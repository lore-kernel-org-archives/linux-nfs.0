Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:39077
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784Ab1HALTi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 07:19:38 -0400
Date: Mon, 1 Aug 2011 07:19:36 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Sachin Prabhu <sprabhu@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: Do not allow multiple mounts on same mountpoint
 when using -o noac
Message-ID: <20110801111936.GA16934@infradead.org>
References: <1311947408.29400.40.camel@sprabhu.fab.redhat.com>
 <1312197013.3800.1.camel@sprabhu.fab.redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1312197013.3800.1.camel@sprabhu.fab.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Aug 01, 2011 at 12:10:12PM +0100, Sachin Prabhu wrote:
> Do not allow multiple mounts on same mountpoint when using -o noac

The patch content really doesn't seem to match the subject line and
most of the content.

> However when using the option 'noac', the user is able to mount the same
> share on the same mountpoint multiple times. This happens because a
> share mounted with the noac option is automatically assigned the 'sync'
> flag MS_SYNCHRONOUS in nfs_initialise_sb(). This flag is set after the
> check for already existing superblocks is done in sget(). The check for
> the mount flags in nfs_compare_mount_options() does not take into
> account the 'sync' flag applied later on in the code path. This means
> that when using 'noac', a new superblock structure is assigned for every
> new mount of the same share and multiple shares on the same mountpoint
> are allowed.
> 
> ie. 
> # mount -onoac localhost:/nfsv3 /mnt
> can be run multiple times.

> The patch checks for noac and assigns the sync flag before sget() is
> called to obtain an already existing superblock structure.

That's a fine fix, but the the whole patch subject and description
focusses on a side effect rather than the underlying real problem.

The underlying issue is that youwant to share superblocks when
having multiple mounts with -o noac, which requires assigning the
sync flag ealier. 

The check in do_add_mount simply prevents mounts with the same
superblock and root dentry at the same mountpoint, so it will fail for
any two nfs mounts that might be from the same server but do not share
the superblock due to different options.  I'm actually not sure we want
to prevent that in general, and I can't see how it could be done easily.

