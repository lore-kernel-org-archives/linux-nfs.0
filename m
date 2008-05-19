From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 04/04]  NFS/RDMA client stall patches
Date: Mon, 19 May 2008 13:51:50 +1000
Message-ID: <4830F956.10602@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: talpey@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:35665 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755376AbYESDtn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 May 2008 23:49:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This trivial patch prevents the client from waiting
for 5 seconds on xprt reconnect if the xprt was
disconnected by the client with out being in an error
state.

Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
---

Index: linux-2.6.25.3/net/sunrpc/xprtrdma/verbs.c
===================================================================
--- linux-2.6.25.3.orig/net/sunrpc/xprtrdma/verbs.c
+++ linux-2.6.25.3/net/sunrpc/xprtrdma/verbs.c
@@ -848,8 +848,8 @@ rpcrdma_ep_disconnect(struct rpcrdma_ep
                        (ep->rep_connected == 1) ? "still " : "dis");
        } else {
                dprintk("RPC:       %s: rdma_disconnect %i\n", __func__, rc);
-               ep->rep_connected = rc;
        }
+       ep->rep_connected = rc;
        return rc;
 }

