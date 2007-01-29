From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] 2.6.17.8 - do_vfs_lock: VFS is out of sync with lock
	manager!
Date: Mon, 29 Jan 2007 09:16:50 -0500
Message-ID: <1170080210.5757.6.camel@lade.trondhjem.org>
References: <9a8748490608080739w2e14e5ceg44a7bf0a3b475704@mail.gmail.com>
	 <17636.4462.975774.528003@cse.unsw.edu.au>
	 <9a8748490608170258s32df0272r60c8c540e5871485@mail.gmail.com>
	 <17641.10665.116168.867041@cse.unsw.edu.au>
	 <1156190098.6158.109.camel@localhost>
	 <17853.33116.113629.65031@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jesper Juhl <jesper.juhl@gmail.com>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751487AbXA2ORM@vger.kernel.org>
In-Reply-To: <17853.33116.113629.65031@notabene.brown>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Mon, 2007-01-29 at 16:08 +1100, Neil Brown wrote:
> On Monday August 21, trond.myklebust@fys.uio.no wrote:
> > 
> > Could we instead replace it with a dprintk() that returns the value of
> > "res"? That will keep it useful for debugging purposes.
> 
> (only 5 months later...)
> 
> Sure, how about this?
> 
> Thanks,
> NeilBrown

ACKed.

Thanks Neil!

Trond

> 
> Remove warning: VFS is out of sync with lock manager.
> 
> But keep it as a dprintk
> 
> The message can be generated in a quite normal situation:
>  If a 'lock' request is interrupted, then the lock client needs to
>   record that the server has the lock, incase it does.
>  When we come the unlock, the server might say it doesn't, even
>   though we think it does (or might) and this generates the message.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./fs/nfs/file.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff .prev/fs/nfs/file.c ./fs/nfs/file.c
> --- .prev/fs/nfs/file.c	2007-01-29 16:04:09.000000000 +1100
> +++ ./fs/nfs/file.c	2007-01-29 16:04:45.000000000 +1100
> @@ -434,8 +434,9 @@ static int do_vfs_lock(struct file *file
>  			BUG();
>  	}
>  	if (res < 0)
> -		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n",
> -				__FUNCTION__);
> +		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
> +			" - error %d!\n",
> +				__FUNCTION__, res);
>  	return res;
>  }
>  
