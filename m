From: Peter Leckie <pleckie@sgi.com>
Subject: Re: [PATCH 01/04]  NFS/RDMA client stall patches
Date: Mon, 19 May 2008 13:50:52 +1000
Message-ID: <4830F91C.7070206@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: talpey@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:35652 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754624AbYESDsn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 May 2008 23:48:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't call __xprt_get_cong() if this is a retransmit.
This prevents __xprt_get_cong() from recursively
incrementing the congestion avoidance window for
retransmitted data.

Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
X-Sgi-Pv: 971446
 <http://bugworks/query.cgi/971446>---
Index: linux-2.6.25.3/net/sunrpc/xprt.c
===================================================================
--- linux-2.6.25.3.orig/net/sunrpc/xprt.c
+++ linux-2.6.25.3/net/sunrpc/xprt.c
@@ -224,7 +224,8 @@ int xprt_reserve_xprt_cong(struct rpc_ta
                        return 1;
                goto out_sleep;
        }
-       if (__xprt_get_cong(xprt, task)) {
+     /*If this is a retransmit don't increment cong*/
+       if ((req && req->rq_ntrans) ||__xprt_get_cong(xprt, task)) {
                xprt->snd_task = task;
                if (req) {
                        req->rq_bytes_sent = 0;


