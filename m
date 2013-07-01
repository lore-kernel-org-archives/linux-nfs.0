Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7577 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877Ab3GAQpu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 12:45:50 -0400
Message-ID: <51D1A8C0.509@RedHat.com>
Date: Mon, 01 Jul 2013 12:05:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/3] krb5_utils: remove redundant array size.
References: <20130603005219.20080.1927.stgit@notabene.brown> <20130603010021.20080.24416.stgit@notabene.brown>
In-Reply-To: <20130603010021.20080.24416.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/06/13 21:00, Neil Brown wrote:
> When initialising an array there is no need to specify the size as the
> size is taken from the initialiser.  Having the size there means that
> any change to the initialiser needs to change the size to and so is
> error-prone.
> 
> So just remove the size.
Committed....

steved.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  utils/gssd/krb5_util.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> index 6275dd8..9ef80f0 100644
> --- a/utils/gssd/krb5_util.c
> +++ b/utils/gssd/krb5_util.c
> @@ -1236,7 +1236,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
>  	krb5_keytab kt = NULL;;
>  	int retval = 0;
>  	char *k5err = NULL;
> -	const char *svcnames[5] = { "$", "root", "nfs", "host", NULL };
> +	const char *svcnames[] = { "$", "root", "nfs", "host", NULL };
>  
>  	/*
>  	 * If a specific service name was specified, use it.
> 
> 
