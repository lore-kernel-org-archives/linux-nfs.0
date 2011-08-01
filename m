Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583Ab1HAN31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2011 09:29:27 -0400
Subject: Re: [PATCH] nfs: Do not allow multiple mounts on same mountpoint
 when using -o noac
From: Sachin Prabhu <sprabhu@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: NFS <linux-nfs@vger.kernel.org>
Date: Mon, 01 Aug 2011 14:29:19 +0100
In-Reply-To: <20110801111936.GA16934@infradead.org>
References: <1311947408.29400.40.camel@sprabhu.fab.redhat.com>
	 <1312197013.3800.1.camel@sprabhu.fab.redhat.com>
	 <20110801111936.GA16934@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312205360.3800.6.camel@sprabhu.fab.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-08-01 at 07:19 -0400, Christoph Hellwig wrote:
> On Mon, Aug 01, 2011 at 12:10:12PM +0100, Sachin Prabhu wrote:
> > Do not allow multiple mounts on same mountpoint when using -o noac
> 
> The patch content really doesn't seem to match the subject line and
> most of the content.
> 
> > However when using the option 'noac', the user is able to mount the same
> > share on the same mountpoint multiple times. This happens because a
> > share mounted with the noac option is automatically assigned the 'sync'
> > flag MS_SYNCHRONOUS in nfs_initialise_sb(). This flag is set after the
> > check for already existing superblocks is done in sget(). The check for
> > the mount flags in nfs_compare_mount_options() does not take into
> > account the 'sync' flag applied later on in the code path. This means
> > that when using 'noac', a new superblock structure is assigned for every
> > new mount of the same share and multiple shares on the same mountpoint
> > are allowed.
> > 
> > ie. 
> > # mount -onoac localhost:/nfsv3 /mnt
> > can be run multiple times.
> 
> > The patch checks for noac and assigns the sync flag before sget() is
> > called to obtain an already existing superblock structure.
> 
> That's a fine fix, but the the whole patch subject and description
> focusses on a side effect rather than the underlying real problem.
> 
> The underlying issue is that youwant to share superblocks when
> having multiple mounts with -o noac, which requires assigning the
> sync flag ealier. 
> 
> The check in do_add_mount simply prevents mounts with the same
> superblock and root dentry at the same mountpoint, so it will fail for
> any two nfs mounts that might be from the same server but do not share
> the superblock due to different options.  I'm actually not sure we want
> to prevent that in general, and I can't see how it could be done easily.
> 

Yes. That is essentially what the problem is. 

The problem was reported by a user who noticed that passing the 'noac'
mount option allowed them to repeatedly mount the same share on the same
mount point. I just used the same perspective when reporting the issue
upstream.

Sachin Prabhu

