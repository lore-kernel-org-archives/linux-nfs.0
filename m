From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] NFS: fix client hang due to race condition
Date: Wed, 6 Jul 2005 14:41:14 -0700
Message-ID: <20050706144114.37bd05be.akpm@osdl.org>
References: <20050706212744.GC20698@njw.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262555AbVGFVnG@vger.kernel.org>
To: Nick Wilson <njw@osdl.org>
In-Reply-To: <20050706212744.GC20698@njw.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Nick Wilson <njw@osdl.org> wrote:
>
> The flags field in struct nfs_inode is protected by the BKL. This patch
> fixes a couple places where the lock is not obtained before changing the
> flags.
> 

Yeah, nasty.  Well caught.

>  		}
>  		invalidate_inode_pages2(mapping);
> +		lock_kernel();
>  		nfsi->flags &= ~NFS_INO_INVALID_DATA;
> +		unlock_kernel();

Adding new lock_kernel()s is a bit retro.  We might want to use a per-inode
lock for this, or set_bit/clear_bit and friends.

If we choose to use a per-inode lock then it is legal to use inode.i_lock
(coz I said) as long as no locks are nested inside it.  i_lock's mandate is
"a general-purpose innermost per-inode lock".
