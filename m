From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Mon, 10 Dec 2007 11:24:48 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712101041330.12638@jlentini-linux.nane.netapp.com>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
  <1196902607.17724.2.camel@heimdal.trondhjem.org>
 <Pine.LNX.4.64.0712061255200.12638@jlentini-linux.nane.netapp.com>
 <1196969392.7990.9.camel@localhost.localdomain>
 <Pine.LNX.4.64.0712061803240.12638@jlentini-linux.nane.netapp.com>
 <1197067000.10831.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49971 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751AbXLJQZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 11:25:07 -0500
In-Reply-To: <1197067000.10831.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Fri, 7 Dec 2007, Trond Myklebust wrote:

> On Thu, 2007-12-06 at 18:11 -0500, James Lentini wrote:
> > What is your opinion on including the fix in 2.6.24? It addresses an 
> > observed problem for certain I/Os over NFS/RDMA. Would you like me to 
> > resend the patch with a revised description?
> 
> Please do.

rpcrdma_convert_iovs is passed an xdr_buf representing either an RPC 
request or an RPC reply. In the case of a request, several 
calculations and tests involving pos are unnecessary. In the case of a 
reply, several calculations and tests involving pos are incorrect (the 
code tests pos against the reply xdr buf's len field, which is always 
0 at the time rpcrdma_convert_iovs is executed). This change removes 
the incorrect/unnecessary calculations and tests involving pos.

This fixes an observed problem when reading certain file sizes over 
NFS/RDMA.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Signed-off-by: Tom Talpey <talpey@netapp.com>
Signed-off-by: James Lentini <jlentini@netapp.com>

---
 net/sunrpc/xprtrdma/rpc_rdma.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -92,7 +92,6 @@
 		seg[n].mr_page = NULL;
 		seg[n].mr_offset = xdrbuf->head[0].iov_base;
 		seg[n].mr_len = xdrbuf->head[0].iov_len;
-		pos += xdrbuf->head[0].iov_len;
 		++n;
 	}
 
@@ -104,7 +103,6 @@
 		seg[n].mr_len = min_t(u32,
 			PAGE_SIZE - xdrbuf->page_base, xdrbuf->page_len);
 		len = xdrbuf->page_len - seg[n].mr_len;
-		pos += len;
 		++n;
 		p = 1;
 		while (len > 0) {
@@ -119,20 +117,15 @@
 		}
 	}
 
-	if (pos < xdrbuf->len && xdrbuf->tail[0].iov_len) {
+	if (xdrbuf->tail[0].iov_len) {
 		if (n == nsegs)
 			return 0;
 		seg[n].mr_page = NULL;
 		seg[n].mr_offset = xdrbuf->tail[0].iov_base;
 		seg[n].mr_len = xdrbuf->tail[0].iov_len;
-		pos += xdrbuf->tail[0].iov_len;
 		++n;
 	}
 
-	if (pos < xdrbuf->len)
-		dprintk("RPC:       %s: marshaled only %d of %d\n",
-				__func__, pos, xdrbuf->len);
-
 	return n;
 }
 
