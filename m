From: "Frank A. Kingswood" <frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Sat, 26 Apr 2008 16:38:31 +0100
Message-ID: <48134C77.9090700@kingswood-consulting.co.uk>
References: <20080423214929.GA24387@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-8ByrlEUxsivZ+VzJOa5vwg@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:52626 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753985AbYDZPil (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Apr 2008 11:38:41 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JpmU4-0006Gb-8a
	for linux-nfs@vger.kernel.org; Sat, 26 Apr 2008 15:38:40 +0000
Received: from 88-97-16-53.dsl.zen.co.uk ([88.97.16.53])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2008 15:38:40 +0000
Received: from frank by 88-97-16-53.dsl.zen.co.uk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2008 15:38:40 +0000
In-Reply-To: <20080423214929.GA24387-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steinar H. Gunderson wrote:
> I've gotten a few bug reports lately that if UDP is blocked at the server,
> NFS mounts (even with -o tcp) fail. git bisect shows that the culprit is
> the change "Get rid of the "-i" option for mount.nfs[4] and always use the
> text-based mount(2) system call for kernel version 2.6.23 and later." -- in
> other words, the bug is specific to the text interface. Does anyone know why
> this would be the case?

The NFS client code (nfs-utils-1.1.2) tests for
   if (kernel_version > MAKE_VERSION(2, 6, 22))

yet the kernel patch for NFS did not go un until 2.6.25-rc2

> From: Linus Torvalds <torvalds@...>
> Subject: Linux 2.6.25-rc2
> Date: Feb 15, 5:23 pm 2008
> 
> Ok,
>  this kernel is a winner.
> 
> [...]
> 
> Chuck Lever (1):
>       NFS: Allow text-based mounts via compat_sys_mount
> 

So the test should at least be > MAKE_VERSION(2, 6, 24).

Frank

