From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC][PATCH] client cannot get lock after other client got lock occur
 network partition.
Date: Mon, 09 Nov 2009 17:19:39 +0800
Message-ID: <4AF7DEAB.20202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52403 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754896AbZKIJS0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2009 04:18:26 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond et all

There is a bug, when i test NFSv3 file's lock as followed:

Step1: ClientA and ClientB open a same nfs file;
Step2: ClientA locks file with write lock, it's ok;
Step3: Cut off the network between ClientA and Server;
Step4: ClientB can not acquire for write lock successful forever, even though
       the network partition larger than NLM_HOST_EXPIRE.

As i know, If use NFSv4, step4 can success after LEASE_TIME.

Is it necessary to fix NFSv3 ? 

The attached patch can make this case OK, but i am not sure it's good.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/lockd/host.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 4600c20..c964327 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -550,8 +550,8 @@ nlm_gc_hosts(void)
 
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
 		hlist_for_each_entry_safe(host, pos, next, chain, h_hash) {
-			if (atomic_read(&host->h_count) || host->h_inuse
-			 || time_before(jiffies, host->h_expires)) {
+			if (time_before(jiffies, host->h_expires)
+			    && (atomic_read(&host->h_count) || host->h_inuse))
 				dprintk("nlm_gc_hosts skipping %s (cnt %d use %d exp %ld)\n",
 					host->h_name, atomic_read(&host->h_count),
 					host->h_inuse, host->h_expires);
@@ -560,6 +560,7 @@ nlm_gc_hosts(void)
 			dprintk("lockd: delete host %s\n", host->h_name);
 			hlist_del_init(&host->h_hash);
 
+			nlmsvc_free_host_resources(host);
 			nlm_destroy_host(host);
 			nrhosts--;
 		}
---
thanks,
Mi Jinlong

