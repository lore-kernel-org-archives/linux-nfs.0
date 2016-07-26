Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwkm02.jp.fujitsu.com ([202.219.69.169]:54772 "EHLO
	mgwkm02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbcGZClm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jul 2016 22:41:42 -0400
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 313ABAC00A4
	for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2016 11:41:37 +0900 (JST)
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Subject: [PATCH v2] Prevent rqstp->rq_pages[RPCSVC_MAXPAGES] overrun
Message-ID: <28fb2e47-48ce-1af7-3135-15ca9b4e1726@jp.fujitsu.com>
Date: Tue, 26 Jul 2016 11:38:11 +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If over-"RPCSVC_MAXPAGES" pages are sent from file system through pipe_buffer,
nfsd_splice_actor() corrupts struct svc_rqst and results in kernel panic. It
actually occurred with a parallel distributed file system. It needs boundary
checking.

v2: Fix semicolon-missing bug.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>

---
 fs/nfsd/vfs.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6fbd81e..43393f3 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -811,12 +811,20 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 	size = sd->len;
 
 	if (rqstp->rq_res.page_len == 0) {
+		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
+			WARN_ON(1);
+			return -ENOMEM;
+		}
 		get_page(page);
 		put_page(*rqstp->rq_next_page);
 		*(rqstp->rq_next_page++) = page;
 		rqstp->rq_res.page_base = buf->offset;
 		rqstp->rq_res.page_len = size;
 	} else if (page != pp[-1]) {
+		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
+			WARN_ON(1);
+			return -ENOMEM;
+		}
 		get_page(page);
 		if (*rqstp->rq_next_page)
 			put_page(*rqstp->rq_next_page);
