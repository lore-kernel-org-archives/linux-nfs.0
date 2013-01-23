Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5001 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602Ab3AWWzl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 17:55:41 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r0NMtfF0000604
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2013 17:55:41 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/7] nfsd4: track maximum bytes
Date: Wed, 23 Jan 2013 17:55:37 -0500
Message-Id: <1358981738-5649-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1358981738-5649-1-git-send-email-bfields@redhat.com>
References: <1358981738-5649-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

All reserve_space is doing currently is checking that we don't run out
of pages, but some users (e.g. readdir) also want to check some other
limit.

XXX: also for 4.1 shouldn't we be checking session-negotiated maximum?

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 11 +++++++++--
 fs/nfsd/xdr4.h    |  1 +
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 19f773e..a378435 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1669,6 +1669,7 @@ static __be32 svcxdr_stream_init_from_resp(struct svcxdr_stream *xdr, struct nfs
 	buf->head[0].iov_len = (char *)resp->p - (char *)buf->head[0].iov_base;
 	buf->len = buf->head[0].iov_len;
 
+	xdr->maxbytes = INT_MAX;
 	xdr->buf = buf;
 	xdr->this_iov = buf->head;
 	xdr->ptr.p = resp->p;
@@ -1683,6 +1684,7 @@ static __be32 svcxdr_stream_init_from_resp(struct svcxdr_stream *xdr, struct nfs
  */
 static void svcxdr_stream_init_from_buffer(struct svcxdr_stream *xdr, __be32 *buf, int len)
 {
+	xdr->maxbytes = INT_MAX;
 	xdr->ptr.p = buf;
 	xdr->ptr.end = buf + len;
 	xdr->ptr.next_page = NULL;
@@ -1724,8 +1726,12 @@ static bool svcxdr_reserve_space(struct svcxdr_stream *xdr, struct svcxdr_ptr *p
 	*ptr = xdr->ptr;
 
 	bytes = roundup(bytes, 4);
-
-	return svcxdr_seek(&xdr->ptr, bytes);
+	if (bytes > xdr->maxbytes)
+		return false;
+	if (!svcxdr_seek(&xdr->ptr, bytes))
+		return false;
+	xdr->maxbytes -= bytes;
+	return true;
 }
 
 /* XXX: basic idea here:
@@ -1827,6 +1833,7 @@ static int svcxdr_byte_offset(struct svcxdr_ptr *from, struct svcxdr_ptr *to)
 static void svcxdr_reset(struct svcxdr_stream *xdr, struct svcxdr_ptr *to)
 {
 	WARN_ON_ONCE(svcxdr_ptr_misordered(&xdr->last_commit, to));
+	xdr->maxbytes += svcxdr_byte_offset(to, &xdr->ptr);
 	xdr->ptr = *to;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 4d9c82b..36b8c2c 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -54,6 +54,7 @@ struct svcxdr_stream {
 	struct svcxdr_ptr ptr;
 	struct xdr_buf *buf;
 	struct kvec *this_iov;
+	int maxbytes;
 };
 
 #define CURRENT_STATE_ID_FLAG (1<<0)
-- 
1.7.11.7

