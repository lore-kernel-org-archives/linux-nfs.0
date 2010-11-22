Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:58881 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753438Ab0KVSE4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Nov 2010 13:04:56 -0500
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Kums <kumaran.rajaram@gmail.com>
Cc: Moazam Raja <moazam@gmail.com>, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTikFfdMWs0b4V1doVYUx1T96+ef8-dMUZf3v8cW9@mail.gmail.com>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
	 <1290194699.3135.49.camel@heimdal.trondhjem.org>
	 <AANLkTi=AV20AsUKOGfVg6M92T8LfPLuuyrG_hQESw_RU@mail.gmail.com>
	 <1290297244.9269.9.camel@heimdal.trondhjem.org>
	 <AANLkTikFfdMWs0b4V1doVYUx1T96+ef8-dMUZf3v8cW9@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Nov 2010 13:04:51 -0500
Message-ID: <1290449091.2909.0.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-22 at 10:45 -0700, Kums wrote:
> On Sat, Nov 20, 2010 at 4:54 PM, Trond Myklebust <trond.myklebust@fys.uio.no
> > wrote:
> > If so, then that would be
> > a much stronger guarantee than POSIX and local disk give you, and it
> > will seriously impact I/O performance (whether you use NFS, local disk
> > or whatever).
> >
> 
> Yes, I understand. Iam just throwing out a suggestion to see if "-o sync"
> nfs mount + sync exportfs option can be alternative to using O_SYNC or
> O_DIRECT in the application (to guarantee everything written by application
> hits the disk).

mount -osync under NFS works exactly the same as under any other
filesystem, so yes...

Trond


