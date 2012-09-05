Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:40252 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751128Ab2IEHzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Sep 2012 03:55:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1T9ARz-000202-IJ
	for linux-nfs@vger.kernel.org; Wed, 05 Sep 2012 09:55:05 +0200
Received: from 59-124-179-67.HINET-IP.hinet.net ([59.124.179.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2012 09:55:03 +0200
Received: from yanpai.chen by 59-124-179-67.HINET-IP.hinet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2012 09:55:03 +0200
To: linux-nfs@vger.kernel.org
From: Yan-Pai Chen <yanpai.chen@gmail.com>
Subject: Re: [3.2.5] NFSv3 =?utf-8?b?Q0xPU0VfV0FJVA==?= hang
Date: Wed, 5 Sep 2012 07:49:27 +0000 (UTC)
Message-ID: <loom.20120905T093214-245@post.gmane.org>
References: <20110909194509.GB6195@hostway.ca> <1315610322.17611.112.camel@lade.trondhjem.org> <20111020190334.GA22772@hostway.ca> <20120301225524.GB27595@hostway.ca> <20120302002511.GA4495@hostway.ca> <20120302184918.GA20702@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simon Kirby <sim@...> writes:

> 
> Here's another CLOSE_WAIT hang, 3.2.5 client, 3.2.2 knfsd server, NFSv3.
> Not sure why these are all happening again now. This cluster seems to
> have a set of customers that are good at breaking things. ;)

Hi all,

I have the same problem in 3.3 kernel (client).
After applying the following modification as suggested by Dick in
http://www.spinics.net/lists/linux-nfs/msg32407.html, the problem
is just gone.

Does anyone know if they are related?
Thanks.

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index c64c0ef..f979e9f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1071,24 +1071,9 @@ void xprt_reserve(struct rpc_task *task)
 {
        struct rpc_xprt *xprt = task->tk_xprt;

-       task->tk_status = 0;
-       if (task->tk_rqstp != NULL)
-               return;
-
-       /* Note: grabbing the xprt_lock_write() here is not strictly needed,
-        * but ensures that we throttle new slot allocation if the transport
-        * is congested (e.g. if reconnecting or if we're out of socket
-        * write buffer space).
-        */
-       task->tk_timeout = 0;
-       task->tk_status = -EAGAIN;
-       if (!xprt_lock_write(xprt, task))
-               return;
-
        spin_lock(&xprt->reserve_lock);
        xprt_alloc_slot(task);
        spin_unlock(&xprt->reserve_lock);
-       xprt_release_write(xprt, task);
 }




