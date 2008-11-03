From: "Brian J. Murrell" <brian-SquOHqY54CVWr29BmMi2cA@public.gmane.org>
Subject: Re: stuck/hung nfsv4 mounts
Date: Mon, 03 Nov 2008 15:09:18 -0500
Message-ID: <1225742958.2247.128.camel@brian-laptop>
References: <1225724721.2247.29.camel@brian-laptop>
	 <1225731544.6958.6.camel@heimdal.trondhjem.org>
	 <1225734631.2247.76.camel@brian-laptop>
	 <4d569c330811031158r26963e0w5bcf8331e0fb14b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.klug.on.ca ([205.189.48.131]:4901 "EHLO
	server.klug.on.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055AbYKCUJV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 15:09:21 -0500
Received: from linux.interlinx.bc.ca (d193-213-184.home3.cgocable.net [67.193.213.184])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 15E332805
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 15:09:20 -0500 (EST)
Received: from [10.75.22.172] (brian-laptop.ilinx [10.75.22.172])
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 1293F800A
	for <linux-nfs@vger.kernel.org>; Mon,  3 Nov 2008 15:09:19 -0500 (EST)
In-Reply-To: <4d569c330811031158r26963e0w5bcf8331e0fb14b7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-11-03 at 14:58 -0500, Kevin Coffman wrote:
> 
> These are all from librpcsecgss (from the -rrr).  I don't see an error here.

Good.

> You should have gotten output from gssd itself as well.  You might
> also look for any errors on the server from rpc.svcgssd.

Nothing.

> This looks fine.  (Assuming linux.interlinx.bc.ca is the NFS server
> and pc.interlinx.bc.ca is the client.)

Indeed, they both are as you assume.

So I've restarted both the rpc.svcgssd and rpc.gssd with -rrr -vvv on
the server and client (respectively) to see what more I can see but I
can't get the upcall to trigger.  I would have thought simply issuing a
mount would do that, but it seems not.  What exactly causes the upcall
to be made and what might prevent it from being made?

b.


