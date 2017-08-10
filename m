Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51897 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752889AbdHJUgg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Aug 2017 16:36:36 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v7AKaYol025725
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 20:36:35 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id v7AKaY9h003497
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 20:36:34 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v7AKaXiT023245
        for <linux-nfs@vger.kernel.org>; Thu, 10 Aug 2017 20:36:34 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1] NFS: Fix NFSv2 security settings
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170810203329.11254.69554.stgit@manet.1015granger.net>
Date: Thu, 10 Aug 2017 16:36:32 -0400
Message-Id: <67838AB8-9B38-4167-8020-682786E99D7C@oracle.com>
References: <20170810203329.11254.69554.stgit@manet.1015granger.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 10, 2017, at 4:33 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> For a while now all NFSv2 mounts have used only AUTH_NULL, no matter
> what the sec= mount option setting was.

Well, that's not true. Any NFSv2 mount where sec= is specified uses
AUTH_NULL. If sec= is not specified, the mount uses AUTH_UNIX.


> Commit e68fd7c8071d ("mount:
> use sec= that was specified on the command line") attempted to
> address a very similar problem with NFSv3, but had a bug.
> 
> The MNTv1 MNT procedure does not return a list of security flavors,
> so our client makes up a list containing just AUTH_NULL. This should
> enable nfs_verify_authflavors to assign the sec= specified flavor,
> but instead, it incorrectly sets it to AUTH_NULL.
> 
> I expect this would also be a problem for any NFSv3 server whose
> MNTv3 MNT procedure returned a security flavor list containing only
> AUTH_NULL.
> 
> Fixes: e68fd7c8071d ("mount: use sec= that was specified on ... ")
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=310
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> fs/nfs/super.c |   12 ++++++++----
> 1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index d828ef8..6b179af 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1691,8 +1691,8 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
> 			rpc_authflavor_t *server_authlist, unsigned int count)
> {
> 	rpc_authflavor_t flavor = RPC_AUTH_MAXFLAVOR;
> +	bool found_auth_null = false;
> 	unsigned int i;
> -	int use_auth_null = false;
> 
> 	/*
> 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
> @@ -1701,6 +1701,10 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
> 	 * AUTH_NULL has a special meaning when it's in the server list - it
> 	 * means that the server will ignore the rpc creds, so any flavor
> 	 * can be used but still use the sec= that was specified.
> +	 *
> +	 * Note also that the MNT procedure in MNTv1 does not return a list
> +	 * of supported security flavors. In this case, nfs_mount() fabricates
> +	 * a security flavor list containing just AUTH_NULL.
> 	 */
> 	for (i = 0; i < count; i++) {
> 		flavor = server_authlist[i];
> @@ -1709,11 +1713,11 @@ static int nfs_verify_authflavors(struct nfs_parsed_mount_data *args,
> 			goto out;
> 
> 		if (flavor == RPC_AUTH_NULL)
> -			use_auth_null = true;
> +			found_auth_null = true;
> 	}
> 
> -	if (use_auth_null) {
> -		flavor = RPC_AUTH_NULL;
> +	if (found_auth_null) {
> +		flavor = args->auth_info.flavors[0];
> 		goto out;
> 	}
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



