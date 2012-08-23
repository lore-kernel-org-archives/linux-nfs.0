Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:16322 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab2HWUEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Aug 2012 16:04:11 -0400
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id q7NK49fl029988
	(version=TLSv1/SSLv3 cipher=DHE-DSS-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 22:04:09 +0200 (MEST)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.5/8.14.5) with ESMTP id q7NK49Ok006818
	for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 22:04:09 +0200 (MEST)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick.streefland@altium.nl (Dick Streefland)
References: <4d25.5034e746.eefd1@altium.nl> <4d25.5034e746.eefd1@altium.nl> <503609BF.60809@panasas.com>
From: dick.streefland@altium.nl (Dick Streefland)
Subject: Re: NFSv3 client hang on many simultanious reads
Content-Type: text/plain; charset=us-ascii
Message-ID: <2bd0.50368cb9.925d7@altium.nl>
Date: Thu, 23 Aug 2012 20:04:09 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh <bharrosh@panasas.com> wrote:
| It seems from above that the problem was introduced between 3.0
| and 3.1.
| 
| Would it be at all possible for you to do a "git bisect" between
| 3.0 and 3.1 to Identify the bad commit that introduced this problem?

It took a little while, in part because of a false positive, but here
is the bisect result:

43cedbf0e8dfb9c5610eb7985d5f21263e313802 is the first bad commit
commit 43cedbf0e8dfb9c5610eb7985d5f21263e313802
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Sun Jul 17 16:01:03 2011 -0400

    SUNRPC: Ensure that we grab the XPRT_LOCK before calling xprt_alloc_slot
    
    This throttles the allocation of new slots when the socket is busy
    reconnecting and/or is out of buffer space.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

:040000 040000 7d1ad2865000b8cb85d4d458137d88ba2894dbdc 726403505c0518b5275ff7d1bb0d21fdb1817461 M	include
:040000 040000 d8f92df1985a24e91217d09efd3f775768af0eab b1c251877291dffcbd2826506e956f722f14ff86 M	net

Could this chunk cause a deadlock?

@@ -1001,10 +1004,25 @@ void xprt_reserve(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt = task->tk_xprt;
 
+	task->tk_status = 0;
+	if (task->tk_rqstp != NULL)
+		return;
+
+	/* Note: grabbing the xprt_lock_write() here is not strictly needed,
+	 * but ensures that we throttle new slot allocation if the transport
+	 * is congested (e.g. if reconnecting or if we're out of socket
+	 * write buffer space).
+	 */
+	task->tk_timeout = 0;
+	task->tk_status = -EAGAIN;
+	if (!xprt_lock_write(xprt, task))
+		return;
+
 	task->tk_status = -EIO;
 	spin_lock(&xprt->reserve_lock);
 	xprt_alloc_slot(task);
 	spin_unlock(&xprt->reserve_lock);
+	xprt_release_write(xprt, task);
 }
 
-- 
Dick

