Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:19110 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbbACTpN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 14:45:13 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] NFSv4.1: Fix client id trunking on Linux
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1420234772-13083-1-git-send-email-trond.myklebust@primarydata.com>
Date: Sat, 3 Jan 2015 14:45:08 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6E6F39C1-FC92-4E63-9150-B0FE578D5144@oracle.com>
References: <1420234772-13083-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 2, 2015, at 4:39 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Currently, our trunking code will check for session trunking, but will
> fail to detect client id trunking. This is a problem, because it means
> that the client will fail to recognise that the two connections represent
> shared state, even if they do not permit a shared session.
> By removing the check for the server minor id, and only checking the
> major id, we will end up doing the right thing in both cases: we close
> down the new nfs_client and fall back to using the existing one.
> 
> Fixes: 05f4c350ee02e ("NFS: Discover NFSv4 server trunking when mounting")
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Cc: stable@vger.kernel.org # 3.7.x
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

You can add my Tested-by or Reviewed-by if you like.


> ---
> fs/nfs/nfs4client.c | 17 ++++++++---------
> 1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 03311259b0c4..d949d0f378ec 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -566,20 +566,14 @@ static bool nfs4_match_clientids(struct nfs_client *a, struct nfs_client *b)
> }
> 
> /*
> - * Returns true if the server owners match
> + * Returns true if the server major ids match
>  */
> static bool
> -nfs4_match_serverowners(struct nfs_client *a, struct nfs_client *b)
> +nfs4_check_clientid_trunking(struct nfs_client *a, struct nfs_client *b)
> {
> 	struct nfs41_server_owner *o1 = a->cl_serverowner;
> 	struct nfs41_server_owner *o2 = b->cl_serverowner;
> 
> -	if (o1->minor_id != o2->minor_id) {
> -		dprintk("NFS: --> %s server owner minor IDs do not match\n",
> -			__func__);
> -		return false;
> -	}
> -
> 	if (o1->major_id_sz != o2->major_id_sz)
> 		goto out_major_mismatch;
> 	if (memcmp(o1->major_id, o2->major_id, o1->major_id_sz) != 0)
> @@ -654,7 +648,12 @@ int nfs41_walk_client_list(struct nfs_client *new,
> 		if (!nfs4_match_clientids(pos, new))
> 			continue;
> 
> -		if (!nfs4_match_serverowners(pos, new))
> +		/*
> +		 * Note that session trunking is just a special subcase of
> +		 * client id trunking. In either case, we want to fall back
> +		 * to using the existing nfs_client.
> +		 */
> +		if (!nfs4_check_clientid_trunking(pos, new))
> 			continue;
> 
> 		atomic_inc(&pos->cl_count);
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



