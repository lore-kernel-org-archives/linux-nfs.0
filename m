Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47799 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932394AbdHWTb5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Aug 2017 15:31:57 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2] NFS: Fix NFSv2 security settings
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170810204110.11398.85077.stgit@manet.1015granger.net>
Date: Wed, 23 Aug 2017 15:31:51 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5498B4D8-2CE9-4956-BEC1-A8A5F2B649F7@oracle.com>
References: <20170810204110.11398.85077.stgit@manet.1015granger.net>
To: Steve Dickson <SteveD@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ping...


> On Aug 10, 2017, at 4:41 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> For a while now any NFSv2 mount where sec= is specified uses
> AUTH_NULL. If sec= is not specified, the mount uses AUTH_UNIX.
> Commit e68fd7c8071d ("mount: use sec= that was specified on the
> command line") attempted to address a very similar problem with
> NFSv3, and should have fixed this too, but it has a bug.
> 
> The MNTv1 MNT procedure does not return a list of security flavors,
> so our client makes up a list containing just AUTH_NULL. This should
> enable nfs_verify_authflavors() to assign the sec= specified flavor,
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
> Changes since v1:
> - Description edited for accuracy
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



