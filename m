From: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
Subject: [PATCH 08/10] edac_core: Uses call_rcu() and its own
	wait_for_completion scheme.
Date: Tue, 23 Jun 2009 17:04:34 +0200
Message-ID: <20090623150434.22490.18824.stgit@localhost>
References: <20090623150330.22490.87327.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net,
	axboe@kernel.dk, "Patrick McHardy" <kaber@trash.net>,
	christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com,
	linux-wireless@vger.kernel.org, johannes@sipsolutions.net,
	yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org,
	linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-ext4@vger.kernel.org, tytso@mit.edu, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-wireless-owner@vger.kernel.org>
In-Reply-To: <20090623150330.22490.87327.stgit@localhost>
Sender: linux-wireless-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Module edac_core.ko uses call_rcu() callbacks in edac_device.c, edac_mc.c
and edac_pci.c.

They all uses a wait_for_completion scheme, but this scheme it not 100%
safe on multiple CPUs.  See the _rcu_barrier() implementation which explains
why extra precausion is needed.

The patch adds a comment about rcu_barrier() and as a precausion calls
rcu_barrier().  A maintainer needs to look at removing the wait_for_completion
code.

Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
---

 drivers/edac/edac_device.c |    5 +++++
 drivers/edac/edac_mc.c     |    5 +++++
 drivers/edac/edac_pci.c    |    5 +++++
 3 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/edac/edac_device.c b/drivers/edac/edac_device.c
index b02a6a6..5e831c9 100644
--- a/drivers/edac/edac_device.c
+++ b/drivers/edac/edac_device.c
@@ -373,6 +373,11 @@ static void del_edac_device_from_global_list(struct edac_device_ctl_info
 	init_completion(&edac_device->removal_complete);
 	call_rcu(&edac_device->rcu, complete_edac_device_list_del);
 	wait_for_completion(&edac_device->removal_complete);
+
+	/* hawk-4UpuNZONu4c@public.gmane.org 2009-06-22: I think that rcu_barrier() should
+	 *  be used instead of wait_for_completion, because
+	 *  rcu_barrier() take multiple CPUs into account */
+	rcu_barrier();
 }
 
 /*
diff --git a/drivers/edac/edac_mc.c b/drivers/edac/edac_mc.c
index 335b7eb..edcce41 100644
--- a/drivers/edac/edac_mc.c
+++ b/drivers/edac/edac_mc.c
@@ -428,6 +428,11 @@ static void del_mc_from_global_list(struct mem_ctl_info *mci)
 	init_completion(&mci->complete);
 	call_rcu(&mci->rcu, complete_mc_list_del);
 	wait_for_completion(&mci->complete);
+
+	/* hawk-4UpuNZONu4c@public.gmane.org 2009-06-22: I think that rcu_barrier() should
+	 *  be used instead of wait_for_completion, because
+	 *  rcu_barrier() take multiple CPUs into account */
+	rcu_barrier();
 }
 
 /**
diff --git a/drivers/edac/edac_pci.c b/drivers/edac/edac_pci.c
index 30b585b..d0eb8c9 100644
--- a/drivers/edac/edac_pci.c
+++ b/drivers/edac/edac_pci.c
@@ -188,6 +188,11 @@ static void del_edac_pci_from_global_list(struct edac_pci_ctl_info *pci)
 	init_completion(&pci->complete);
 	call_rcu(&pci->rcu, complete_edac_pci_list_del);
 	wait_for_completion(&pci->complete);
+
+	/* hawk-4UpuNZONu4c@public.gmane.org 2009-06-22: I think that rcu_barrier() should
+	 *  be used instead of wait_for_completion, because
+	 *  rcu_barrier() take multiple CPUs into account */
+	rcu_barrier();
 }
 
 #if 0

