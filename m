Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:44905 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932908AbaDIRbv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Apr 2014 13:31:51 -0400
Date: Wed, 9 Apr 2014 19:31:48 +0200
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: akpm <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSD: Remove NULL value assignments
Message-Id: <20140409193148.548f7fc5f0356f61257b2f41@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Static values are automatically initialized to NULL.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/nfsd/nfs4state.c | 10 +++++-----
 fs/nfsd/nfssvc.c    |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3ba6597..c80097e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -83,11 +83,11 @@ static DEFINE_MUTEX(client_mutex);
  */
 static DEFINE_SPINLOCK(recall_lock);
 
-static struct kmem_cache *openowner_slab = NULL;
-static struct kmem_cache *lockowner_slab = NULL;
-static struct kmem_cache *file_slab = NULL;
-static struct kmem_cache *stateid_slab = NULL;
-static struct kmem_cache *deleg_slab = NULL;
+static struct kmem_cache *openowner_slab;
+static struct kmem_cache *lockowner_slab;
+static struct kmem_cache *file_slab;
+static struct kmem_cache *stateid_slab;
+static struct kmem_cache *deleg_slab;
 
 void
 nfs4_lock_state(void)
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9a4a5f9..04407a4 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -205,7 +205,7 @@ static int nfsd_init_socks(struct net *net)
 	return 0;
 }
 
-static int nfsd_users = 0;
+static int nfsd_users;
 
 static int nfsd_startup_generic(int nrservs)
 {
