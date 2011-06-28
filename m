Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:24749 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760831Ab1F1Slz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 14:41:55 -0400
Received: from rtcsinet22.oracle.com (rtcsinet22.oracle.com [66.248.204.30])
	by rcsinet10.oracle.com (Switch-3.4.4/Switch-3.4.2) with ESMTP id p5SIfqVZ031139
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 18:41:54 GMT
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rtcsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id p5SIfpZx011393
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 18:41:52 GMT
Received: from abhmt115.oracle.com (abhmt115.oracle.com [141.146.116.67])
	by acsmt356.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id p5SIfkpt012785
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 13:41:46 -0500
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH 2/2] NFS: Allow sec=none mounts in certain cases
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110628182540.2866.42553.stgit@seurat.1015granger.net>
Date: Tue, 28 Jun 2011 14:41:43 -0400
Message-Id: <5254B924-F04F-473A-9E7D-516F8F129B56@oracle.com>
References: <20110628181324.2866.98154.stgit@seurat.1015granger.net> <20110628182540.2866.42553.stgit@seurat.1015granger.net>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I think the short patch description here is misleading.  This patch does not explicitly allow the "sec=none" mount option to be used.  I'll update this if/when I redrive the patches.


On Jun 28, 2011, at 2:25 PM, Chuck Lever wrote:

> There is an undocumented convention (verified by reviewing network
> traces from a NetApp filer and a Solaris NFS server) where a server
> that returns a mount authflavor list containing an AUTH_NULL entry
> is actually indicating it will accept any security flavor for the
> export being mounted.
> 
> This might be used when the server maps all security flavors into the
> same security mode.  For example, the server treats all accessors as,
> say, UID 17.
> 
> Essentially, AUTH_NULL is treated as a wildcard that matches the
> flavor the mounter requested.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> fs/nfs/super.c |   15 +++++++++++----
> 1 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 4625a4c..543cf9f 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1570,13 +1570,20 @@ static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
> 	 * the first flavor in the list that it supports, on the
> 	 * assumption that the best access is provided by the first
> 	 * flavor."
> +	 *
> +	 * By convention we treat AUTH_NULL in the returned list as
> +	 * a wild card.  The server will map our requested flavor to
> +	 * something else.
> 	 */
> -	for (i = 0; i < args->auth_flavor_len; i++)
> -		for (j = 0; j < server_authlist_len; j++)
> -			if (args->auth_flavors[i] == server->auth_flavs[j]) {
> -				args->auth_flavors[0] = server->auth_flavs[j];
> +	for (i = 0; i < server_authlist_len; i++) {
> +		if (server->auth_flavs[i] == RPC_AUTH_NULL)
> +			goto out;
> +		for (j = 0; j < args->auth_flavor_len; j++)
> +			if (server->auth_flavs[i] == args->auth_flavors[j]) {
> +				args->auth_flavors[0] = server->auth_flavs[i];
> 				goto out;
> 			}
> +	}
> 
> 	dfprintk(MOUNT, "NFS: server does not support requested auth flavor\n");
> 	nfs_umount(server);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




