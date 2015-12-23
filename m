Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:6139 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbbLWVhr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2015 16:37:47 -0500
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: kernel-janitors@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] lockd: constify nlmsvc_binding structure
Date: Wed, 23 Dec 2015 22:25:13 +0100
Message-Id: <1450905913-657-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nlmsvc_binding structure is never modified, so declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

This assumes that whoever takes advantage of the EXPORT_SYMBOL will also
not want to write in the fields.  Is that reasonable?

 fs/lockd/svc.c             |    2 +-
 fs/nfsd/lockd.c            |    2 +-
 include/linux/lockd/bind.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 44d18ad..0c1a699 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -48,7 +48,7 @@
 
 static struct svc_program	nlmsvc_program;
 
-struct nlmsvc_binding *		nlmsvc_ops;
+const struct nlmsvc_binding	*nlmsvc_ops;
 EXPORT_SYMBOL_GPL(nlmsvc_ops);
 
 static DEFINE_MUTEX(nlmsvc_mutex);
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 4d24d64..140edab6 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -29,7 +29,7 @@ struct nlmsvc_binding {
 	void			(*fclose)(struct file *);
 };
 
-extern struct nlmsvc_binding *	nlmsvc_ops;
+extern const struct nlmsvc_binding *nlmsvc_ops;
 
 /*
  * Similar to nfs_client_initdata, but without the NFS-specific
diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 77e7a5c..1a03bc3 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -58,7 +58,7 @@ nlm_fclose(struct file *filp)
 	fput(filp);
 }
 
-static struct nlmsvc_binding	nfsd_nlm_ops = {
+static const struct nlmsvc_binding nfsd_nlm_ops = {
 	.fopen		= nlm_fopen,		/* open file for locking */
 	.fclose		= nlm_fclose,		/* close file */
 };

