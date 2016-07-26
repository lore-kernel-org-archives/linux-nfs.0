Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:16249 "EHLO
	mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbcGZB4e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jul 2016 21:56:34 -0400
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id B7E38AC00E9
	for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2016 10:56:28 +0900 (JST)
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Subject: [PATCH] Prevent rqstp->rq_pages[RPCSVC_MAXPAGES] overrun
Message-ID: <5496b3fb-b6d1-edd1-13a4-500b776a079c@jp.fujitsu.com>
Date: Tue, 26 Jul 2016 10:54:28 +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If over-"RPCSVC_MAXPAGES" pages are sent from file system through pipe_buffer,
nfsd_splice_actor() corrupts struct svc_rqst and results in kernel panic. It
actually occurred with a parallel distributed file system. It needs boundary
checking.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>

---
 fs/nfsd/vfs.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6fbd81e..d6cb423 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -811,12 +811,20 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 	size = sd->len;
 
 	if (rqstp->rq_res.page_len == 0) {
+		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
+			WARN_ON(1);
+			return -ENOMEM
+		}
 		get_page(page);
 		put_page(*rqstp->rq_next_page);
 		*(rqstp->rq_next_page++) = page;
 		rqstp->rq_res.page_base = buf->offset;
 		rqstp->rq_res.page_len = size;
 	} else if (page != pp[-1]) {
+		if (rqstp->rq_next_page > &rqstp->rq_pages[RPCSVC_MAXPAGES-1]) {
+			WARN_ON(1);
+			return -ENOMEM
+		}
 		get_page(page);
 		if (*rqstp->rq_next_page)
 			put_page(*rqstp->rq_next_page);

