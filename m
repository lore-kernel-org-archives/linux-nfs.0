Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59039 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbaKUR3L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Nov 2014 12:29:11 -0500
Date: Fri, 21 Nov 2014 18:29:08 +0100
From: David Sterba <dsterba@suse.cz>
To: Omar Sandoval <osandov@osandov.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 4/5] btrfs: don't allow -C or +c chattrs on a swap file
Message-ID: <20141121172908.GE8568@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <cover.1416563833.git.osandov@osandov.com>
 <a422e8d7ce252474b998eeca3af5f1e2964c5c50.1416563833.git.osandov@osandov.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a422e8d7ce252474b998eeca3af5f1e2964c5c50.1416563833.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 21, 2014 at 02:08:30AM -0800, Omar Sandoval wrote:
> @@ -293,14 +293,21 @@ static int btrfs_ioctl_setflags(struct file *file, void __user *arg)
>  		}
>  	} else {

You can put the condition here, instead of shifting the nested block.

	} else if (!IS_SWAPFILE(inode)) {

>  		/*
> -		 * Revert back under same assuptions as above
> +		 * swap_activate checks that we don't swapon a copy-on-write
> +		 * file, but we must also make sure that it doesn't become
> +		 * copy-on-write.
>  		 */
> -		if (S_ISREG(mode)) {
> -			if (inode->i_size == 0)
> -				ip->flags &= ~(BTRFS_INODE_NODATACOW
> -				             | BTRFS_INODE_NODATASUM);
> -		} else {
> -			ip->flags &= ~BTRFS_INODE_NODATACOW;
> +		if (!IS_SWAPFILE(inode)) {
> +			/*
> +			 * Revert back under same assumptions as above
> +			 */
> +			if (S_ISREG(mode)) {
> +				if (inode->i_size == 0)
> +					ip->flags &= ~(BTRFS_INODE_NODATACOW |
> +						       BTRFS_INODE_NODATASUM);
> +			} else {
> +				ip->flags &= ~BTRFS_INODE_NODATACOW;
> +			}
>  		}
>  	}
