Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8292 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925Ab2AZScg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 13:32:36 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] NFS: printks in fs/nfs/ should start with NFS:
Date: Thu, 26 Jan 2012 13:32:22 -0500
Message-Id: <1327602743-1152-2-git-send-email-dros@netapp.com>
In-Reply-To: <1327602743-1152-1-git-send-email-dros@netapp.com>
References: <1327602743-1152-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Messages like "Got error -10052 from the server on DESTROY_SESSION. Session
has been destroyed regardless" can be confusing to users who aren't very
familiar with NFS.

NOTE: This patch ignores any printks() that start by printing __func__ - that
will be in a separate patch.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/idmap.c          |    3 ++-
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/nfs4state.c      |    2 +-
 fs/nfs/nfs4xdr.c        |    2 +-
 5 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index ff084d2..91b1e2a 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -175,7 +175,8 @@ int nfs_idmap_init(void)
 	struct key *keyring;
 	int ret = 0;
 
-	printk(KERN_NOTICE "Registering the %s key type\n", key_type_id_resolver.name);
+	printk(KERN_NOTICE "NFS: Registering the %s key type\n",
+		key_type_id_resolver.name);
 
 	cred = prepare_kernel_cred(NULL);
 	if (!cred)
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b4f8f96..9a058b8 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -575,7 +575,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 			goto out_err_free;
 		fl->fh_array[i]->size = be32_to_cpup(p++);
 		if (sizeof(struct nfs_fh) < fl->fh_array[i]->size) {
-			printk(KERN_ERR "Too big fh %d received %d\n",
+			printk(KERN_ERR "NFS: Too big fh %d received %d\n",
 			       i, fl->fh_array[i]->size);
 			goto out_err_free;
 		}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 05dbba6..0773bbb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5371,7 +5371,7 @@ int nfs4_proc_destroy_session(struct nfs4_session *session)
 
 	if (status)
 		printk(KERN_WARNING
-			"Got error %d from the server on DESTROY_SESSION. "
+			"NFS: Got error %d from the server on DESTROY_SESSION. "
 			"Session has been destroyed regardless...\n", status);
 
 	dprintk("<-- nfs4_proc_destroy_session\n");
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7d09860..b43a65d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1764,7 +1764,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 	} while (atomic_read(&clp->cl_count) > 1);
 	return;
 out_error:
-	printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
+	printk(KERN_WARNING "NFS: state manager failed on NFSv4 server %s"
 			" with error %d\n", clp->cl_hostname, -status);
 	nfs4_end_drain_session(clp);
 	nfs4_clear_state_manager_bit(clp);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4633d40..0f24f14 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1023,7 +1023,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	 * Now we backfill the bitmap and the attribute buffer length.
 	 */
 	if (len != ((char *)p - (char *)q) + 4) {
-		printk(KERN_ERR "nfs: Attr length error, %u != %Zu\n",
+		printk(KERN_ERR "NFS: Attr length error, %u != %Zu\n",
 				len, ((char *)p - (char *)q) + 4);
 		BUG();
 	}
-- 
1.7.4.4

