FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " \
                   file://ast2700-evb.json \
                   file://blacklist.json \
                 "

do_install:append() {
     install -d ${D}/usr/share/entity-manager/configurations
     install -m 0444 ${WORKDIR}/ast2700-evb.json ${D}/usr/share/entity-manager/configurations
     install -m 0444 ${WORKDIR}/blacklist.json -D -t ${D}${datadir}/entity-manager
}

