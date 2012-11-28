Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47810 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754885Ab2K1Txh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 14:53:37 -0500
Message-ID: <50B66BBF.4040404@RedHat.com>
Date: Wed, 28 Nov 2012 14:53:35 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] gssd: Remove insane sanity checks of the service
 name
References: <1353969081-17842-1-git-send-email-Trond.Myklebust@netapp.com> <1353969081-17842-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353969081-17842-2-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 26/11/12 17:31, Trond Myklebust wrote:
> Either we trust the info file, or we don't. The current
> 'checks' only work for the combination 'nfs', '100003' and
> a version number between 2 and 4.
> The problem is that the callback channel also wants to use
> 'nfs' in combination with a different program number and
> version number.
> 
> This patch throws the bogus checks out altogether and lets the
> kernel use whatever combination it wants....
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Committed... 

steved.

> ---
>  utils/gssd/gssd_proc.c | 13 +------------
>  1 file changed, 1 insertion(+), 12 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index b79e872..8c00201 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -250,21 +250,10 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  	if ((p = strstr(buf, "port")) != NULL)
>  		sscanf(p, "port: %127s\n", port);
>  
> -	/* check service, program, and version */
> -	if (memcmp(service, "nfs", 3) != 0)
> -		return -1;
> +	/* get program, and version numbers */
>  	*prog = atoi(program + 1); /* skip open paren */
>  	*vers = atoi(version);
>  
> -	if (strlen(service) == 3 ) {
> -		if ((*prog != 100003) || ((*vers != 2) && (*vers != 3) &&
> -		    (*vers != 4)))
> -			goto fail;
> -	} else if (memcmp(service, "nfs4_cb", 7) == 0) {
> -		if (*vers != 1)
> -			goto fail;
> -	}
> -
>  	if (!addrstr_to_sockaddr(addr, address, port))
>  		goto fail;
>  
> 
