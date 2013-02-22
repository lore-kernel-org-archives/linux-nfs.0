Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10761 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757765Ab3BVRJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Feb 2013 12:09:46 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] NFSDv4.2: Added NFS v4.2 support to the NFS server
Date: Fri, 22 Feb 2013 12:09:41 -0500
Message-Id: <1361552981-29385-3-git-send-email-steved@redhat.com>
In-Reply-To: <1361552981-29385-1-git-send-email-steved@redhat.com>
References: <1361552981-29385-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This enable NFSv4.2 support for the server. To enable this
code do the following:
  echo "+4.2" >/proc/fs/nfsd/versions

after the nfsd kernel module is loaded.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 fs/nfsd/nfs4xdr.c   | 1 +
 fs/nfsd/nfsd.h      | 2 +-
 fs/nfsd/state.h     | 2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ac8ed96..947c550 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1678,7 +1678,7 @@ out_new:
 		status = nfserr_jukebox;
 		goto out;
 	}
-	new->cl_minorversion = 1;
+	new->cl_minorversion = cstate->minorversion;
 
 	gen_clid(new, nn);
 	add_to_unconfirmed(new);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d2ae8db..86be853 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1621,6 +1621,7 @@ struct nfsd4_minorversion_ops {
 static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
 	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
 	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
+	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
 };
 
 static __be32
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 26a457b..0e3ccd1 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -24,7 +24,7 @@
 /*
  * nfsd version
  */
-#define NFSD_SUPPORTED_MINOR_VERSION	1
+#define NFSD_SUPPORTED_MINOR_VERSION	2
 /*
  * Maximum blocksizes supported by daemon under various circumstances.
  */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d1c229f..de9416b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -108,7 +108,7 @@ struct nfs4_cb_conn {
 	u32                     cb_prog; /* used only in 4.0 case;
 					    per-session otherwise */
 	u32                     cb_ident;	/* minorversion 0 only */
-	struct svc_xprt		*cb_xprt;	/* minorversion 1 only */
+	struct svc_xprt		*cb_xprt;	/* minorversion >= 1 only */
 };
 
 static inline struct nfs4_delegation *delegstateid(struct nfs4_stid *s)
-- 
1.8.1.2

