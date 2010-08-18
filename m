Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:60358 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992Ab0HRWQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 18:16:42 -0400
Subject: Re: [PATCH 1/4] sunrpc: don't shorten buflen twice in
 xdr_shrink_pagelen
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1282166814.8540.119.camel@heimdal.trondhjem.org>
References: <4C6C4565.1070603@panasas.com>
	 <1282164159-20283-1-git-send-email-bhalevy@panasas.com>
	 <1282166814.8540.119.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Aug 2010 18:16:37 -0400
Message-ID: <1282169797.8540.125.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-08-18 at 17:26 -0400, Trond Myklebust wrote:
> On Wed, 2010-08-18 at 23:42 +0300, Benny Halevy wrote:
> > On Jan. 14, 2009, 2:50 +0200, andros@netapp.com wrote:
> > > From: Andy Adamson <andros@netapp.com>
> > >
> > > The buflen is reset for all cases at the end of xdr_shrink_pagelen.
> > > The data left in the tail after xdr_read_pages is not processed when the
> > > buflen is incorrectly set.
> > 
> > Note that in this case we also lose (len - tail->iov_len)
> > bytes from the buffered data in pages.
> 
> We don't really need to do that. The amount of free space in the tail
> (as opposed to space occupied by data) can be calculated as:
> 
> buf->buflen - buf->head->iov_len - buf->page_len - buf->tail->iov_len;
> 
Something like the following:

---------------------------------------------------------------------------------------------
SUNRPC: Don't truncate tail data unnecessarily in xdr_shrink_pagelen

From: Trond Myklebust <Trond.Myklebust@netapp.com>

If we have unused buffer space, then we should make use of that rather
than unnecessarily truncating the message.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xdr.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)


diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 3317db3..3bbef7f 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -396,12 +396,21 @@ xdr_shrink_pagelen(struct xdr_buf *buf, size_t len)
 	struct kvec *tail;
 	size_t copy;
 	unsigned int pglen = buf->page_len;
+	unsigned int tailbuf_len;
 
 	tail = buf->tail;
 	BUG_ON (len > pglen);
 
+	tailbuf_len = buf->buflen - buf->head->iov_len - buf->page_len;
+
 	/* Shift the tail first */
-	if (tail->iov_len != 0) {
+	if (tailbuf_len != 0) {
+		unsigned int free_space = tailbuf_len - tail->iov_len;
+
+		if (len < free_space)
+			free_space = len;
+		tail->iov_len += free_space;
+
 		copy = len;
 		if (tail->iov_len > len) {
 			char *p = (char *)tail->iov_base + len;


