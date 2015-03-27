Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38887 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbbC0QwX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:52:23 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [RFC 31/39] nfsd: Keep list of acls to dispose of in compoundargs
Date: Fri, 27 Mar 2015 17:50:29 +0100
Message-Id: <2ed6a884e9ec7c230c700920904ed190131e6f5a.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We will decode acls in requests into richacls; those need to be richacl_put()
at the end of the request instead of kfree()d; this allows the vfs to cache
them whenever possible.

NOTE: If we allow only a single acl per request, we can get rid of the list
here.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 26 ++++++++++++++++++++++++++
 fs/nfsd/xdr4.h    |  6 ++++++
 2 files changed, 32 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index df5e66c..4ac816f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -39,6 +39,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/richacl.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -195,6 +196,24 @@ svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, u32 len)
 	return tb->buf;
 }
 
+static struct richacl *
+svcxdr_alloc_richacl(struct nfsd4_compoundargs *argp, u32 nace)
+{
+	struct svcxdr_richacl *acls;
+
+	acls = kmalloc(sizeof(*acls), GFP_KERNEL);
+	if (!acls)
+		return NULL;
+	acls->acl = richacl_alloc(nace, GFP_KERNEL);
+	if (!acls->acl) {
+		kfree(acls);
+		return NULL;
+	}
+	acls->next = argp->acls;
+	argp->acls = acls;
+	return acls->acl;
+}
+
 /*
  * For xdr strings that need to be passed to other kernel api's
  * as null-terminated strings.
@@ -4383,6 +4402,12 @@ int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
 		args->to_free = tb->next;
 		kfree(tb);
 	}
+	while (args->acls) {
+		struct svcxdr_richacl *acls = args->acls;
+		args->acls = acls->next;
+		richacl_put(acls->acl);
+		kfree(acls);
+	}
 	return 1;
 }
 
@@ -4401,6 +4426,7 @@ nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_comp
 	args->pagelen = rqstp->rq_arg.page_len;
 	args->tmpp = NULL;
 	args->to_free = NULL;
+	args->acls = NULL;
 	args->ops = args->iops;
 	args->rqstp = rqstp;
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0bda93e..4ed4db0 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -569,6 +569,11 @@ struct svcxdr_tmpbuf {
 	char buf[];
 };
 
+struct svcxdr_richacl {
+	struct svcxdr_richacl *next;
+	struct richacl *acl;
+};
+
 struct nfsd4_compoundargs {
 	/* scratch variables for XDR decode */
 	__be32 *			p;
@@ -578,6 +583,7 @@ struct nfsd4_compoundargs {
 	__be32				tmp[8];
 	__be32 *			tmpp;
 	struct svcxdr_tmpbuf		*to_free;
+	struct svcxdr_richacl		*acls;
 
 	struct svc_rqst			*rqstp;
 
-- 
2.1.0

