Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47010 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751563AbdF3PHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 11:07:31 -0400
Subject: Re: [PATCH nfs-utils v2 10/12] exportfs: add support for "vsock:"
 exports(5) syntax
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-11-stefanha@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <3d149aad-1bbd-4fef-15fd-7ffd6ab85dd1@RedHat.com>
Date: Fri, 30 Jun 2017 11:07:27 -0400
MIME-Version: 1.0
In-Reply-To: <20170630132120.31578-11-stefanha@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> Allow exports to be restricted to AF_VSOCK clients:
> 
>   # exportfs vsock:3:/export
> 
> and:
> 
>   # cat /etc/exports
>   /export	vsock:*(rw,no_root_squash,insecure,subtree_check)
Again it would be nice to use hostnames or address types
instead of a qualifier like 'vsock'... But if we do end
up going down this road, this definitely has to be
documented in the man page. 

steved.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  utils/exportfs/exportfs.c | 32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 3ded733..6bf67f1 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -299,6 +299,20 @@ static int exportfs_generic(char *arg, char *options, int verbose)
>  	return 0;
>  }
>  
> +static int exportfs_vsock(char *arg, char *options, int verbose)
> +{
> +	char *path;
> +
> +	if ((path = strchr(arg + strlen("vsock:"), ':')) != NULL)
> +		*path++ = '\0';
> +
> +	if (!path || *path != '/')
> +		return 1;
> +
> +	exportfs_parsed(arg, path, options, verbose);
> +	return 0;
> +}
> +
>  static int exportfs_ipv6(char *arg, char *options, int verbose)
>  {
>  	char *path, *c;
> @@ -332,6 +346,8 @@ exportfs(char *arg, char *options, int verbose)
>  
>  	if (*arg == '[')
>  		failed = exportfs_ipv6(arg, options, verbose);
> +	else if (strncmp(arg, "vsock:", strlen("vsock:")) == 0)
> +		failed = exportfs_vsock(arg, options, verbose);
>  	else
>  		failed = exportfs_generic(arg, options, verbose);
>  	if (failed)
> @@ -412,6 +428,20 @@ static int unexportfs_generic(char *arg, int verbose)
>  	return 0;
>  }
>  
> +static int unexportfs_vsock(char *arg, int verbose)
> +{
> +	char *path;
> +
> +	if ((path = strchr(arg + strlen("vsock:"), ':')) != NULL)
> +		*path++ = '\0';
> +
> +	if (!path || *path != '/')
> +		return 1;
> +
> +	unexportfs_parsed(arg, path, verbose);
> +	return 0;
> +}
> +
>  static int unexportfs_ipv6(char *arg, int verbose)
>  {
>  	char *path, *c;
> @@ -445,6 +475,8 @@ unexportfs(char *arg, int verbose)
>  
>  	if (*arg == '[')
>  		failed = unexportfs_ipv6(arg, verbose);
> +	else if (strncmp(arg, "vsock:", strlen("vsock:")) == 0)
> +		failed = unexportfs_vsock(arg, verbose);
>  	else
>  		failed = unexportfs_generic(arg, verbose);
>  	if (failed)
> 
