Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:35738 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbbL1PVU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 10:21:20 -0500
Received: by mail-qk0-f177.google.com with SMTP id n135so75898193qka.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 07:21:20 -0800 (PST)
Date: Mon, 28 Dec 2015 10:21:16 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: dE <de.techno@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How do you get /proc/fs/nfs/exports to populate?
Message-ID: <20151228102116.4f687c6e@tlielax.poochiereds.net>
In-Reply-To: <568103AF.2010500@gmail.com>
References: <567E812E.2040204@gmail.com>
	<568103AF.2010500@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Dec 2015 15:11:03 +0530
dE <de.techno@gmail.com> wrote:

> Ok, got it.
> 
> It happens that those are made after a mount request.
> 

Well, there is no such thing as a mount request, per-se in NFSv4. What
happens is that you try to walk down to the point where you're mounting
and access that inode, and nfsd upcalls to mountd to see whether that's
allowed. That populates the cache.

You can't really run nfsd without mountd (or something equivalent)
since something needs to populate the exports table. If you're running
a v4-only server though, then mountd doesn't need to be network-facing
however.

> On 12/26/15 17:29, dE wrote:
> > Hi!
> >     I'm running nfs-utils without init script or systemd unit assistance.
> >
> > Since I'm using nfsv4, I'm eliminating the need to start mountd.
> >
> > Now if mountd is gone, who populates /proc/fs/nfs/exports?
> >
> > But even after running mountd (after an exportfs -a), this file still 
> > does not have any entries.
> >
> > Running rpc.nfsd with --
> >
> > rpc.nfsd -d --syslog --port 10000
> >
> > rpc.mountd runs without any arguments.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@poochiereds.net>
