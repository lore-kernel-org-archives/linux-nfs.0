Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:54330 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbbAHPqR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 10:46:17 -0500
Date: Thu, 8 Jan 2015 10:32:39 -0500 (EST)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dai Ngo <dai.ngo@oracle.com>, nfsv4@ietf.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <317961239.8854831.1420731159072.JavaMail.root@uoguelph.ca>
In-Reply-To: <20150108011127.GA93138@kitty>
Subject: Re: [nfsv4] close(2) behavior when client holds a write delegation
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Haynes wrote:
> Adding NFSv4 WG ....
> 
> On Wed, Jan 07, 2015 at 04:05:43PM -0800, Trond Myklebust wrote:
> > On Wed, Jan 7, 2015 at 12:04 PM, Chuck Lever
> > <chuck.lever@oracle.com> wrote:
> > > Hi-
> > >
> > > Dai noticed that when a 3.17 Linux NFS client is granted a
> 
> Hi, is this new behavior for 3.17 or does it happen to prior
> versions as well?
> 
> > > write delegation, it neglects to flush dirty data synchronously
> > > with close(2). The data is flushed asynchronously, and close(2)
> > > completes immediately. Normally that’s OK. But Dai observed that:
> > >
> > > 1. If the server can’t accommodate the dirty data (eg ENOSPC or
> > >    EIO) the application is not notified, even via close(2) return
> > >    code.
> > >
> > > 2. If the server is down, the application does not hang, but it
> > >    can leave dirty data in the client’s page cache with no
> > >    indication to applications or administrators.
> > >
> > >    The disposition of that data remains unknown even if a umount
> > >    is attempted. While the server is down, the umount will hang
> > >    trying to flush that data without giving an indication of why.
> > >
> > > 3. If a shutdown is attempted while the server is down and there
> > >    is a pending flush, the shutdown will hang, even though there
> > >    are no running applications with open files.
> > >
> > > 4. The behavior is non-deterministic from the application’s
> > >    perspective. It occurs only if the server has granted a write
> > >    delegation for that file; otherwise close(2) behaves like it
> > >    does for NFSv2/3 or NFSv4 without a delegation present
> > >    (close(2) waits synchronously for the flush to complete).
> > >
> > > Should close(2) wait synchronously for a data flush even in the
> > > presence of a write delegation?
> > >
> > > It’s certainly reasonable for umount to try hard to flush pinned
> > > data, but that makes shutdown unreliable.
> > 
> > We should probably start paying more attention to the "space_limit"
> > field in the write delegation. That field is supposed to tell the
> > client precisely how much data it is allowed to cache on close().
> > 
> 
> Sure, but what does that mean?
> 
> Is the space_limit supposed to be on the file or the amount of data
> that
> can be cached by the client?
> 
My understanding of this was that the space limit was how much the
server guarantees that the client can grow the file by without failing,
due to ENOSPACE. Done via pre-allocation of blocks to the file on the
server or something like that.

I'll admit I can't remember what the FreeBSD server sets this to.
(Hopefully 0, because it doesn't do pre-allocation, but I should go take a look.;-)

For the other cases, such as crashed server or network partitioning,
there will never be a good solution. I think for these it is just a
design choice for the client implementor. (If FreeBSD, this tends to
end up controllable via a mount option. I think the FreeBSD client
uses the "nocto" option to decide if it will flush on close.)

rick

> Note that Spencer Dawkins effectively asked this question a couple of
> years ago:
> 
> | In this text:
> | 
> | 15.18.3.  RESULT
> | 
> |     nfs_space_limit4
> |               space_limit; /* Defines condition that
> |                               the client must check to
> |                               determine whether the
> |                               file needs to be flushed
> |                               to the server on close.  */
> | 
> | I'm no expert, but could I ask you to check whether this is the
> | right
> | description for this struct? nfs_space_limit4 looks like it's
> | either
> | a file size or a number of blocks, and I wasn't understanding how
> | that
> | was a "condition" or how the limit had anything to do with flushing
> | a
> | file to the server on close, so I'm wondering about a cut-and-paste
> | error.
> | 
> 
> Does any server set the space_limit?
> 
> And to what?
> 
> Note, it seems that OpenSolaris does set it to be NFS_LIMIT_SIZE and
> UINT64_MAX. Which means that it is effectively saying that the client
> is guaranteed a lot of space. :-)
> 
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
> 
