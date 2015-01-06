Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:6874 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752302AbbAFXgs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:36:48 -0500
Date: Wed, 7 Jan 2015 10:21:03 +1100
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 16/18] xfs: do not allocate blocks when converting
 unwritten extents
Message-ID: <20150106232103.GF31508@dastard>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-17-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1420561721-9150-17-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 06, 2015 at 05:28:39PM +0100, Christoph Hellwig wrote:
> Current xfs_bmapi_write always allocates blocks when it encounters a
> hole.  But for unwritten extent conversions we do not have the proper
> transaction reservations to do that, and should error out instead.
> 
> Currently this doesn't matter too much because the writeback path
> ensures that all blocks are properly allocated, but the pNFS block
> server code will accept unwritten extent conversions from clients,
> and in case of recovery from a crashed server we might get conversion
> requests for blocks whose allocation transaction hasn't made it to
> disk before the crash.  Also in general it is a good idea to be
> defensive here, especially for client initiated requests.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/xfs/libxfs/xfs_bmap.c | 15 +++++++++++++++
>  fs/xfs/xfs_iomap.c       | 17 ++++++-----------
>  2 files changed, 21 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/xfs/libxfs/xfs_bmap.c b/fs/xfs/libxfs/xfs_bmap.c
> index b5eb474..be08671 100644
> --- a/fs/xfs/libxfs/xfs_bmap.c
> +++ b/fs/xfs/libxfs/xfs_bmap.c
> @@ -4580,6 +4580,20 @@ xfs_bmapi_write(
>  		 * that we found, if any.
>  		 */
>  		if (inhole || wasdelay) {
> +			if ((flags & (XFS_BMAPI_CONVERT|XFS_BMAPI_PREALLOC)) ==
> +					XFS_BMAPI_CONVERT) {
> +				xfs_filblks_t count;
> +
> +				if (eof)
> +					bma.got.br_startoff = end;
> +
> +				count = XFS_FILBLKS_MIN(len,
> +						bma.got.br_startoff - bno);
> +				bno += count;
> +				len -= count;
> +				goto next;
> +			}

Please add a comment to the code explaining why this check is needed.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
