From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd using up 60% CPU and won't let go
Date: Tue, 30 Sep 2008 08:25:54 -0400
Message-ID: <1222777554.7332.10.camel@localhost>
References: <48E17042.101@corky.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
To: Just Marc <marc-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:34606 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446AbYI3MZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2008 08:25:59 -0400
In-Reply-To: <48E17042.101-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-09-29 at 20:18 -0400, Just Marc wrote:
> Hi,
> 
>  > It's basically just a userspace NFS server, right?
> 
> Correct.
> 
>  > Could you work around the problem by mounting with -onolock?
> 
> That doesn't seem to help.
> 
>  >You might try running wireshark on the "lo" interface and seeing 
> whether there's any NLM traffic from lockd.
> 
> You guessed right.   There's a 12 megabytes per second of NLM traffic on lo.
> 
> unlock call requests and unlock replies saying permission denied, looks 
> like it just repeats forever in a tight loop.

As Bruce said, you need to mount with -onolock. Please unmount _all_
your cfs partitions, then mount them again with -onolock.

Note that -oremount,nolock will not work and for some kernels, mounting
while you have the same cfs partition mounted somewhere else will cause
the kernel to use the 'old' mount options.
See /proc/mounts to find out which mount options the kernel is actually
using.

Cheers
  Trond

