Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754718Ab2DWSfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 14:35:10 -0400
Date: Mon, 23 Apr 2012 14:33:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu,
        viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com, malahal@us.ibm.com,
        bfields@fieldses.org, trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors
 from getattr call
Message-ID: <20120423143345.0388fcc5@tlielax.poochiereds.net>
In-Reply-To: <4F959A36.2080402@RedHat.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
	<1334749927-26138-1-git-send-email-jlayton@redhat.com>
	<20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com>
	<20120420171300.326d6e36@corrin.poochiereds.net>
	<4F956D5C.5050801@RedHat.com>
	<20120423113216.01992555@tlielax.poochiereds.net>
	<4F959A36.2080402@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Apr 2012 14:06:46 -0400
Steve Dickson <SteveD@redhat.com> wrote:


> > 
> > It'd be preferable to me if we didn't require a new error code, but if
> > different filesystems require different semantics from the VFS on an
> > ESTALE return, then that is one way to achieve it.
> > 
> Well I thought the use of the fs_flags to register for this type
> of semantics was a good one...
> 

The problem with that is that you don't have a way to know whether the
fs wants you to retry or not on a lookup. When you get back an ESTALE
on a lookup, then that's all you have. You don't know what fs was
involved. The ERETRYLOOKUP return solves that case nicely.

The problem with the ERETRYLOOKUP idea in other codepaths is that we'll
have a bunch of this kind of crap all over the place in the vfs code:

    return rc == -ERETRYLOOKUP ? -ESTALE : rc;

...in order to deal with those codepaths that might call down into the
fs, get that error back and then not actually be able to retry. For
instance, vfs_getattr is called from both vfs_fstat and vfs_fstatat.
The latter can and should retry on an ESTALE, but the former cannot.

That's a relatively simple case though. The real PITA will be stuff
like the inode_permission codepaths which branch out very widely. It'll
be hard to ensure that ERETRYLOOKUP doesn't leak out from there.

Another possibility is a hybrid approach. Have only the lookup codepath
return ERETRYLOOKUP to indicate that the fs wants to retry more than
once. Once you have a pointer to the sb, then you can look at the FS_*
flag and use that to indicate that you want to retry on an ESTALE
return.

-- 
Jeff Layton <jlayton@redhat.com>
