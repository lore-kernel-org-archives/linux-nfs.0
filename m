From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] async vs. sync. corrupted fs
Date: Tue, 20 May 2008 09:01:48 -0400
Message-ID: <1211288508.13163.13.camel@localhost>
References: <215ff4410805160355x25b8d055x9a0a246aa5875482@mail.gmail.com>
	<20080519145411.GC7622@fieldses.org>
	<215ff4410805200100o20fb83bcm9921127efef27ef9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: Chris Fanning <christopher.fanning@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:38798 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765828AbYETNCK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 09:02:10 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JyRTj-0000eE-Ru
	for linux-nfs@vger.kernel.org; Tue, 20 May 2008 23:02:07 +1000
In-Reply-To: <215ff4410805200100o20fb83bcm9921127efef27ef9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-20 at 10:00 +0200, Chris Fanning wrote:
> On Mon, May 19, 2008 at 4:54 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Fri, May 16, 2008 at 12:55:59PM +0200, Chris Fanning wrote:
> >> Hello all,
> >>
> >> Could someone help me out?
> >>
> >> I'm exporting a whole partition to a client.
> >> Using (rw,no_root_squash,sync, no_subtree_check), when I shutdown the
> >> server _before_ the client, the filesystem on the partion becomes
> >> corrupted.
> >
> > How do you know it becomes corrupted?
> >
> when I boot the server it reports the partition as corrupted and I
> need to perform an fsck.
> 
> >> When I user async, it doesn't happen.
> >
> > "async" the client-side mount option, or "async" the server-side export
> > option?
> server export.
> (rw,no_root_squash,sync, no_subtree_check)
> 
> client mount (fstab)
> nfs_home_server:/home  /home  nfs  tcp,rw  0  0
> 
> >
> >> Is this normal?
> >
> > No.
> I didn't think so ;)
> 
> Perhaps I can shed some more light on this. The client is diskless.
> The problems I'm reporting are with it's /home mount. It's root
> filessystem is also a nfs mount (but that is exported form a
> _different_ nfs server).
> I modify the nfsroot using chroot on the server.
> 
> I *think* this might be because of /proc mounted in the chroot get
> exported to the client? Any insight?
> 
> I've been trying all sorts of combinations yesterday (/proc mounted
> and not mounted in the chroot) and I haven't been able to reproduce
> the error. Strange becuase it definitely happened when was shutting
> down the nfs_home_server while everything else was up and running.
> 
> Perahps it is also worth noting that I'm booting the client with
> live-initramfs. /home gets mounted after the real
> filesystem(aufs,nfs+ram) comes up.
> Once the client has booted I can use /home. But it doesn't show up
> using 'df', and it is not present in /etc/mtab
> However it does show up in /proc/mounts
> nfs_home_server:/home /home nfs
> rw,vers=3,rsize=32768,wsize=23768,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,addr=192.168.2.2
> 0 0
> 
> Sorry for the convulated reply.
> Thanks.
> Chris.

The NFS client is incapable of physically corrupting the disk on the
server. The reason is simple: there are no NFS RPC calls that can access
the raw disk.

You should therefore rather be taking a long hard look at the server
side, to see if there might be anything going on there that can explain
it.
One issue to look at would be stack corruption: we know that some
combinations of soft raid + lvm + xfs can produce very deep call stacks,
which can lead to stack overflows which might be causing corruption.
You could also try running something like memtest86 to ensure that you
don't have faulty memory.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

