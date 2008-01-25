From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 034/112] SUNRPC: temp var should match return type of
	xdr_skb_read_actor
Date: Fri, 25 Jan 2008 11:37:33 -0500
Message-ID: <20080125163732.31887.85886.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756928AbYAYRAe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:34 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0Lmw010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:30 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The return type of xdr_skb_read_actor functions is size_t.  This fixes a
nit I unwittingly overlooked in commit dd456471.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/socklib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 97ac45f..a661a3a 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -72,7 +72,7 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 	struct page	**ppage = xdr->pages;
 	unsigned int	len, pglen = xdr->page_len;
 	ssize_t		copied = 0;
-	int		ret;
+	size_t		ret;
 
 	len = xdr->head[0].iov_len;
 	if (base < len) {
