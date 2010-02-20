From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] commit_metadata export operation v6
Date: Sat, 20 Feb 2010 18:38:04 -0500
Message-ID: <20100220233804.GA15015@fieldses.org>
References: <20100217200426.13409.32688.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43413 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756607Ab0BTXhQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Feb 2010 18:37:16 -0500
In-Reply-To: <20100217200426.13409.32688.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2010 at 02:05:05PM -0600, Ben Myers wrote:
> Hey Bruce,
> 
> Here is the latest version of the knfsd sync changes.  I have addressed the
> suggestions provided by Christoph, Trond, Dave, and Alex.
> 
> In this latest version I have fixed up the few nits in the nfsd patch that
> Christoph pointed out yesterday.  I also have simplified the xfs patch as
> suggested by Dave.

Thanks, applying.

(Do you the second (xfs) patch to go in through the nfsd tree as well,
or should that go in through xfs maintainers after the nfsd merge?)

--b.

> 
> Thanks,
> 	Ben
> ---
> 
> Ben Myers (2):
>       commit_metadata export operation replacing nfsd_sync_dir
>       xfs_export_operations.commit_metadata
> 
> 
>  fs/nfsd/nfs4recover.c         |    4 --
>  fs/nfsd/vfs.c                 |  106 ++++++++++++++++++++---------------------
>  fs/xfs/linux-2.6/xfs_export.c |   20 ++++++++
>  include/linux/exportfs.h      |    5 ++
>  4 files changed, 78 insertions(+), 57 deletions(-)
> 
> -- 
> Signature
