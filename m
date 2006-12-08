From: Neil Brown <neilb@suse.de>
Subject: Re: Let's get rid of those annoying "VFS is out of sync with
	lock manager" messages (includes proposed patch)
Date: Fri, 8 Dec 2006 14:36:27 +1100
Message-ID: <17784.56763.794504.185193@cse.unsw.edu.au>
References: <200612072208.16350.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsWXG-0008N6-Ec
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 19:36:30 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsWXH-0005Co-Br
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 19:36:31 -0800
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: message from Jesper Juhl on Thursday December 7
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday December 7, jesper.juhl@gmail.com wrote:
> 
> So I took Neils patch, made the change Trond suggested and the result is 
> below.
> 
> Comments?  Ok to merge?  

Yes, except that you need a changelog comment at the top.  Possibly
based very heavily on the text I wrote, but written to justify the
patch rather than to explain the bug.

NeilBrown

> 
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
> ---
> 
>  fs/nfs/file.c |   11 +++++++----
>  1 files changed, 7 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index cc93865..22572af 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -428,8 +428,8 @@ static int do_vfs_lock(struct file *file
>  			BUG();
>  	}
>  	if (res < 0)
> -		printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n",
> -				__FUNCTION__);
> +		dprintk("%s: VFS is out of sync with lock manager (res = %d)!\n",
> +				__FUNCTION__, res);
>  	return res;
>  }
>  
> @@ -479,10 +479,13 @@ static int do_setlk(struct file *filp, i
>  		 * we clean up any state on the server. We therefore
>  		 * record the lock call as having succeeded in order to
>  		 * ensure that locks_remove_posix() cleans it out when
> -		 * the process exits.
> +		 * the process exits. Make sure not to sleep if
> +		 * someone else holds the lock.
>  		 */
> -		if (status == -EINTR || status == -ERESTARTSYS)
> +		if (status == -EINTR || status == -ERESTARTSYS) {
> +			fl->fl_flags &= ~FL_SLEEP;
>  			do_vfs_lock(filp, fl);
> +		}
>  	} else
>  		status = do_vfs_lock(filp, fl);
>  	unlock_kernel();
> 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
