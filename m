From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/24] NFS: Decode NFSv2 readdir reply using an xdr_stream
Date: Sun, 16 May 2010 22:48:51 -0400
Message-ID: <20100517024851.20258.44548.stgit@localhost.localdomain>
References: <20100517023905.20258.86631.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076Ab0EQCsx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:48:53 -0400
Received: by mail-qy0-f171.google.com with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:48:53 -0700 (PDT)
In-Reply-To: <20100517023905.20258.86631.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |  173 +++++++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 152 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 565a5c6..1d65103 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -834,27 +834,6 @@ err_unmap:
 	goto out;
 }
 
-__be32 *
-nfs_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
-{
-	if (!*p++) {
-		if (!*p)
-			return ERR_PTR(-EAGAIN);
-		entry->eof = 1;
-		return ERR_PTR(-EBADCOOKIE);
-	}
-
-	entry->ino	  = ntohl(*p++);
-	entry->len	  = ntohl(*p++);
-	entry->name	  = (const char *) p;
-	p		 += XDR_QUADLEN(entry->len);
-	entry->prev_cookie	  = entry->cookie;
-	entry->cookie	  = ntohl(*p++);
-	entry->eof	  = !p[0] && p[1];
-
-	return p;
-}
-
 /*
  * NFS XDR decode functions
  */
@@ -1110,6 +1089,158 @@ static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
 }
 
 /*
+ * 2.2.17.  entry
+ *
+ * struct entry {
+ *	unsigned fileid;
+ *	filename name;
+ *	nfscookie cookie;
+ *	entry *nextentry;
+ * };
+ *
+ * The type (size) of nfscookie isn't defined in RFC 1094.
+ * The "nextentry" field is not used; instead, each entry
+ * is preceded by a boolean "entry follows" field.
+ *
+ * The Linux implementation is limited to receiving not more
+ * than a single page of entries at a time.
+ *
+ * Here, the XDR buffer is checked for correct syntax.  The
+ * actual decoding is done by nfs_decode_entry() during
+ * subsequent nfs_readdir() calls.
+ */
+static int decode_readdirok(struct xdr_stream *xdr)
+{
+	struct xdr_buf *rcvbuf = xdr->buf;
+	struct page **page = rcvbuf->pages;
+	__be32 *p, *end, *entry, *kaddr;
+	unsigned int nr, pglen, recvd;
+	size_t hdrlen;
+
+	pglen = rcvbuf->page_len;
+	hdrlen = (u8 *)xdr->p - (u8 *)xdr->iov->iov_base;
+	recvd = rcvbuf->len - hdrlen;
+	if (pglen > recvd)
+		pglen = recvd;
+	xdr_read_pages(xdr, pglen);
+	kaddr = p = kmap_atomic(*page, KM_USER0);
+	end = (__be32 *)((char *)p + pglen);
+	entry = p;
+
+	/* Make sure the packet actually has a value_follows and EOF entry */
+	if ((entry + 1) > end)
+		goto short_pkt;
+
+	nr = 0;
+	for (; *p++; nr++) {
+		u32 len;
+
+		if (p + 2 > end)
+			goto short_pkt;
+		p++;	/* fileid */
+		len = be32_to_cpup(p++);
+		if (len > NFS2_MAXNAMLEN) {
+			dprintk("NFS: giant filename in readdir (len 0x%x)!\n",
+					len);
+			goto err_unmap;
+		}
+		p += XDR_QUADLEN(len) + 1;	/* name plus cookie */
+		if (p + 2 > end)
+			goto short_pkt;
+		entry = p;
+	}
+
+	/*
+	 * Apparently some server sends responses that are a valid size, but
+	 * contain no entries, and have value_follows==0 and EOF==0. For
+	 * those, just set the EOF marker.
+	 */
+	if (!nr && entry[1] == 0) {
+		dprintk("NFS: readdir reply truncated!\n");
+		entry[1] = 1;
+	}
+out:
+	kunmap_atomic(kaddr, KM_USER0);
+	return nr;
+short_pkt:
+	/*
+	 * When we get a short packet there are 2 possibilities. We can
+	 * return an error, or fix up the response to look like a valid
+	 * response and return what we have so far. If there are no
+	 * entries and the packet was short, then return -EIO. If there
+	 * are valid entries in the response, return them and pretend that
+	 * the call was successful, but incomplete. The caller can retry the
+	 * readdir starting at the last cookie.
+	 */
+	dprintk("%s: short packet at entry %d\n", __func__, nr);
+	entry[0] = entry[1] = 0;
+	if (nr)
+		goto out;
+err_unmap:
+	kunmap_atomic(kaddr, KM_USER0);
+	return -EIO;
+}
+
+/*
+ * 2.2.17.  readdirres
+ *
+ *	union readdirres switch (stat status) {
+ *	case NFS_OK:
+ *		struct {
+ *			entry *entries;
+ *			bool eof;
+ *		} readdirok;
+ *	default:
+ *		void;
+ *	};
+ */
+static int nfs2_xdr_dec_readdirres(struct rpc_rqst *req, __be32 *p,
+				   void *__unused)
+{
+	struct xdr_stream xdr;
+	enum nfs_stat status;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	if (decode_stat(&xdr, &status) != 0)
+		return -EIO;
+	if (status != NFS_OK)
+		return nfs_stat_to_errno(status);
+	return decode_readdirok(&xdr);
+}
+
+/**
+ * nfs_decode_dirent - Decode a single NFSv2 directory entry stored in
+ *                     the local page cache.
+ * @p: pointer to buffer where entry resides
+ * @entry: entry struct to fill out with data
+ * @plus: boolean indicating whether this should be a readdirplus entry
+ *
+ * Returns the position of the next item in the buffer, or an ERR_PTR.
+ *
+ * This function is not invoked during READDIR reply processing, but
+ * rather whenever an application invokes the getdents(2) system call.
+ */
+__be32 *nfs_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
+{
+	if (!*p++) {
+		if (!*p)
+			return ERR_PTR(-EAGAIN);
+		entry->eof = 1;
+		return ERR_PTR(-EBADCOOKIE);
+	}
+
+	entry->ino = be32_to_cpup(p++);
+	entry->len = be32_to_cpup(p++);
+	entry->name = (const char *)p;
+	p += XDR_QUADLEN(entry->len);
+	entry->prev_cookie = entry->cookie;
+	entry->cookie = be32_to_cpup(p++);
+
+	entry->eof = !p[0] && p[1];
+	return p;
+}
+
+/*
  * Decode STATFS reply
  */
 static int

