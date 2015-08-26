Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50992 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859AbbHZNiA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2015 09:38:00 -0400
Date: Wed, 26 Aug 2015 15:37:23 +0200
From: David Sterba <dsterba@suse.cz>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-btrfs@vger.kernel.org
Subject: Re: [PATCH-RFC-RESEND 1/9] vfs: pull btrfs clone API to vfs layer
Message-ID: <20150826133723.GX10756@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
 <1440577010-122867-2-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1440577010-122867-2-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 04:16:42PM +0800, Peng Tao wrote:
> +struct file_clone_range {
> +	__s64 src_fd;
> +	__u64 src_offset;
> +	__u64 src_length;
> +	__u64 dest_offset;
> +};

Might be a good idea to add some spare bytes to the structure.

>  struct fstrim_range {
>  	__u64 start;
>  	__u64 len;
> @@ -159,6 +166,8 @@ struct inodes_stat_t {
>  #define FIFREEZE	_IOWR('X', 119, int)	/* Freeze */
>  #define FITHAW		_IOWR('X', 120, int)	/* Thaw */
>  #define FITRIM		_IOWR('X', 121, struct fstrim_range)	/* Trim */
> +#define FICLONE		_IOW(0x94, 9, int)	/* Clone */
> +#define FICLONERANGE	_IOW(0x94, 13, struct file_clone_range)	/* Clone range */

FICLONE is a special case of FICLONERANGE. The whole file clone had come
historically first and then was refined, I don't think this needs to be
copied to the generic API. A zeroed file_clone_range is simple to use
for that purpose.
