Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512AbbKRUOa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Nov 2015 15:14:30 -0500
Subject: Re: [PATCH] Delete the unix socket only if we have created it
To: Laurent Bigonville <bigon@debian.org>, linux-nfs@vger.kernel.org
References: <1447111517-5448-1-git-send-email-bigon@debian.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <564CDC25.9020907@RedHat.com>
Date: Wed, 18 Nov 2015 15:14:29 -0500
MIME-Version: 1.0
In-Reply-To: <1447111517-5448-1-git-send-email-bigon@debian.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/09/2015 06:25 PM, Laurent Bigonville wrote:
> From: Laurent Bigonville <bigon@bigon.be>
> 
> If systemd has created the unix socket on our behalf, we shouldn't try
> to delete it.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=1279076
> 
> Signed-off-by: Laurent Bigonville <bigon@bigon.be>
Committed... 

steved.
> ---
>  src/rpcbind.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 045daa1..c4265cd 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -87,6 +87,7 @@ static inline void __nss_configure_lookup(const char *db, const char *s) {}
>  int debugging = 0;	/* Tell me what's going on */
>  int doabort = 0;	/* When debugging, do an abort on errors */
>  int dofork = 1;		/* fork? */
> +int createdsocket = 0;  /* Did I create the socket or systemd did it for me? */
>  
>  rpcblist_ptr list_rbl;	/* A list of version 3/4 rpcbind services */
>  
> @@ -445,6 +446,7 @@ init_transport(struct netconfig *nconf)
>  		memset(&sun, 0, sizeof sun);
>  		sun.sun_family = AF_LOCAL;
>  		unlink(_PATH_RPCBINDSOCK);
> +		createdsocket = 1; /* We are now in the process of creating the unix socket */
>  		strcpy(sun.sun_path, _PATH_RPCBINDSOCK);
>  		addrlen = SUN_LEN(&sun);
>  		sa = (struct sockaddr *)&sun;
> @@ -846,7 +848,8 @@ static void
>  terminate(int dummy /*__unused*/)
>  {
>  	close(rpcbindlockfd);
> -	unlink(_PATH_RPCBINDSOCK);
> +	if(createdsocket)
> +		unlink(_PATH_RPCBINDSOCK);
>  	unlink(RPCBINDDLOCK);
>  #ifdef WARMSTART
>  	write_warmstart();	/* Dump yourself */
> 
