Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48613 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753421Ab0KSUEY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 15:04:24 -0500
Date: Fri, 19 Nov 2010 15:04:21 -0500
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Moazam Raja <moazam@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
Message-ID: <20101119200421.GA3143@fieldses.org>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
 <1290194699.3135.49.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290194699.3135.49.camel@heimdal.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 19, 2010 at 02:24:59PM -0500, Trond Myklebust wrote:
> On Thu, 2010-11-18 at 15:34 -0800, Moazam Raja wrote:
> > Hi all,
> > 
> > I'm currently exporting a ZFS filesystem on Solaris 11 Express as NFS.
> > I have a Linux client mounting that NFS v3 filesystem with the
> > proto=tcp option.
> > 
> > My question is, what's the safest and most reliable way to write data
> > to this NFS mount on a Linux client? Should my application code use
> > O_DIRECT, or O_SYNC? Or should I be doing a write() and a fsync()? I
> > want to make sure that data is not lost and is truly committed, while
> > keeping decent performance (of course).
> 
> Any one of the above methods will ensure that the data is synced to
> disk. In addition, NFS also guarantees that your data is fully synced to
> disk when taking/freeing POSIX locks, and when you close() the file.

Is the client still doing that in the presence of a write delegation, by
the way?

--b.

> 
> The choice of one method over the other depends on your application
> requirements. Not on your choice of underlying storage.
> 
> Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
