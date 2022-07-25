SUMMARY = "Telemetry service"
DESCRIPTION = "Middleware between Redfish Telemetry Service and dbus-sensors"
HOMEPAGE = "https://github.com/openbmc/telemetry"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SRC_URI = "git://github.com/openbmc/telemetry;branch=master;protocol=https"

PV = "1.0+git${SRCPV}"
SRCREV = "39cc6ac99a135f1d7284520fbff613d7eb274f34"

S = "${WORKDIR}/git"

inherit pkgconfig meson
inherit systemd

DEPENDS = "boost \
           gtest \
           nlohmann-json \
           phosphor-logging \
           sdbusplus \
           systemd"

SYSTEMD_SERVICE:${PN} = "xyz.openbmc_project.Telemetry.service"
EXTRA_OEMESON = "-Dbuildtest=false"

