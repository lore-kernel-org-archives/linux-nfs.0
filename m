From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [GIT] NFS client fixes for 2.6.23++
Date: Sat, 20 Oct 2007 13:24:05 -0400
Message-ID: <1192901045.7440.11.camel@heimdal.trondhjem.org>
References: <1192828993.7466.18.camel@heimdal.trondhjem.org>
	<20071020014149.GA19871@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linus Torvalds <torvalds@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjI3B-0007GS-8d
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 10:23:49 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IjI3G-0004F3-He
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 10:23:54 -0700
In-Reply-To: <20071020014149.GA19871@lixom.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Fri, 2007-10-19 at 20:41 -0500, Olof Johansson wrote:
> nfs: Fix build break with CONFIG_NFS_V4=n
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

....with apologies.

> ---
> 
> 
> On Fri, Oct 19, 2007 at 05:23:13PM -0400, Trond Myklebust wrote:
> > Hi Linus,
> > 
> > Please pull from the repository at
> > 
> >    git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git
> > 
> > This will update the following files through the appended changesets.
> > 
> [...]
> > @@ -522,8 +522,12 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
> >  		return;
> >  	list_del(&ctx->list);
> >  	spin_unlock(&inode->i_lock);
> > -	if (ctx->state != NULL)
> > -		nfs4_close_state(&ctx->path, ctx->state, ctx->mode);
> > +	if (ctx->state != NULL) {
> > +		if (wait)
> > +			nfs4_close_sync(&ctx->path, ctx->state, ctx->mode);
> > +		else
> > +			nfs4_close_state(&ctx->path, ctx->state, ctx->mode);
> > +	}
> >  	if (ctx->cred != NULL)
> >  		put_rpccred(ctx->cred);
> >  	dput(ctx->path.dentry);
> 
> This gives me build errors on most PPC defconfigs, which don't enable NFSv4.
> 
> This seems sufficient to fix it.
> 
> 
> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> index a4e3b96..b35069a 100644
> --- a/fs/nfs/nfs4_fs.h
> +++ b/fs/nfs/nfs4_fs.h
> @@ -236,6 +236,7 @@ extern struct svc_version nfs4_callback_version1;
>  #else
>  
>  #define nfs4_close_state(a, b, c) do { } while (0)
> +#define nfs4_close_sync(a, b, c) do { } while (0)
>  
>  #endif /* CONFIG_NFS_V4 */
>  #endif /* __LINUX_FS_NFS_NFS4_FS.H */
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
