From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] commit_metadata export operation v5
Date: Tue, 16 Feb 2010 21:39:48 -0500
Message-ID: <20100217023948.GB32315@fieldses.org>
References: <20100216210026.5694.14423.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38215 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933473Ab0BQCjJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Feb 2010 21:39:09 -0500
In-Reply-To: <20100216210026.5694.14423.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 16, 2010 at 03:04:08PM -0600, Ben Myers wrote:
> Here is the latest version of the knfsd sync changes that I've been spamming
> you with.

Don't worry about spamming--it's good that people have lots of comments!

--b.

> I have addressed the latest suggestions provided by Christoph,
> Trond, Dave, and Alex.  This version of the commit_metadata export operation
> takes only one inode as suggested by Christoph and it turns out to be much
> cleaner this way.  Now we've gone back to committing all of the time in
> nfsd_create_setattr and don't bother with the added argument.  A couple extra
> comments to explain the commit ordering.
> 
> Thanks,
> Ben
> 
> ---
> 
> Ben Myers (2):
>       commit_metadata export operation replacing nfsd_sync_dir
>       xfs_export_operations.commit_metadata
> 
> 
>  fs/nfsd/nfs4recover.c         |    4 --
>  fs/nfsd/vfs.c                 |  109 ++++++++++++++++++++---------------------
>  fs/xfs/linux-2.6/xfs_export.c |   24 +++++++++
>  include/linux/exportfs.h      |    5 ++
>  4 files changed, 83 insertions(+), 59 deletions(-)
> 
> -- 
