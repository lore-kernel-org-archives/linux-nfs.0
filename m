From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/23] SUNRPC: Don't flag empty RPCB_GETADDR reply as bogus
Date: Wed, 18 Mar 2009 20:45:28 -0400
Message-ID: <20090319004527.32404.75166.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:17042 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756856AbZCSAqa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:46:30 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In 2007, commit e65fe3976f594603ed7b1b4a99d3e9b867f573ea added
additional sanity checking to rpcb_decode_getaddr() to make sure we
were getting a reply that was long enough to be an actual universal
address.  If the uaddr string isn't long enough, the XDR decoder
returns EIO.

However, an empty string is a valid RPCB_GETADDR response if the
requested service isn't registered.  Moreover, "::.n.m" is also a
valid RPCB_GETADDR response for IPv6 addresses that is shorter
than rpcb_decode_getaddr()'s lower limit of 11.  So this sanity
check introduced a regression for rpcbind requests against IPv6
remotes.

So revert the lower bound check added by commit
e65fe3976f594603ed7b1b4a99d3e9b867f573ea, and add an explicit check
for an empty uaddr string, similar to libtirpc's rpcb_getaddr(3).

Pointed-out-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/rpcb_clnt.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 03ae007..2caa7ed 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -703,11 +703,16 @@ static int rpcb_decode_getaddr(struct rpc_rqst *req, __be32 *p,
 	*portp = 0;
 	addr_len = ntohl(*p++);
 
+	if (addr_len == 0) {
+		dprintk("RPC:       rpcb_decode_getaddr: "
+					"service is not registered\n");
+		return 0;
+	}
+
 	/*
-	 * Simple sanity check.  The smallest possible universal
-	 * address is an IPv4 address string containing 11 bytes.
+	 * Simple sanity check.
 	 */
-	if (addr_len < 11 || addr_len > RPCBIND_MAXUADDRLEN)
+	if (addr_len > RPCBIND_MAXUADDRLEN)
 		goto out_err;
 
 	/*

