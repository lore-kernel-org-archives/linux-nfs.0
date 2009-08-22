From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v3 cached directory content out of sync
Date: Sat, 22 Aug 2009 13:38:44 -0400
Message-ID: <1250962724.8143.29.camel@heimdal.trondhjem.org>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35887 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932832AbZHVRip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Aug 2009 13:38:45 -0400
In-Reply-To: <d4098e2f0908211208j55dee16fy146ddb8de81d8722-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 21:08 +0200, Stefan Egli wrote:
> Hi Trond,
> 
> > It sounds like a bug. You don't mention which client you are using.
> 
> from uname:
> Linux (Ubuntu) 2.6.24-24-generic #1 SMP Tue Jun 30 19:54:36 UTC 2009
> x86_64 GNU/Linux
> 
> from mount:
> type nfs (ro,tcp,rsize=8192,wsize=8192,nfsvers=3,addr=192.168.XX.YY)
> 
> > You can tune the amount of time the client caches information by using
> > the 'ac*' mount options. In this case, you will want to adjust the
> > values of 'acdirmin' and 'acdirmax', probably setting them to zero.
> >
> > 'man 5 nfs' should provide you with more information.
> 
> Ok, so setting acdirmin=0 and acdirmax=0 would mean no directory
> content caching, right?

No directory _attribute_ caching, which again should mean that we check
if the parent directory mtime has changed on each lookup.

> >>  Question 5: any of this related to commit 37d9d76d8b3a2ac5817e1fa3263cfe
> >> 0fdb439e51: NFS: flush cached directory information slightly more readily. ?
> >
> > You client should be seeing mtime changes when you are creating new
> > files, so it shouldn't need to look at the ctime.
> >
> > The only time when ctime changes are relevant are if you use 'rsync' to
> > copy the files without specifying --omit-dir-times.
> > IOW: if something is explicitly setting the mtime on the directory.
> 
> Would have to check if that applies in our case. We're doing
> backup/restore from tivoli (tsm) - maybe that guy is to be blamed
> for not correctly updating mtime/ctimes ?

The restore will probably mess with the mtime, in which case you should
probably apply the above commit (applications cannot change the ctime).

Cheers
  Trond

