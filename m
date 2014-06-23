Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13209 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753720AbaFWNz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2014 09:55:27 -0400
Date: Mon, 23 Jun 2014 09:55:23 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] nfs: ensure cached data is correct before using
 delegation
Message-ID: <20140623135523.GI4510@tonberry.usersys.redhat.com>
References: <20140620125140.GH4510@tonberry.usersys.redhat.com>
 <1403286083-14345-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403286083-14345-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 20 Jun 2014, Trond Myklebust wrote:

> Hi Scott,
> 
> How about the following 2 extra patches on top of yours? Do they help
> with the performance regression?

Yes, they do.  Thanks!

-Scott

> 
> Cheers
>   Trond
> 
> Scott Mayhew (1):
>   nfs: Fix cache_validity check in nfs_write_pageuptodate()
> 
> Trond Myklebust (2):
>   NFS: Clear NFS_INO_REVAL_PAGECACHE when we update the file size
>   NFS: Don't mark the data cache as invalid if it has been flushed
> 
>  fs/nfs/inode.c | 76 +++++++++++++++++++++++++++++++---------------------------
>  fs/nfs/write.c |  4 +++-
>  2 files changed, 44 insertions(+), 36 deletions(-)
> 
> -- 
> 1.9.3
> 
