Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39019 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758788Ab2DJNjQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Apr 2012 09:39:16 -0400
Date: Tue, 10 Apr 2012 09:39:13 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Message-ID: <20120410133913.GF18465@fieldses.org>
References: <4F82F16C.7030303@parallels.com>
 <20120409112739.6a823d6f@corrin.poochiereds.net>
 <4F830999.5000504@parallels.com>
 <20120409161114.GB6482@fieldses.org>
 <1333988226.2688.76.camel@lade.trondhjem.org>
 <20120409162107.GC6482@fieldses.org>
 <1333989216.2688.87.camel@lade.trondhjem.org>
 <4F8314CF.70302@parallels.com>
 <20120409181138.GA9581@fieldses.org>
 <4F8411CC.2070105@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F8411CC.2070105@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 02:56:12PM +0400, Stanislav Kinsbursky wrote:
> 09.04.2012 22:11, bfields@fieldses.org пишет:
> >Since NFSv4 doesn't have a separate MOUNT protocol, clients need to be
> >able to do readdir's and lookups to get to exported filesystems.  We
> >support this in the Linux server by exporting all the filesystems from
> >"/" on down that must be traversed to reach a given filesystem.  These
> >exports are very restricted (e.g. only parents of exports are visible).
> >
> 
> Ok, thanks for explanation.
> So, this pseudoroot looks like a part of NFS server internal
> implementation, but not a part of a standard. That's good.
> 
> >>Why does it prevents implementing of check for "superblock-network
> >>namespace" pair on NFS server start and forbid (?) it in case of
> >>this pair is shared already in other namespace? I.e. maybe this
> >>pseudoroot can be an exclusion from this rule?
> >
> >That might work.  It's read-only and consists only of directories, so
> >the grace period doesn't affect it.
> >
> 
> I've just realized, that this per-sb grace period won't work.
> I.e., it's a valid situation, when two or more containers located on
> the same filesystem, but shares different parts of it. And there is
> not conflict here at all.

Well, there may be some conflict in that a file could be hardlinked into
both subtrees, and that file could be locked from users of either
export.

--b.

> I don't see any clear and simple way how to handle such races,
> because otherwise we have to tie network namespace and filesystem
> namespace.
> I.e. there will be required some way to define, was passed export
> directory shared already somewhere else or not.
> 
> Realistic solution - since export check should be done in initial
> file system environment (most probably container will have it's own
> root), then we to pass this data to some kernel thread/userspace
> daemon in initial file system environment somehow (sockets doesn't
> suits here... Shared memory?).
> 
> Improbable solution - patching VFS layer...
> 
> -- 
> Best regards,
> Stanislav Kinsbursky
