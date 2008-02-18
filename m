From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: 2.6.24: RPC: bad TCP reclen 0x00020090 (large)
Date: Mon, 18 Feb 2008 15:25:09 -0600
Message-ID: <1203369909.24272.44.camel@trinity.ogc.int>
References: <47B2F88D.7080300@msgid.tls.msk.ru>
	 <20080218045812.f1dc6f71.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michael Tokarev <mjt@tls.msk.ru>,
	Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35652 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760715AbYBRVQD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 16:16:03 -0500
In-Reply-To: <20080218045812.f1dc6f71.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-02-18 at 04:58 -0800, Andrew Morton wrote:
> (suitable cc added)
> 
> (regression)
> 
> On Wed, 13 Feb 2008 17:02:53 +0300 Michael Tokarev <mjt@tls.msk.ru> wrote:
> 
> > Hello!
> > 
> > After upgrading to 2.6.24 (from .23), we're seeing ALOT
> > of messages like in $subj in dmesg:
> > 
> > Feb 13 13:21:39 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
> > Feb 13 13:21:46 paltus kernel: printk: 3586 messages suppressed.
> > Feb 13 13:21:46 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
> > Feb 13 13:21:49 paltus kernel: printk: 371 messages suppressed.
> > Feb 13 13:21:49 paltus kernel: RPC: bad TCP reclen 0x00020090 (large)
> > Feb 13 13:21:55 paltus kernel: printk: 2979 messages suppressed.
> > ...
> > 
> > with linux NFS server.  The clients are all linux too, mostly 2.6.23
> > and some 2.6.22.
> > 
> > I found the "offending" piece of code in net/sunrpc/svcsock.c,
> > in routine svc_tcp_recvfrom() with condition being:
> > 
> >    if (svsk->sk_reclen > serv->sv_max_mesg) ...

The problem might be that the client is setting a bit in the RPC message
length field that is meant to be interpreted and masked off by the
server -- and we're not doing it yet. My bet is that 0x20000 is the bit
we're looking for. I'll poke around...

> > 
> > This happens after a server reboot.  At this point, client(s) are trying
> > to perform some NFS transaction and fail, and server starts generating
> > the above messages - till I do a umount followed by mount on all clients.
> > Before, such situation (nfs server reboot) were handled transparently,
> > ie, there was nothing to do, the mount continued working just fine when
> > the server comes back online.
> > 
> > Now, I'm not sure if it's really 2.6.24-specific problem or a userspace
> > problem.  Some time ago we also upgraded nfs-kernel-server (Debian)
> > package, and the remount-after-nfs-server-reboot problem started to
> > occur at THAT time (and it is something to worry about as well, I just
> > had no time to deal with it); but the dmesg spamming only appeared
> > with 2.6.24.
> > 
> > How to debug the issue further on from this point?
> > 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

