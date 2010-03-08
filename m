From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: add and use nfs_authsys_create
Date: Mon, 08 Mar 2010 10:36:36 -0500
Message-ID: <4B951984.9070101@RedHat.com>
References: <1266620728-14574-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753491Ab0CHPgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 10:36:40 -0500
In-Reply-To: <1266620728-14574-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/19/2010 06:05 PM, Jeff Layton wrote:
> The current mount, umount and showmount code uses
> authunix_create_default to get an auth handle. The one provided by glibc
> returned a truncated list of groups when there were more than 16 groups.
> libtirpc however currently does an abort() in this case, which causes
> the program to crash and dump core.
> 
> nfs-utils just uses these auth handles for the MNT protocol, so the
> group list doesn't make a lot of difference here. Add a new function
> that creates an auth handle with a supplemental gids list that consists
> only of the primary gid. Have nfs-utils use that function anywhere that
> it currently uses authunix_create_default. Also, have the caller
> properly check for a NULL return from that function.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  support/include/nfsrpc.h    |    3 +++
>  support/nfs/rpc_socket.c    |   21 +++++++++++++++++++++
>  utils/mount/network.c       |   15 ++++++++++++---
>  utils/showmount/showmount.c |    8 +++++++-
>  4 files changed, 43 insertions(+), 4 deletions(-)
> 
> diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
> index 4db35ab..6ebefca 100644
> --- a/support/include/nfsrpc.h
> +++ b/support/include/nfsrpc.h
> @@ -160,4 +160,7 @@ extern int		nfs_rpc_ping(const struct sockaddr *sap,
>  				const unsigned short protocol,
>  				const struct timeval *timeout);
>  
> +/* create AUTH_SYS handle with no supplemental groups */
> +extern AUTH *			 nfs_authsys_create(void);
> +
>  #endif	/* !__NFS_UTILS_NFSRPC_H */
> diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
> index 0e20824..aa6a205 100644
> --- a/support/nfs/rpc_socket.c
> +++ b/support/nfs/rpc_socket.c
> @@ -557,3 +557,24 @@ rpcprog_t nfs_getrpcbyname(const rpcprog_t program, const char *table[])
>  
>  	return program;
>  }
> +
> +/*
> + * AUTH_SYS doesn't allow more than 16 gids in the supplemental group list.
> + * If there are more than that, trying to determine which ones to include
> + * in the list is problematic. This function creates an auth handle that
> + * only has the primary gid in the supplemental gids list. It's intended to
> + * be used for protocols where credentials really don't matter much (the MNT
> + * protocol, for instance).
> + */
> +AUTH *
> +nfs_authsys_create(void)
> +{
> +	char machname[MAXHOSTNAMELEN + 1];
> +	uid_t	uid = geteuid();
> +	gid_t	gid = getegid();
> +
> +	if (gethostname(machname, sizeof(machname)) == -1)
> +		return NULL;
> +
> +	return authsys_create(machname, uid, gid, 1, &gid);
> +}
The following patch is needed to fix regression when tirpc is
disabled:

steved.

Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 8 10:24:44 2010 -0500

    Use authunix_create() instead of authsys_create() to fix regression.
    
    Commit 409b8 introduced a regression when the --disable-tirpc
    configuration flag is set. The authsys_create() interface, which
    was introduced, does not exist in the legacy glibc library.
    
    Since the authsys_create() interface is a redefined of the
    authunix_create() interface, which is defined in glibc, using
    authunix_create() resolves the regression,
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index aa6a205..c14efe8 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -576,5 +576,5 @@ nfs_authsys_create(void)
        if (gethostname(machname, sizeof(machname)) == -1)
                return NULL;
 
-       return authsys_create(machname, uid, gid, 1, &gid);
+       return authunix_create(machname, uid, gid, 1, &gid);
 }

