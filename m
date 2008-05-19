From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 02/04]  NFS/RDMA client stall patches
Date: Mon, 19 May 2008 13:51:05 +1000
Message-ID: <4830F929.7000307@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: talpey@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:35656 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755171AbYESDtB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 May 2008 23:49:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Drain both the sending and resend queues on disconnect.
This prevents the client from getting it's self into a
dead state when the server disconnects us.

Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
X-Sgi-Pv: 971446
 <http://bugworks/query.cgi/971446>---
Index: linux-2.6.25.3/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.25.3.orig/net/sunrpc/xprt.c
+++ linux-2.6.25.3/net/sunrpc/xprt.c
@@ -586,6 +586,8 @@ void xprt_disconnect_done(struct rpc_xpr
        spin_lock_bh(&xprt->transport_lock);
        xprt_clear_connected(xprt);
        xprt_wake_pending_tasks(xprt, -ENOTCONN);
+       rpc_wake_up_status(&xprt->resend, -ENOTCONN);
+       rpc_wake_up_status(&xprt->sending, -ENOTCONN);
        spin_unlock_bh(&xprt->transport_lock);
 }
 EXPORT_SYMBOL_GPL(xprt_disconnect_done);

