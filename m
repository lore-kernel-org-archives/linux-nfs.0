From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH 12/29] NFS: Verify IPv6 addresses properly
Date: Thu, 29 Nov 2007 19:53:26 -0500
Message-ID: <1196384006.20292.124.camel@heimdal.trondhjem.org>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
	<20071129194056.4170.67521.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ixu8U-0006uC-MK
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 16:53:52 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ixu8a-0000Sg-0f
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 16:53:48 -0800
In-Reply-To: <20071129194056.4170.67521.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Thu, 2007-11-29 at 14:40 -0500, Chuck Lever wrote:
> Add support to nfs_verify_server_address for recognizing AF_INET6
> addresses.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/super.c |   27 ++++++++++++++++-----------
>  1 files changed, 16 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index e5646a9..ed0b5f1 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -576,16 +576,21 @@ static void nfs_umount_begin(struct vfsmount *vfsmnt, int flags)
>  }
>  
>  /*
> - * Sanity-check a server address provided by the mount command
> + * Sanity-check a server address provided by the mount command.
> + *
> + * Address family must be initialized, and address must not be
> + * the ANY address for that family.
>   */
> -static int nfs_verify_server_address(struct sockaddr *addr)
> +static int nfs_verify_server_address(struct sockaddr_storage *ssp)

Hmm... This looks wrong. We should never be using a type 'pointer to
sockaddr_storage'. Particularly not when all the callers have to cast.
Please convert to a generic 'struct sockaddr *'.

Ditto in the other cases (nfs4_default_port(),
nfs_parse_server_address() etc.).

BTW: did I miss [Patch 11/29]? I can't find it in my inbox...

Trond

>  {
> -	switch (addr->sa_family) {
> +	switch (ssp->ss_family) {
>  	case AF_INET: {
> -		struct sockaddr_in *sa = (struct sockaddr_in *) addr;
> -		if (sa->sin_addr.s_addr != INADDR_ANY)
> -			return 1;
> -		break;
> +		struct sockaddr_in *sa = (struct sockaddr_in *)ssp;
> +		return sa->sin_addr.s_addr != INADDR_ANY;
> +	}
> +	case AF_INET6: {
> +		struct in6_addr *sa = &((struct sockaddr_in6 *)ssp)->sin6_addr;
> +		return !ipv6_addr_any(sa);
>  	}
>  	}
>  
> @@ -1084,7 +1089,7 @@ static int nfs_validate_mount_data(void *options,
>  			memset(mntfh->data + mntfh->size, 0,
>  			       sizeof(mntfh->data) - mntfh->size);
>  
> -		if (!nfs_verify_server_address((struct sockaddr *) &data->addr))
> +		if (!nfs_verify_server_address((void *)&data->addr))
>  			goto out_no_address;
>  
>  		/*
> @@ -1118,7 +1123,7 @@ static int nfs_validate_mount_data(void *options,
>  		if (nfs_parse_mount_options((char *)options, args) == 0)
>  			return -EINVAL;
>  
> -		if (!nfs_verify_server_address((struct sockaddr *)
> +		if (!nfs_verify_server_address((void *)
>  						&args->nfs_server.address))
>  			goto out_no_address;
>  
> @@ -1577,7 +1582,7 @@ static int nfs4_validate_mount_data(void *options,
>  			return -EFAULT;
>  		if (args->nfs_server.address.sin_port == 0)
>  			args->nfs_server.address.sin_port = htons(NFS_PORT);
> -		if (!nfs_verify_server_address((struct sockaddr *)
> +		if (!nfs_verify_server_address((void *)
>  						&args->nfs_server.address))
>  			goto out_no_address;
>  
> @@ -1636,7 +1641,7 @@ static int nfs4_validate_mount_data(void *options,
>  
>  		if (args->nfs_server.address.sin_port == 0)
>  			args->nfs_server.address.sin_port = htons(NFS_PORT);
> -		if (!nfs_verify_server_address((struct sockaddr *)
> +		if (!nfs_verify_server_address((void *)
>  						&args->nfs_server.address))
>  			return -EINVAL;
>  
> 


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

