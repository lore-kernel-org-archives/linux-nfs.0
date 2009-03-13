Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:37110 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903AbZCMVko (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Mar 2009 17:40:44 -0400
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: David Rees <drees76@gmail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
	 <1236978608.7265.41.camel@heimdal.trondhjem.org>
	 <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>
Content-Type: text/plain
Date: Fri, 13 Mar 2009 17:40:38 -0400
Message-Id: <1236980438.7265.47.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-03-13 at 14:32 -0700, David Rees wrote:
> On Fri, Mar 13, 2009 at 2:10 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Fri, 2009-03-13 at 13:36 -0700, David Rees wrote:
> >> Steps to reproduce:
> >>
> >> 1. Write a big file to the same partition that is exported on the server:
> >> dd if=/dev/zero of=/opt/export/bigfile bs=1M count=5000 conv=fdatasync
> >> 2. Write a small file to the same partition from the client:
> >> dd if=/dev/zero of=/opt/export/bigfile bs=16k count=8 conf=fdatasync
> >
> > You don't need conv=fdatasync when writing to NFS. The close-to-open
> > cache consistency automatically guarantees fdatasync on close().
> 
> Yeah, I didn't think I did, but I added it for good measure since I
> needed it to simulate load directly on the server.  It doesn't seem to
> affect the numbers significantly either way.
> 
> >> I am seeing slightly less than 2kBps (yes, 1000-2000 bytes per second)
> >> from the client while this is happening.
> >
> > UDP transport, or TCP? If the former, then definitely switch to the
> > latter, since you're probably pounding the server with unnecessary RPC
> > retries while it is busy with the I/O.
> >
> > For the same reason, also make sure that -otimeo=600 (the default for
> > TCP).
> 
> Yes, both set that way by default.  From /proc/mounts on the client:
> 
> rw,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.2.1.13,mountvers=3,mountproto=tcp,addr=10.2.1.13

That all looks correct.

Just a few more random thoughts:

Do you perhaps see a lot of sockets connected to port 2049 and that are
not in the TCP_ESTABLISHED state when you do 'netstat -nt' on the
server?
What is the ratio of 'write' to 'commit' operations when you look at the
'nfsstat -s' output (also on the server)?

Trond

