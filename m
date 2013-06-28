Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:30748 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845Ab3F1PGO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jun 2013 11:06:14 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v4 3/4] nfs: have nfs_mount fake up a auth_flavs list when the server didn't provide it
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1372362881-32282-4-git-send-email-jlayton@redhat.com>
Date: Fri, 28 Jun 2013 11:06:08 -0400
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
        Weston.Adamson@netapp.com
Message-Id: <077289D0-868D-4358-A29A-8BC31C6FB2F0@oracle.com>
References: <1372362881-32282-1-git-send-email-jlayton@redhat.com> <1372362881-32282-4-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 27, 2013, at 3:54 PM, Jeff Layton <jlayton@redhat.com> wrote:

> Instead of handling this as a special case in the auth-selection code,
> we can simply fake up an auth_flavs list when the server doesn't
> provide it.

The series looks like a reasonable approach.  One nit picked below.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/mount_clnt.c | 18 +++++++++++++++++-
> fs/nfs/super.c      | 13 -------------
> 2 files changed, 17 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> index 91a6faf..0f925f3 100644
> --- a/fs/nfs/mount_clnt.c
> +++ b/fs/nfs/mount_clnt.c
> @@ -139,7 +139,10 @@ struct mnt_fhstatus {
>  * nfs_mount - Obtain an NFS file handle for the given host and path
>  * @info: pointer to mount request arguments
>  *
> - * Uses default timeout parameters specified by underlying transport.
> + * Uses default timeout parameters specified by underlying transport. On
> + * successful return, the auth_flavs list and auth_flav_len will be populated
> + * with the list from the server or a faked-up list if the server didn't
> + * provide one.
>  */
> int nfs_mount(struct nfs_mount_request *info)
> {
> @@ -195,6 +198,19 @@ int nfs_mount(struct nfs_mount_request *info)
> 	dprintk("NFS: MNT request succeeded\n");
> 	status = 0;
> 
> +	/*
> +	 * The NFSv2 MNT operation does not return a flavor list. Also, some
> +	 * NFSv3 servers (older Linux servers in particular) return an empty
> +	 * list.
> +	 *
> +	 * In that event fake up a list that just has RPC_AUTH_NULL in it since
> +	 * we have no way to know what the server actually supports.
> +	 */

I see the checks are folded together again.  I'm not going to win that battle, am I? ;-)

The comment repeats most of what the code already says.  How about:

	/*
	 * If the server didn't provide a flavor list, allow the
	 * client to try any flavor.
	 */

Blue is my favorite color, by the way.

> +	if (info->version != NFS_MNT3_VERSION || *info->auth_flav_len == 0) {
> +		dprintk("NFS: Faking up auth_flavs list\n");
> +		info->auth_flavs[0] = RPC_AUTH_NULL;
> +		*info->auth_flav_len = 1;
> +	}
> out:
> 	return status;
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index a0949f5..ceb60c7 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1620,19 +1620,6 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
> 	rpc_authflavor_t flavor;
> 
> 	/*
> -	 * The NFSv2 MNT operation does not return a flavor list.
> -	 */
> -	if (args->mount_server.version != NFS_MNT3_VERSION)
> -		goto out_default;
> -
> -	/*
> -	 * Certain releases of Linux's mountd return an empty
> -	 * flavor list in some cases.
> -	 */
> -	if (count == 0)
> -		goto out_default;
> -
> -	/*
> 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
> 	 * must be in the list returned by the server.
> 	 *
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




