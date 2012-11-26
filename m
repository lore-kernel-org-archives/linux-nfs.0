Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35358 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139Ab2KZWhg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 17:37:36 -0500
Date: Mon, 26 Nov 2012 17:37:34 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] gssd: Remove insane sanity checks of the service name
Message-ID: <20121126223734.GD18186@fieldses.org>
References: <1353969081-17842-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353969081-17842-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1353969081-17842-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 26, 2012 at 05:31:21PM -0500, Trond Myklebust wrote:
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

ACK to both.--b.

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
> -- 
> 1.7.11.7
> 
