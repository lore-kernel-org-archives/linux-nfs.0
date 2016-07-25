Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:53645 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbcGYAhJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 20:37:09 -0400
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
	by yt-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 1B62AAC016A
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jul 2016 09:37:05 +0900 (JST)
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Subject: sunrpc: add bounds checking RPCSVC_MAXPAGES to svc_tcp_*_pages()
Message-ID: <4283d127-db43-338e-1122-b845bbd5d335@jp.fujitsu.com>
Date: Mon, 25 Jul 2016 09:35:57 +0900
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To prevent page* buffer overrun that breaks svc_rqst,
though I do not know sk_datalen can actually become so large.

Signed-off-by: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>

---
 net/sunrpc/svcsock.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index dadfec6..7532dfa 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -940,6 +940,9 @@ static unsigned int svc_tcp_restore_pages(struct svc_sock *svsk, struct svc_rqst
 		return 0;
 	len = svsk->sk_datalen;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	WARN_ON_ONCE(npages > RPCSVC_MAXPAGES);
+	if (npages > RPCSVC_MAXPAGES)
+		npages = RPCSVC_MAXPAGES;
 	for (i = 0; i < npages; i++) {
 		if (rqstp->rq_pages[i] != NULL)
 			put_page(rqstp->rq_pages[i]);
@@ -959,6 +962,9 @@ static void svc_tcp_save_pages(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		return;
 	len = svsk->sk_datalen;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	WARN_ON_ONCE(npages > RPCSVC_MAXPAGES);
+	if (npages > RPCSVC_MAXPAGES)
+		npages = RPCSVC_MAXPAGES;
 	for (i = 0; i < npages; i++) {
 		svsk->sk_pages[i] = rqstp->rq_pages[i];
 		rqstp->rq_pages[i] = NULL;
@@ -973,6 +979,9 @@ static void svc_tcp_clear_pages(struct svc_sock *svsk)
 		goto out;
 	len = svsk->sk_datalen;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	WARN_ON_ONCE(npages > RPCSVC_MAXPAGES);
+	if (npages > RPCSVC_MAXPAGES)
+		npages = RPCSVC_MAXPAGES;
 	for (i = 0; i < npages; i++) {
 		if (svsk->sk_pages[i] == NULL) {
 			WARN_ON_ONCE(1);
