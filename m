From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH] 2.4.20 Direct IO patch for NFS. (Note: a trivial API change...)
Date: Mon, 30 Sep 2002 19:52:35 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020930195235.P18377@parcelfarce.linux.theplanet.co.uk>
References: <15768.39196.468797.249573@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>,
	Chuck Lever <cel@netapp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <15768.39196.468797.249573@charged.uio.no>; from trond.myklebust@fys.uio.no on Mon, Sep 30, 2002 at 08:34:04PM +0200
List-ID: <nfs.lists.sourceforge.net>

On Mon, Sep 30, 2002 at 08:34:04PM +0200, Trond Myklebust wrote:
> diff -u --recursive --new-file linux-2.4.20-pre8/fs/block_dev.c linux-2.4.20-directio/fs/block_dev.c
> --- linux-2.4.20-pre8/fs/block_dev.c	Sun May 12 02:26:03 2002
> +++ linux-2.4.20-directio/fs/block_dev.c	Mon Sep 30 18:24:45 2002
> @@ -131,8 +131,9 @@
>  	return 0;
>  }
>  
> -static int blkdev_direct_IO(int rw, struct inode * inode, struct kiobuf * iobuf, unsigned long blocknr, int blocksize)
> +static int blkdev_direct_IO(int rw, struct file * filp, struct kiobuf * iobuf, unsigned long blocknr, int blocksize)
>  {
> +	struct inode * inode = filp->f_dentry->d_inode->i_mapping->host;
>  	return generic_direct_IO(rw, inode, iobuf, blocknr, blocksize, blkdev_get_block);
>  }
>  

isn't that two dereferences more than necessary for a local filesystem?

-- 
Revolutions do not require corporate support.
