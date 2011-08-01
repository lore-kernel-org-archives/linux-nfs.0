Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32934 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827Ab1HALNj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2011 07:13:39 -0400
Subject: Re: [PATCH] nfs: Do not allow multiple mounts on same mountpoint
 when using -o noac
From: Sachin Prabhu <sprabhu@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Date: Mon, 01 Aug 2011 12:13:37 +0100
In-Reply-To: <1312050785.26265.2.camel@lade.trondhjem.org>
References: <1311947408.29400.40.camel@sprabhu.fab.redhat.com>
	 <1312050785.26265.2.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312197218.3800.2.camel@sprabhu.fab.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2011-07-30 at 14:33 -0400, Trond Myklebust wrote:
> On Fri, 2011-07-29 at 14:50 +0100, Sachin Prabhu wrote: 
> > When you normally attempt to mount a share twice on the same mountpoint,
> > a check in do_add_mount causes it to return an error
> > 
> > # mount localhost:/nfsv3 /mnt
> > # mount localhost:/nfsv3 /mnt
> > mount.nfs: /mnt is already mounted or busy
> > 
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
> > 
> > The patch checks for noac and assigns the sync flag before sget() is
> > called to obtain an already existing superblock structure.
> > 
> > 
> > Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
> 
> Hi Sachin,
> 
> This patch fails to apply with the error 'corrupt patch at line 6'. It
> looks to me as if your mailer has reformatted it for you.
> 
> Cheers
>   Trond

Hello Trond,

Sorry about that. I have re-posted the patch. 

Sachin Prabhu

