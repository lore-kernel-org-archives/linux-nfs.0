Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:33577 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756733Ab2IGN5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Sep 2012 09:57:22 -0400
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id q87DvLOK032188
	(version=TLSv1/SSLv3 cipher=DHE-DSS-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 7 Sep 2012 15:57:21 +0200 (MEST)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.5/8.14.5) with ESMTP id q87DvLqk024796
	for <linux-nfs@vger.kernel.org>; Fri, 7 Sep 2012 15:57:21 +0200 (MEST)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick.streefland@altium.nl (Dick Streefland)
References: <20110909194509.GB6195@hostway.ca> <1315610322.17611.112.camel@lade.trondhjem.org> <20111020190334.GA22772@hostway.ca> <20120301225524.GB27595@hostway.ca> <20120302002511.GA4495@hostway.ca> <20120302184918.GA20702@hostway.ca> <loom.20120905T093214-245@post.gmane.org> <loom.20120905T093214-245@post.gmane.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908F86381@SACEXCMBX04-PRD.hq.netapp.com>
From: dick.streefland@altium.nl (Dick Streefland)
Subject: Re: [3.2.5] NFSv3 CLOSE_WAIT hang
Content-Type: text/plain; charset=us-ascii
Message-ID: <6cb9.5049fd40.b47c1@altium.nl>
Date: Fri, 07 Sep 2012 13:57:20 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
| Clearly the comment is misleading and should be removed. That write lock
| 
| _is_ needed in order to throttle slots on TCP.
| 
| As far as I know, kernel 3.3 is not in stable support any more, so I
| can't help that. Can you reproduce the problem on a 3.5 kernel or
| higher?

I can easily reproduce the hang on the latest kernel (eeea3ac912)
with my script (http://permalink.gmane.org/gmane.linux.nfs/51833).
With this change, it doesn't hang:

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a5a402a..6e739bf 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1083,20 +1083,9 @@ void xprt_reserve(struct rpc_task *task)
 	if (task->tk_rqstp != NULL)
 		return;
 
-	/* Note: grabbing the xprt_lock_write() here is not strictly needed,
-	 * but ensures that we throttle new slot allocation if the transport
-	 * is congested (e.g. if reconnecting or if we're out of socket
-	 * write buffer space).
-	 */
-	task->tk_timeout = 0;
-	task->tk_status = -EAGAIN;
-	if (!xprt_lock_write(xprt, task))
-		return;
-
 	spin_lock(&xprt->reserve_lock);
 	xprt_alloc_slot(task);
 	spin_unlock(&xprt->reserve_lock);
-	xprt_release_write(xprt, task);
 }
 
 static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)

-- 
Dick

