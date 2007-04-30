From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: mountd randomly crash and panic the server
Date: Tue, 01 May 2007 01:46:04 +0200
Message-ID: <46367FBC.6000007@oxeva.fr>
References: <461CFABE.9050301@barazer.net>	<46234130.5020502@oxeva.fr>	<17955.21572.383131.837268@notabene.brown>	<4623830D.7040108@oxeva.fr>
	<17956.8604.672536.126674@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HifZh-0000rz-JI
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 16:46:34 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HifZj-00074i-LX
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 16:46:36 -0700
In-Reply-To: <17956.8604.672536.126674@notabene.brown>
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

On 04/17/2007 3:23:40 +0200, Neil Brown <neilb@suse.de> wrote:

> 
> I did end up just hunting through the patches between 2.6.18 and
> 2.6.20 and I think I have found it (I had already looked at the code
> where the bug is, but didn't see it the first time :-().
> 
> Could you try this patch and report the results please?
> I'm very confident that the patch is correct and required, but I would
> like to also know that it fixes your problem.
> 

By the way, I patched the 2.6.20.7 kernel since you provided the patch, 
and haven't encountered any stability problem, except some CFQ scheduler 
  related kernel panics, which are, I suppose, not linked to the NFS 
problem (I still mention it because unrelated but linked problems like 
this sometimes happens)

Thanks for the patch !

Gabriel Barazer

> Thanks
> NeilBrown
> 
> ---------------------------------------------
> Use a spinlock to protect sk_info_authunix
> 
> sk_info_authunix is not being protected properly so the object that
> it points to can be cache_put twice, leading to corruption.
> 
> We borrow svsk->sk_defer_lock to provide the protection.  We should probably
> rename that lock to have a more generic name.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./net/sunrpc/svcauth_unix.c |   21 ++++++++++++++++-----
>  1 file changed, 16 insertions(+), 5 deletions(-)
> 
> diff .prev/net/sunrpc/svcauth_unix.c ./net/sunrpc/svcauth_unix.c
> --- .prev/net/sunrpc/svcauth_unix.c	2007-04-17 11:18:44.000000000 +1000
> +++ ./net/sunrpc/svcauth_unix.c	2007-04-17 11:19:18.000000000 +1000
> @@ -383,7 +383,10 @@ void svcauth_unix_purge(void)
>  static inline struct ip_map *
>  ip_map_cached_get(struct svc_rqst *rqstp)
>  {
> -	struct ip_map *ipm = rqstp->rq_sock->sk_info_authunix;
> +	struct ip_map *ipm;
> +	struct svc_sock *svsk = rqstp->rq_sock;
> +	spin_lock(&svsk->sk_defer_lock);
> +	ipm = svsk->sk_info_authunix;
>  	if (ipm != NULL) {
>  		if (!cache_valid(&ipm->h)) {
>  			/*
> @@ -391,12 +394,14 @@ ip_map_cached_get(struct svc_rqst *rqstp
>  			 * remembered, e.g. by a second mount from the
>  			 * same IP address.
>  			 */
> -			rqstp->rq_sock->sk_info_authunix = NULL;
> +			svsk->sk_info_authunix = NULL;
> +			spin_unlock(&svsk->sk_defer_lock);
>  			cache_put(&ipm->h, &ip_map_cache);
>  			return NULL;
>  		}
>  		cache_get(&ipm->h);
>  	}
> +	spin_unlock(&svsk->sk_defer_lock);
>  	return ipm;
>  }
>  
> @@ -405,9 +410,15 @@ ip_map_cached_put(struct svc_rqst *rqstp
>  {
>  	struct svc_sock *svsk = rqstp->rq_sock;
>  
> -	if (svsk->sk_sock->type == SOCK_STREAM && svsk->sk_info_authunix == NULL)
> -		svsk->sk_info_authunix = ipm;	/* newly cached, keep the reference */
> -	else
> +	spin_lock(&svsk->sk_defer_lock);
> +	if (svsk->sk_sock->type == SOCK_STREAM &&
> +	    svsk->sk_info_authunix == NULL) {
> +		/* newly cached, keep the reference */
> +		svsk->sk_info_authunix = ipm;
> +		ipm = NULL;
> +	}
> +	spin_unlock(&svsk->sk_defer_lock);
> +	if (ipm)
>  		cache_put(&ipm->h, &ip_map_cache);
>  }
>  

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
