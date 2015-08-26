Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:50538 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105AbbHZIBu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Aug 2015 04:01:50 -0400
Date: Wed, 26 Aug 2015 10:01:11 +0200
From: David Sterba <dsterba@suse.cz>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH RFC 02/11] vfs/btrfs: add .clone_range file operation
Message-ID: <20150826080111.GV10756@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-3-git-send-email-tao.peng@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1440516829-116041-3-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2015 at 11:33:40PM +0800, Peng Tao wrote:
> --- a/include/uapi/linux/btrfs.h
> +++ b/include/uapi/linux/btrfs.h
> @@ -316,12 +316,6 @@ struct btrfs_ioctl_search_args_v2 {
>  	__u64 buf[0];                       /* out - found items */
>  };
>  
> -struct btrfs_ioctl_clone_range_args {
> -  __s64 src_fd;
> -  __u64 src_offset, src_length;
> -  __u64 dest_offset;
> -};

For backward compatibility and not-breaking-builds reasons, do not
remove anything from this file.

> -
>  /* flags for the defrag range ioctl */
>  #define BTRFS_DEFRAG_RANGE_COMPRESS 1
>  #define BTRFS_DEFRAG_RANGE_START_IO 2
> @@ -548,7 +542,6 @@ static inline char *btrfs_err_str(enum btrfs_err_code err_code)
>  #define BTRFS_IOC_TRANS_END    _IO(BTRFS_IOCTL_MAGIC, 7)
>  #define BTRFS_IOC_SYNC         _IO(BTRFS_IOCTL_MAGIC, 8)
>  
> -#define BTRFS_IOC_CLONE        _IOW(BTRFS_IOCTL_MAGIC, 9, int)

The ioctl definition reuses the BTRFS_IOCTL_MAGIC (0x94), which is IMHO
wrong.

I'll comment more once the whole series is posted to fsdevel.
