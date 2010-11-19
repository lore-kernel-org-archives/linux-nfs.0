Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38865 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755339Ab0KSV0l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 16:26:41 -0500
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Moazam Raja <moazam@gmail.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20101119200421.GA3143@fieldses.org>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
	 <1290194699.3135.49.camel@heimdal.trondhjem.org>
	 <20101119200421.GA3143@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Nov 2010 16:26:35 -0500
Message-ID: <1290201995.3135.63.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-11-19 at 15:04 -0500, J. Bruce Fields wrote:
> On Fri, Nov 19, 2010 at 02:24:59PM -0500, Trond Myklebust wrote:
> > On Thu, 2010-11-18 at 15:34 -0800, Moazam Raja wrote:
> > > Hi all,
> > > 
> > > I'm currently exporting a ZFS filesystem on Solaris 11 Express as NFS.
> > > I have a Linux client mounting that NFS v3 filesystem with the
> > > proto=tcp option.
> > > 
> > > My question is, what's the safest and most reliable way to write data
> > > to this NFS mount on a Linux client? Should my application code use
> > > O_DIRECT, or O_SYNC? Or should I be doing a write() and a fsync()? I
> > > want to make sure that data is not lost and is truly committed, while
> > > keeping decent performance (of course).
> > 
> > Any one of the above methods will ensure that the data is synced to
> > disk. In addition, NFS also guarantees that your data is fully synced to
> > disk when taking/freeing POSIX locks, and when you close() the file.
> 
> Is the client still doing that in the presence of a write delegation, by
> the way?

If the application requests O_DIRECT/O_SYNC or calls fsync(), we are
required by POSIX to ensure the data is safe on disk. The presence of an
NFS delegation does not change that requirement.

We could potentially relax the sync-to-disk requirements when locking
and closing the file since those are only about ensuring close-to-open
cache consistency requirements (which is also ensured by the delegation)
but we do not do so today.

Cheers
  Trond

