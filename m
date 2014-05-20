Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:53894 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244AbaETSIe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:34 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 10/12] nfs: Split up generic_pg_pgios
Date: Tue, 20 May 2014 14:08:17 -0400
Message-ID: <1400609299-32558-11-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs will need a way to use a different function to initiate IO and to
free the pgio_header.  The common function now expects a function
pointer for each.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  4 ++++
 fs/nfs/pagelist.c | 24 +++++++++++++++++++-----
 2 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5b64177..3a5abf0 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -242,6 +242,10 @@ struct nfs_pgio_header *nfs_pgio_header_alloc(const struct nfs_rw_ops *);
 void nfs_pgio_header_free(struct nfs_pgio_header *);
 int nfs_generic_pgio(struct nfs_pageio_descriptor *, struct nfs_pgio_header *);
 void nfs_generic_pgio_reset(struct nfs_pgio_header *);
+int nfs_generic_pgios_common(struct nfs_pageio_descriptor *,
+			     void (*)(struct nfs_pgio_header *),
+			     int (*)(struct nfs_pageio_descriptor *,
+				     struct nfs_pgio_header *));
 int nfs_initiate_pgio(struct rpc_clnt *, struct nfs_pgio_header *,
 		      const struct rpc_call_ops *, int, int);
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index d1670a2..fc01c5b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -722,8 +722,18 @@ void nfs_generic_pgio_reset(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pgio_reset);
 
+static int nfs_do_pgio(struct nfs_pageio_descriptor *desc,
+		       struct nfs_pgio_header *hdr)
+{
+	return nfs_initiate_pgio(NFS_CLIENT(hdr->inode),
+				 hdr, desc->pg_rpc_callops,
+				 desc->pg_ioflags, 0);
+}
 
-static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
+int nfs_generic_pgios_common(struct nfs_pageio_descriptor *desc,
+			     void (*free_header)(struct nfs_pgio_header *),
+			     int (*do_pgio)(struct nfs_pageio_descriptor *,
+					    struct nfs_pgio_header *))
 {
 	struct nfs_pgio_header *hdr;
 	int ret;
@@ -733,14 +743,18 @@ static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
 		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		return -ENOMEM;
 	}
-	nfs_pgheader_init(desc, hdr, nfs_pgio_header_free);
+	nfs_pgheader_init(desc, hdr, free_header);
 	ret = nfs_generic_pgio(desc, hdr);
 	if (ret == 0)
-		ret = nfs_initiate_pgio(NFS_CLIENT(hdr->inode),
-					hdr, desc->pg_rpc_callops,
-					desc->pg_ioflags, 0);
+		ret = do_pgio(desc, hdr);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_generic_pgios_common);
+
+static int nfs_generic_pg_pgios(struct nfs_pageio_descriptor *desc)
+{
+	return nfs_generic_pgios_common(desc, nfs_pgio_header_free, nfs_do_pgio);
+}
 
 static bool nfs_match_open_context(const struct nfs_open_context *ctx1,
 		const struct nfs_open_context *ctx2)
-- 
1.9.2

