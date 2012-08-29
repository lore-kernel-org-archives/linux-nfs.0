Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:10410 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab2H2MLV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Aug 2012 08:11:21 -0400
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id q7TCBJ27020373
	(version=TLSv1/SSLv3 cipher=DHE-DSS-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 29 Aug 2012 14:11:20 +0200 (MEST)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.5/8.14.5) with ESMTP id q7TCBJ4G024313
	for <linux-nfs@vger.kernel.org>; Wed, 29 Aug 2012 14:11:19 +0200 (MEST)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick.streefland@altium.nl (Dick Streefland)
References: <4d25.5034e746.eefd1@altium.nl> <4d25.5034e746.eefd1@altium.nl> <503609BF.60809@panasas.com> <2bd0.50368cb9.925d7@altium.nl>
From: dick.streefland@altium.nl (Dick Streefland)
Subject: Re: NFSv3 client hang on many simultanious reads
Content-Type: text/plain; charset=us-ascii
Message-ID: <6876.503e06e7.53da5@altium.nl>
Date: Wed, 29 Aug 2012 12:11:19 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

dick.streefland@altium.nl (Dick Streefland) wrote:
| Could this chunk cause a deadlock?
| 
| @@ -1001,10 +1004,25 @@ void xprt_reserve(struct rpc_task *task)
|  {
|  	struct rpc_xprt	*xprt = task->tk_xprt;
|  
| +	task->tk_status = 0;
| +	if (task->tk_rqstp != NULL)
| +		return;
| +
| +	/* Note: grabbing the xprt_lock_write() here is not strictly needed,
| +	 * but ensures that we throttle new slot allocation if the transport
| +	 * is congested (e.g. if reconnecting or if we're out of socket
| +	 * write buffer space).
| +	 */
| +	task->tk_timeout = 0;
| +	task->tk_status = -EAGAIN;
| +	if (!xprt_lock_write(xprt, task))
| +		return;
| +
|  	task->tk_status = -EIO;
|  	spin_lock(&xprt->reserve_lock);
|  	xprt_alloc_slot(task);
|  	spin_unlock(&xprt->reserve_lock);
| +	xprt_release_write(xprt, task);
|  }

I doublechecked, and this chunk does indeed cause the hang.
According to the comment, the lock is not strictly needed.
So how about simply reverting this?

-- 
Dick

