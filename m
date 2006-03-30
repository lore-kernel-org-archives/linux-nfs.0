From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 11:12:31 -0500
Message-ID: <1143735152.8093.13.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0603300813270.18696@p34>
	 <1143728720.8074.41.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603300929340.18696@p34>
	 <1143729766.8074.49.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603300949000.18696@p34>
	 <1143731364.8074.53.camel@lade.trondhjem.org>
	 <Pine.LNX.4.64.0603301011160.18696@p34>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751029AbWC3QMk@vger.kernel.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
In-Reply-To: <Pine.LNX.4.64.0603301011160.18696@p34>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2006-03-30 at 10:13 -0500, Justin Piszcz wrote:
> On Thu, 30 Mar 2006, Trond Myklebust wrote:
> 
> > On Thu, 2006-03-30 at 09:50 -0500, Justin Piszcz wrote:
> >> I tried an exportfs -rv and it did not help.  Any other suggestions?
> >
> > Did the output from 'exportfs -rv' match with the contents
> > of /etc/exports? If so, did it also match with the contents
> > of /var/lib/nfs/xtab and /proc/fs/nfs/exports?
> >
> > Cheers,
> >  Trond
> >
> 
> In the /etc/exports file, I have an entry that looks like this:
> /path	specific-host-001(ro,root_squash,no_sync)
> /path	specific-host-002((ro,root_squash,no_sync)
> /path	*(ro,root_squash,no_sync)
> 
> So while there are only three entries, there are:
> 
> cat /proc/fs/nfs/exports | wc -> 566
> cat /var/lib/nfs/xtab | wc -> 564

Yes, but do they match? /var/lib/nfs/xtab and /proc/fs/nfs/exports are
supposed to differ in that 'exportfs' will fill in a few default
options. The question is whether there are entries for
specific-host-001, specific-host-002,...

> Entries per file.
> 
> Is this more of a kernel or nfsutils issue at this point?

More likely to be an nfs-utils issue.

Cheers,
  Trond
