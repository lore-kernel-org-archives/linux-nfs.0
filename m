From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS hangs with 2.6.25/2.6.26 despite server being reachable
Date: Wed, 16 Jul 2008 15:15:53 -0400
Message-ID: <20080716191553.GG20298@fieldses.org>
References: <20080716054053.GE6159@zoy.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49199 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386AbYGPTPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2008 15:15:55 -0400
In-Reply-To: <20080716054053.GE6159-Y93EPB1FQwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2008 at 10:40:53PM -0700, Michel Lespinasse wrote:
> I'm getting frequent NFS hangs when running 2.6.25 or 2.6.26 on my
> NFS clients, while 2.6.24 seems to work fine.
> 
> Here are some details about my configuration:
> 
> * The NFS server is a linux host (x86-64) running 2.6.22.19;
> 
> * I have two diskless clients using different hardware, one is an old
>   AMD K7 with intel pro/100 adapter, the other is x86-64 with on-board
>   intel e1000e networking.
> 
> * The clients boot from a small initrd and mount their rootfs using
>   NFS3 over TCP. The initial mounting is done with "nfsmount -o ro,nolock"
>   from the klibc-utils package.
> 
> * /etc/fstab in the clients describe the nfs root as having the nolock,noatime
>   options. The boot scripts (unmodified from my debian etch distro)
>   remount the root using these. In the end, /proc/mounts shows the rootfs as
>   using the following options:
>   When running 2.6.24 on the client:
>     rw,noatime,vers=3,rsize=131072,wsize=131072,hard,nointr,
>     nolock,proto=tcp,timeo=7,retrans=3,sec=sys
>   When running 2.6.26 on the client:
>     rw,noatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,nointr,
>     nolock,proto=tcp,timeo=7,retrans=3,sec=sys,mountproto=udp
> 
> * I often run suspend-to-ram on the clients, if I know they'll be unused
>   for a few hours.
> 
> The above setup works just fine when running 2.6.24 on the clients.
> 
> When running 2.6.25 on the clients, the rootfs often hangs after a
> suspend/resume cycle. This happens most often if the clients had been
> suspended for a while (say overnight, rather than just during dinner).
> By 'hangs' I mean the the clients show all symptoms that would be expected
> if the server was gone, i.e. processes can't access the filesystem,
> load goes to high values, machine becomes basically unusable. However,
> the clients are still pingable from the NFS server host, so I believe
> the network itself is fine. After 5-10 minutes of this, everything comes
> back to normal without any intervention on my part.
> 
> When running 2.6.26 on the clients, the same behavior is observed except that
> it never goes back to normal. Actually, I could not find any way to fix the
> clients without rebooting them.
> 
> I'm not sure what's going on. My best guess would be that something times
> out (possibly the TCP connection itself ?) and that the NFS client in 2.6.25
> and above takes a very long time before giving up and establishing a new
> connection with the server ??? I'm not sure if that makes any sense, and I
> was not able to collect hard evidence of that so far...
> 
> Any ideas about what might be going wrong and/or what additional information
> I should try to collect about the hangs ?

A sysrq-T trace showing where the clients were hung might help.  (So,
"echo T >/proc/sysrq-trigger", then look at the logs.)

If it were possible to get it down to a simple test case, then we'd
probably learn something from a git-bisect to figure out exactly when
the problem was first introduced.

--b.
