Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:32808 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751873AbdAaTRc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 14:17:32 -0500
Date: Tue, 31 Jan 2017 19:17:04 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Cc: Andrew Lunn <andrew@lunn.ch>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jiri Slaby <jirislaby@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
        Nick Kossifidis <mickflemm@gmail.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Timur Tabi <timur@codeaurora.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung Huh <woojung.huh@microchip.com>
Subject: [PATCH 4.10-rc3 00/13] net: dsa: remove unnecessary phy.h include
Message-ID: <20170131191704.GA8281@n2100.armlinux.org.uk>
References: <20170118001403.GJ27312@n2100.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170118001403.GJ27312@n2100.armlinux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Including phy.h and phy_fixed.h into net/dsa.h causes phy*.h to be an
unnecessary dependency for quite a large amount of the kernel.  There's
very little which actually requires definitions from phy.h in net/dsa.h
- the include itself only wants the declaration of a couple of
structures and IFNAMSIZ.

Add linux/if.h for IFNAMSIZ, declarations for the structures, phy.h to
mv88e6xxx.h as it needs it for phy_interface_t, and remove both phy.h
and phy_fixed.h from net/dsa.h.

This patch reduces from around 800 files rebuilt to around 40 - even
with ccache, the time difference is noticable.

In order to make this change, several drivers need to be updated to
include necessary headers that they were picking up through this
include.  This has resulted in a much larger patch series.

I'm assuming the 0-day builder has had 24 hours with this series, and
hasn't reported any further issues with it - the last issue was two
weeks ago (before I became ill) which I fixed over the last weekend.

I'm hoping this doesn't conflict with what's already in net-next...

 arch/mips/cavium-octeon/octeon-platform.c             | 4 ----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h                 | 1 +
 drivers/net/ethernet/broadcom/bgmac.c                 | 2 ++
 drivers/net/ethernet/cadence/macb.h                   | 2 ++
 drivers/net/ethernet/cavium/liquidio/lio_main.c       | 1 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c    | 1 +
 drivers/net/ethernet/cavium/liquidio/octeon_console.c | 1 +
 drivers/net/ethernet/freescale/fman/fman_memac.c      | 1 +
 drivers/net/ethernet/marvell/mvneta.c                 | 1 +
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c       | 1 +
 drivers/net/usb/lan78xx.c                             | 1 +
 drivers/net/wireless/ath/ath5k/ahb.c                  | 2 +-
 drivers/target/iscsi/iscsi_target_login.c             | 1 +
 include/net/dsa.h                                     | 6 ++++--
 net/core/netprio_cgroup.c                             | 1 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c            | 1 +
 16 files changed, 20 insertions(+), 7 deletions(-)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
