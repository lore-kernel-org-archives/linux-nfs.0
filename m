Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:35626 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755991Ab0KSTZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Nov 2010 14:25:05 -0500
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Moazam Raja <moazam@gmail.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Nov 2010 14:24:59 -0500
Message-ID: <1290194699.3135.49.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-11-18 at 15:34 -0800, Moazam Raja wrote:
> Hi all,
> 
> I'm currently exporting a ZFS filesystem on Solaris 11 Express as NFS.
> I have a Linux client mounting that NFS v3 filesystem with the
> proto=tcp option.
> 
> My question is, what's the safest and most reliable way to write data
> to this NFS mount on a Linux client? Should my application code use
> O_DIRECT, or O_SYNC? Or should I be doing a write() and a fsync()? I
> want to make sure that data is not lost and is truly committed, while
> keeping decent performance (of course).

Any one of the above methods will ensure that the data is synced to
disk. In addition, NFS also guarantees that your data is fully synced to
disk when taking/freeing POSIX locks, and when you close() the file.

The choice of one method over the other depends on your application
requirements. Not on your choice of underlying storage.

Trond

