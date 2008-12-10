From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Fwd: 2.6.26.3 kernel - progressive slowdown over NFS
Date: Tue, 09 Dec 2008 20:06:45 -0500
Message-ID: <1228871206.30231.76.camel@heimdal.trondhjem.org>
References: <f4e12c70809091747rd58165ahaa6594a35752c6ef@mail.gmail.com>
	 <2c0942db0812091638o3d0fe68ek70744f6938949b25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:58357 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243AbYLJBGv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2008 20:06:51 -0500
In-Reply-To: <2c0942db0812091638o3d0fe68ek70744f6938949b25-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-12-09 at 16:38 -0800, Ray Lee wrote:
> [ adding netdev, linux-nfs to cc: -- rbl ]
> 
> Hi,
> 
> 
> We have a simple python program which keeps running a C loop to lstat
> NFS mounted directories.  We are seeing some weird behavior w.r.t. the
> run-time of this program on 2.6.26.3 kernel vs 2.6.24 kernel.
> 
> The run-time of the following code increases over time on the 2.6.26.3
> kernel, whereas remains flat (as expected) on the 2.6.24 kernel.
> [See attached graphs - B1.jpg and B2.jpg]  Once the 2.6.26.3 machine
> gets into this state, we need to restart the box to get back to
> reasonable run-times.  Is this a known issue ?

Could you try applying the following patch?

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git&a=commitdiff&h=23918b03060f6e572168fdde1798a905679d2e06

Trond

PS: note that your 2.6.26 config file has _very_ different memory models
and kernel debugging options enabled compared to your 2.6.24 kernel.
That may also affect performance.

