Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47384 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753718AbbAGSYP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jan 2015 13:24:15 -0500
Date: Wed, 7 Jan 2015 13:24:12 -0500
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFS: Add READ_PLUS support
Message-ID: <20150107182412.GB7066@fieldses.org>
References: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1418855726-14262-1-git-send-email-Anna.Schumaker@Netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 17, 2014 at 05:35:23PM -0500, Anna Schumaker wrote:
> These patches add client support for the NFS v4.2 operation READ_PLUS.  This
> operation is triggered by doing any kind of read on a NFS v4.2 mounted
> filesystem.  `
> 
> The spec allows for the server to return multiple data and hole segments when
> reading a file.  Supporting this would requre a tedious amount of shifiting
> to make sure data is aligned properly, so I'm skipping this feature until I
> figure out a clean way of coding it.

So, what happens?  If that means we use just the first segment, and then
send another rpc for the rest, then this could lead to significant
performance regressions, couldn't it?

For example, if we synchronously read a 1-megabyte file consists of data
and holes alternating every 4k, then we've gone from waiting for a
single 1M read to waiting for 256 round trips.

I doubt that's a realistic example, but I don't know what is.  How do we
assure ourselves that this is an improvement?

Also, do we have good evidence that this does actually help
significantly when reading typical sparse files?  (Where I'm  not sure
how to define "typical"....)

--b.

> 
> These patches and the corresponding server changes are available in the
> [read_plus] branch of
> 
> 	git://git.linux-nfs.org/projects/anna/linux-nfs.git
> 
> Questions?  Comments?  Thoughts?
> 
> Anna
> 
> 
> Anna Schumaker (3):
>   NFS: Add basic support for READ_PLUS
>   SUNRPC: Add the ability to zero out data pages
>   NFS: Add support for reading NFS4_CONTENT_HOLE segments
> 
>  fs/nfs/nfs42xdr.c          | 159 +++++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4proc.c          |  30 ++++++++-
>  fs/nfs/nfs4xdr.c           |   1 +
>  include/linux/nfs4.h       |   1 +
>  include/linux/nfs_fs_sb.h  |   1 +
>  include/linux/nfs_xdr.h    |   2 +-
>  include/linux/sunrpc/xdr.h |   1 +
>  net/sunrpc/xdr.c           |  45 +++++++++++++
>  8 files changed, 237 insertions(+), 3 deletions(-)
> 
> -- 
> 2.1.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
