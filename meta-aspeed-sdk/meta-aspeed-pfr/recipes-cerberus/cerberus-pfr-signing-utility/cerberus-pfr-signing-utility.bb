SUMMARY = "Cerberus PFR signing utility"
DESCRIPTION = "Cerberus PFR signing utility for manifest and recovery image creation"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=323954e5c90a1cc83ee74a3797f8d988"

SRC_URI = " git://github.com/AspeedTech-BMC/cerberus.git;protocol=https;branch=${BRANCH} \
            file://keys \
            file://manifest_tools \
            file://recovery_tools \
          "

PV = "2.0+git${SRCPV}"
SRCREV = "51e55fa2c73f91a81629cefd081e049b5518d2f1"
BRANCH = "aspeed-master"

S = "${WORKDIR}/git"

inherit python3native setuptools3

DEPENDS:append = " ${PYTHON_PN}-pycryptodome-native "

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    # manifest tools
    install -d -m 0755 ${D}${datadir}/cerberus/manifest_tools
    install -m 0644 ${S}/tools/manifest_tools/*.* ${D}${datadir}/cerberus/manifest_tools/.
    # install config, xml and key
    install -m 0644 ${WORKDIR}/keys/*.* ${D}${datadir}/cerberus/manifest_tools/.
    install -m 0644 ${WORKDIR}/manifest_tools/*.* ${D}${datadir}/cerberus/manifest_tools/.

    # recovery tools
    install -d -m 0755 ${D}${datadir}/cerberus/recovery_tools
    install -m 0644 ${S}/tools/recovery_tools/*.* ${D}${datadir}/cerberus/recovery_tools/.
    # install config, xml and key
    install -m 0644 ${WORKDIR}/keys/*.* ${D}${datadir}/cerberus/recovery_tools/.
    install -m 0644 ${WORKDIR}/recovery_tools/*.* ${D}${datadir}/cerberus/recovery_tools/.

    # provision tools
    install -d -m 0755 ${D}${datadir}/cerberus/provision_tools
    install -m 0644 ${S}/tools/provision_tools/*.* ${D}${datadir}/cerberus/provision_tools/.
    # install key
    install -m 0644 ${WORKDIR}/keys/*.* ${D}${datadir}/cerberus/provision_tools/.

    # key management
    install -d -m 0755 ${D}${datadir}/cerberus/key_management_tools
    install -m 0644 ${S}/tools/key_management_tools/*.* ${D}${datadir}/cerberus/key_management_tools/.
    # install key
    install -m 0644 ${WORKDIR}/keys/*.* ${D}${datadir}/cerberus/key_management_tools/.
}

BBCLASSEXTEND = "native nativesdk"

FILES:${PN}:append = " ${datadir}/cerberus/* "
