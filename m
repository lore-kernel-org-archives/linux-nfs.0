Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0103.hostedemail.com ([216.40.44.103]:47337 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751677AbeCWWzM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2018 18:55:12 -0400
From: Joe Perches <joe@perches.com>
To: netdev@vger.kernel.org, linux-can@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        nios2-dev@lists.rocketboards.org, linuxppc-dev@lists.ozlabs.org,
        intel-wired-lan@lists.osuosl.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, devel@linuxdriverproject.org,
        linux-wpan@vger.kernel.org, linux-ppp@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        wcn36xx@lists.infradead.org, xen-devel@lists.xenproject.org,
        bridge@lists.linux-foundation.org, ceph-devel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-afs@lists.infradead.org, linux-sctp@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-x25@vger.kernel.org,
        linux-mediatek@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, oss-drivers@netronome.com,
        brcm80211-dev-list.pdl@broadcom.com,
        brcm80211-dev-list@cypress.com, linux-bluetooth@vger.kernel.org
Subject: [PATCH 0/4] net: drivers/net: Use octal permissions
Date: Fri, 23 Mar 2018 15:54:35 -0700
Message-Id: <cover.1521845235.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using octal and not symbolic permissions is preferred by many as
more readable.

https://lkml.org/lkml/2016/8/2/1945

Rather than getting these piecemeal, just do them all.
Done with checkpatch and some typing.

Joe Perches (4):
  ethernet: Use octal not symbolic permissions
  wireless: Use octal not symbolic permissions
  net: Use octal not symbolic permissions
  drivers/net: Use octal not symbolic permissions

 drivers/net/bonding/bond_procfs.c                  |   2 +-
 drivers/net/bonding/bond_sysfs.c                   |  73 +++++++-------
 drivers/net/bonding/bond_sysfs_slave.c             |   4 +-
 drivers/net/caif/caif_serial.c                     |  32 +++---
 drivers/net/caif/caif_spi.c                        |  16 +--
 drivers/net/caif/caif_virtio.c                     |  16 +--
 drivers/net/can/at91_can.c                         |   3 +-
 drivers/net/can/cc770/cc770.c                      |   4 +-
 drivers/net/can/cc770/cc770_isa.c                  |  16 +--
 drivers/net/can/grcan.c                            |   4 +-
 drivers/net/can/janz-ican3.c                       |   6 +-
 drivers/net/can/sja1000/sja1000_isa.c              |  14 +--
 drivers/net/can/softing/softing_main.c             |   4 +-
 drivers/net/can/spi/mcp251x.c                      |   2 +-
 drivers/net/can/usb/esd_usb2.c                     |   6 +-
 drivers/net/can/vcan.c                             |   2 +-
 drivers/net/ethernet/8390/apne.c                   |   2 +-
 drivers/net/ethernet/8390/lib8390.c                |   2 +-
 drivers/net/ethernet/8390/ne.c                     |   2 +-
 drivers/net/ethernet/8390/ne2k-pci.c               |   2 +-
 drivers/net/ethernet/8390/smc-ultra.c              |   2 +-
 drivers/net/ethernet/8390/stnic.c                  |   2 +-
 drivers/net/ethernet/8390/wd.c                     |   2 +-
 drivers/net/ethernet/altera/altera_tse_main.c      |   6 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  10 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |   2 +-
 drivers/net/ethernet/broadcom/bnx2.c               |   2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |  12 +--
 drivers/net/ethernet/broadcom/sb1250-mac.c         |  10 +-
 drivers/net/ethernet/broadcom/tg3.c                |   6 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |   2 +-
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c    |  10 +-
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |   6 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 112 ++++++++++-----------
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  10 +-
 drivers/net/ethernet/ec_bhf.c                      |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |   6 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |   7 +-
 drivers/net/ethernet/ibm/ibmveth.c                 |   2 +-
 drivers/net/ethernet/intel/igb/igb_hwmon.c         |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |   2 +-
 drivers/net/ethernet/marvell/mvneta.c              |   8 +-
 drivers/net/ethernet/marvell/skge.c                |   2 +-
 drivers/net/ethernet/marvell/sky2.c                |   2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |  16 +--
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c   |  10 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |  32 +++---
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   6 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  14 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |  30 +++---
 drivers/net/ethernet/qualcomm/qca_debug.c          |   2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    |   4 +-
 drivers/net/ethernet/sfc/mcdi_mon.c                |   2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  26 ++---
 drivers/net/ethernet/sun/niu.c                     |  10 +-
 drivers/net/hamradio/bpqether.c                    |   3 +-
 drivers/net/hamradio/yam.c                         |   2 +-
 drivers/net/hyperv/netvsc_drv.c                    |   4 +-
 drivers/net/ieee802154/at86rf230.c                 |   2 +-
 drivers/net/phy/spi_ks8995.c                       |   2 +-
 drivers/net/ppp/ppp_generic.c                      |   2 +-
 drivers/net/ppp/pppoe.c                            |   2 +-
 drivers/net/usb/cdc_ncm.c                          |  12 +--
 drivers/net/usb/hso.c                              |   8 +-
 drivers/net/wireless/ath/ath5k/base.c              |   6 +-
 drivers/net/wireless/ath/ath5k/debug.c             |  37 ++-----
 drivers/net/wireless/ath/ath5k/sysfs.c             |   8 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |  43 ++++----
 drivers/net/wireless/ath/ath9k/common-debug.c      |   9 +-
 drivers/net/wireless/ath/ath9k/common-spectral.c   |  10 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  40 ++++----
 drivers/net/wireless/ath/ath9k/debug_sta.c         |   6 +-
 drivers/net/wireless/ath/ath9k/dfs_debug.c         |   4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_debug.c     |  16 +--
 drivers/net/wireless/ath/ath9k/tx99.c              |   4 +-
 drivers/net/wireless/ath/carl9170/debug.c          |   8 +-
 drivers/net/wireless/ath/carl9170/main.c           |   4 +-
 drivers/net/wireless/ath/wcn36xx/debug.c           |   5 +-
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |   6 +-
 .../wireless/broadcom/brcm80211/brcmsmac/debug.c   |   2 +-
 .../broadcom/brcm80211/brcmsmac/mac80211_if.c      |   2 +-
 drivers/net/wireless/cisco/airo.c                  |   6 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c       |  29 +++---
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |  51 ++++------
 drivers/net/wireless/intel/ipw2x00/libipw_module.c |   2 +-
 drivers/net/wireless/intel/iwlegacy/3945-mac.c     |  35 +++----
 drivers/net/wireless/intel/iwlegacy/4965-mac.c     |  19 ++--
 drivers/net/wireless/intel/iwlegacy/4965-rs.c      |   8 +-
 drivers/net/wireless/intel/iwlegacy/common.c       |   4 +-
 drivers/net/wireless/intel/iwlegacy/debug.c        |  58 ++++++-----
 drivers/net/wireless/intel/iwlwifi/dvm/debugfs.c   |  78 +++++++-------
 drivers/net/wireless/intel/iwlwifi/dvm/rs.c        |  16 +--
 drivers/net/wireless/intel/iwlwifi/fw/debugfs.c    |   2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |  43 ++++----
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |  40 +++-----
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   | 110 ++++++++++----------
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c        |  12 +--
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  12 +--
 drivers/net/wireless/intersil/p54/main.c           |   2 +-
 drivers/net/wireless/mediatek/mt76/debugfs.c       |  10 +-
 .../net/wireless/mediatek/mt76/mt76x2_debugfs.c    |   8 +-
 drivers/net/wireless/mediatek/mt7601u/debugfs.c    |  16 ++-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c     |   2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800pci.c     |   2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800soc.c     |   2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c     |   2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00debug.c   |  64 ++++++------
 drivers/net/wireless/ralink/rt2x00/rt61pci.c       |   2 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c       |   2 +-
 drivers/net/wireless/ray_cs.c                      |   8 +-
 drivers/net/wireless/st/cw1200/debug.c             |   6 +-
 drivers/net/wireless/st/cw1200/main.c              |   2 +-
 drivers/net/wireless/ti/wl18xx/main.c              |  27 +++--
 drivers/net/wireless/ti/wlcore/main.c              |   8 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |   2 +-
 drivers/net/wireless/ti/wlcore/sysfs.c             |   7 +-
 drivers/net/xen-netback/xenbus.c                   |   4 +-
 drivers/net/xen-netfront.c                         |   6 +-
 net/8021q/vlanproc.c                               |   6 +-
 net/appletalk/atalk_proc.c                         |   8 +-
 net/atm/atm_sysfs.c                                |  12 +--
 net/atm/clip.c                                     |   2 +-
 net/atm/lec.c                                      |   2 +-
 net/atm/proc.c                                     |   2 +-
 net/ax25/af_ax25.c                                 |   6 +-
 net/bluetooth/rfcomm/tty.c                         |   4 +-
 net/bridge/br_sysfs_br.c                           |   2 +-
 net/bridge/br_sysfs_if.c                           |  36 +++----
 net/can/af_can.c                                   |   2 +-
 net/can/gw.c                                       |   2 +-
 net/ceph/ceph_common.c                             |   2 +-
 net/core/net-procfs.c                              |   6 +-
 net/core/net-sysfs.c                               |  12 +--
 net/core/sock.c                                    |   2 +-
 net/decnet/af_decnet.c                             |   2 +-
 net/decnet/dn_dev.c                                |   2 +-
 net/decnet/dn_neigh.c                              |   2 +-
 net/decnet/dn_route.c                              |   2 +-
 net/dns_resolver/dns_key.c                         |   2 +-
 net/ipv4/arp.c                                     |   2 +-
 net/ipv4/fib_trie.c                                |   6 +-
 net/ipv4/igmp.c                                    |   4 +-
 net/ipv4/ipconfig.c                                |   2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |   2 +-
 net/ipv4/ping.c                                    |   2 +-
 net/ipv4/proc.c                                    |   6 +-
 net/ipv4/raw.c                                     |   2 +-
 net/ipv4/route.c                                   |   4 +-
 net/ipv4/tcp_ipv4.c                                |   2 +-
 net/ipv4/udp.c                                     |   2 +-
 net/ipv6/addrconf.c                                |   2 +-
 net/ipv6/anycast.c                                 |   2 +-
 net/ipv6/ip6_flowlabel.c                           |   2 +-
 net/ipv6/mcast.c                                   |   4 +-
 net/ipv6/proc.c                                    |   6 +-
 net/ipv6/raw.c                                     |   2 +-
 net/ipv6/route.c                                   |   2 +-
 net/kcm/kcmproc.c                                  |   4 +-
 net/l2tp/l2tp_ppp.c                                |   2 +-
 net/llc/llc_proc.c                                 |   4 +-
 net/mac80211/rc80211_minstrel.c                    |   2 +-
 net/mac80211/rc80211_minstrel_debugfs.c            |   8 +-
 net/mac80211/rc80211_minstrel_ht_debugfs.c         |   8 +-
 net/netfilter/nf_conntrack_netbios_ns.c            |   2 +-
 net/netfilter/nf_conntrack_snmp.c                  |   2 +-
 net/netfilter/nf_conntrack_standalone.c            |   2 +-
 net/netfilter/nf_log.c                             |   2 +-
 net/netfilter/nf_synproxy_core.c                   |   2 +-
 net/netfilter/xt_IDLETIMER.c                       |   2 +-
 net/netfilter/xt_recent.c                          |   4 +-
 net/netrom/af_netrom.c                             |   6 +-
 net/rose/af_rose.c                                 |   8 +-
 net/rxrpc/af_rxrpc.c                               |   2 +-
 net/sctp/proc.c                                    |  16 +--
 net/sunrpc/auth_gss/svcauth_gss.c                  |   2 +-
 net/sunrpc/cache.c                                 |  10 +-
 net/sunrpc/debugfs.c                               |   6 +-
 net/sunrpc/rpc_pipe.c                              |  42 ++++----
 net/wireless/wext-proc.c                           |   2 +-
 net/x25/x25_proc.c                                 |  12 +--
 net/xfrm/xfrm_proc.c                               |   2 +-
 183 files changed, 906 insertions(+), 969 deletions(-)

-- 
2.15.0

