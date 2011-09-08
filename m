Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48656 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753772Ab1IHXVP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Sep 2011 19:21:15 -0400
Date: Thu, 8 Sep 2011 13:59:46 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFSD patches to support junctions
Message-ID: <20110908175946.GA16740@fieldses.org>
References: <20110902162210.32190.5880.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110902162210.32190.5880.stgit@matisse.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 02, 2011 at 12:38:13PM -0400, Chuck Lever wrote:
> Sometime soon we are going to have easy-to-install user space FedFS
> components.  Here are kernel patches needed to make server-side FedFS
> support work.  Please consider these for the 3.2 kernel.
> 
> The third patch introduces a potentially expensive check to see if
> a junction has been encountered during a mountpoint lookup.  An object
> is a junction iff it has the requisite set of extended attributes.
> However, reading an extended attribute is expensive on some file
> systems.
> 
> To mitigate the cost of this check, junctions always have their sticky
> bit set.  The expensive extended attribute part of the junction test
> is done only if the sticky bit is present.
> 
> Note that today junctions are directories, but someday symlinks might
> also act as junctions (for SMB2 support).  And very few files have the
> sticky bit set.  So we avoid doing a directory test here.
> 
> Also, junctions ostensibly have all zero mode bits to hide their local
> contents.  I don't think the kernel needs to be concerned about the
> permissions as long as the sticky bit is set.  This allows some
> flexibility in how junctions are represented.  However, Jeff thinks
> that having nfsd4_is_junction() also consider mode bits would make the
> expensive part of this test still less frequent.
> 
> Any thoughts about this?

Hm, right, a sticky bit set on a directory is a normal thing.  I thought
Trond's original idea was to check for the sticky bit and not
executable?  Which is a pointless combination so should be very rare.

On a typical system maybe directories with the sticky bit are normally
somewhat rare, but that's a question of policy and there could be cases
where it's common.

--b.

> 
> ---
> 
> Trond Myklebust (3):
>       NFSD: Add a cache for fs_locations information
>       NFSD: Remove the ex_pathname field from struct svc_export
>       NFSD: Cleanup for nfsd4_path()
> 
> 
>  fs/nfsd/export.c            |   15 +-----
>  fs/nfsd/nfs4xdr.c           |  106 ++++++++++++++++++++++++++++++++-----------
>  fs/nfsd/nfsd.h              |    7 +++
>  fs/nfsd/vfs.c               |   16 ++++++
>  include/linux/nfsd/export.h |    2 -
>  5 files changed, 104 insertions(+), 42 deletions(-)
> 
> -- 
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
