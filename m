Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:55799 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756737Ab0LRBIC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Dec 2010 20:08:02 -0500
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PTlHF-0006Av-AU
	for linux-nfs@vger.kernel.org; Fri, 17 Dec 2010 17:08:01 -0800
Date: Fri, 17 Dec 2010 17:08:01 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101218010801.GE28367@hostway.ca>
References: <20101208212505.GA18192@hostway.ca>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101208212505.GA18192@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 08, 2010 at 01:25:05PM -0800, Simon Kirby wrote:

> Possibly related to the flush-processes-taking-CPU issues I saw
> previously, I thought this was interesting.  I found a log-crunching box
> that does all of its work via NFS and spends most of the day sleeping. 
> It has been using a linearly-increasing amount of system time during the
> time where is sleeping.  munin graph:
> 
> http://0x.ca/sim/ref/2.6.36/cpu_logcrunch_nfs.png
>...
> Known 2.6.36 issue?  This did not occur on 2.6.35.4, according to the
> munin graphs.  I'll try 2.6.37-rc an see if it changes.

So, back on this topic,

It seems that system CPU from "flush" processes is still increasing
during and after periods of NFS activity, even with 2.6.37-rc5-git4:
        
        http://0x.ca/sim/ref/2.6.37/cpu_nfs.png

Something is definitely going on while NFS is active, and then keeps
happening in the idle periods.  top and perf top look the same as in
2.6.36.  No userland activity at all, but the kernel keeps doing stuff.

I could bisect this, but I have to wait a day for each build, unless I
can come up with a way to reproduce it more quickly.  The mount points
for which the flush processes are active are the two mount points where
the logs are read from, rotated, compressed, and unlinked, and where the
reports are written, running in parallel under an xargs -P 15.

I'm pretty sure the only syscalls that are reproducing this are read(),
readdir(), lstat(), write(), rename(), unlink(), and close().  There's
nothing special happening here...

Simon-
