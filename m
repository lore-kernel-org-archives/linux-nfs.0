Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:53237 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755617Ab0KTXyN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Nov 2010 18:54:13 -0500
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Kums <kumaran.rajaram@gmail.com>
Cc: Moazam Raja <moazam@gmail.com>, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTi=AV20AsUKOGfVg6M92T8LfPLuuyrG_hQESw_RU@mail.gmail.com>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
	 <1290194699.3135.49.camel@heimdal.trondhjem.org>
	 <AANLkTi=AV20AsUKOGfVg6M92T8LfPLuuyrG_hQESw_RU@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 20 Nov 2010 18:54:04 -0500
Message-ID: <1290297244.9269.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-11-20 at 09:12 -0700, Kums wrote:
> On Fri, Nov 19, 2010 at 12:24 PM, Trond Myklebust <
> trond.myklebust@fys.uio.no> wrote:
> 
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
> > --
> >
> 
> Instead of enforcing at the application side with O_DIRECT/O_SYNC, what if
> we mount nfs client with -o sync option as well as exportfs the nfs server
> with sync option? This way the data from all the application can be
> guaranteed to be safe?

???????

What is your definition of 'safe' here? Do you mean 'everything written
by my application is guaranteed to hit disk'? If so, then that would be
a much stronger guarantee than POSIX and local disk give you, and it
will seriously impact I/O performance (whether you use NFS, local disk
or whatever).

Why do you need this kind of guarantee in the first place? What
applications are you running?

Trond

