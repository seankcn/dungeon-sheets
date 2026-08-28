# Builder Image
FROM python:alpine AS builder-image

WORKDIR /app
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"
RUN pip install --upgrade pip

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . /app
RUN cd /app && pip install --no-cache-dir .


# Final Image
FROM python:alpine AS final-image

COPY --from=builder-image /venv /venv
ENV PATH="/venv/bin:$PATH"

ARG TL_MIRROR="https://texlive.info/CTAN/systems/texlive/tlnet"
RUN apk add --no-cache perl curl fontconfig libgcc gnupg && \
    mkdir "/tmp/texlive" && cd "/tmp/texlive" && \
    wget "$TL_MIRROR/install-tl-unx.tar.gz" && \
    tar xzvf ./install-tl-unx.tar.gz && \
    ( \
        echo "selected_scheme scheme-minimal" && \
        echo "instopt_adjustpath 0" && \
        echo "tlpdbopt_install_docfiles 0" && \
        echo "tlpdbopt_install_srcfiles 0" && \
        echo "TEXDIR /opt/texlive/" && \
        echo "TEXMFLOCAL /opt/texlive/texmf-local" && \
        echo "TEXMFSYSCONFIG /opt/texlive/texmf-config" && \
        echo "TEXMFSYSVAR /opt/texlive/texmf-var" && \
        echo "TEXMFHOME ~/.texmf" \
    ) > "/tmp/texlive.profile" && \
    "./install-tl-"*"/install-tl" --location "$TL_MIRROR" -profile "/tmp/texlive.profile" && \
    rm -vf "/opt/texlive/install-tl" && \
    rm -vf "/opt/texlive/install-tl.log" && \
    rm -vrf /tmp/*
ENV PATH="${PATH}:/opt/texlive/bin/x86_64-linuxmusl"
RUN tlmgr install scheme-basic
RUN tlmgr install needspace supertabular enumitem caption gensymb numprint pdfcol tikzfill multitoc
RUN mkdir -p ~/.texmf/tex/latex && \
    wget https://github.com/rpgtex/DND-5e-LaTeX-Template/archive/master.zip && \
    unzip -d ~/.texmf/tex/latex master.zip && \
    mv ~/.texmf/tex/latex/DND-5e-LaTeX-Template-stable ~/.texmf/tex/latex/dnd && \
    rm master.zip
RUN grep -v '^\(#\|ms\|l3backend\)' ~/.texmf/tex/latex/dnd/packages.txt | xargs tlmgr install

WORKDIR /build

CMD [ "python", "-m", "dungeonsheets.make_sheets", "--fancy", "--editable", "--recursive" ]
