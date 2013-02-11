Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:19858 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932605Ab3BKVdS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2013 16:33:18 -0500
Date: Tue, 12 Feb 2013 08:33:11 +1100
From: Dave Chinner <david@fromorbit.com>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: bfields@fieldses.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        chris.mason@fusionio.com, sage@inktank.com, miklos@szeredi.hu,
        konishi.ryusuke@lab.ntt.co.jp, mfasheh@suse.com, jlbec@ejvilplan.org,
        jack@suse.cz, bpm@sgi.com, elder@kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-nilfs@vger.kernel.org, reiserfs-devel@vger.kernel.org,
        linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>,
        Vivek Trivedi <t.vivek@samsung.com>
Subject: Re: [PATCH] fs: encode_fh: return FILEID_INVALID if invalid fid_type
Message-ID: <20130211213311.GE8257@dastard>
References: <1360571159-3666-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360571159-3666-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2013 at 05:25:58PM +0900, Namjae Jeon wrote:
> From: Namjae Jeon <namjae.jeon@samsung.com>
> 
> This patch is a follow up on below patch:
> 
> [PATCH] exportfs: add FILEID_INVALID to indicate invalid fid_type
> commit: 216b6cbdcbd86b1db0754d58886b466ae31f5a63 
....
> diff --git a/fs/xfs/xfs_export.c b/fs/xfs/xfs_export.c
> index a836118..3391800 100644
> --- a/fs/xfs/xfs_export.c
> +++ b/fs/xfs/xfs_export.c
> @@ -48,7 +48,7 @@ static int xfs_fileid_length(int fileid_type)
>  	case FILEID_INO32_GEN_PARENT | XFS_FILEID_TYPE_64FLAG:
>  		return 6;
>  	}
> -	return 255; /* invalid */
> +	return FILEID_INVALID; /* invalid */
>  }

I think you can drop the "/* invalid */" comment from there now as
it is redundant with this change.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
