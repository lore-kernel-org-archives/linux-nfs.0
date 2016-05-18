Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:50769 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753286AbcEROMN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2016 10:12:13 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH Version 4 03/10] NFS refactor
 nfs4_check_serverowner_major_id
To: <andros@netapp.com>, <trond.myklebust@primarydata.com>
References: <1462993705-14673-1-git-send-email-andros@netapp.com>
 <1462993705-14673-4-git-send-email-andros@netapp.com>
CC: <bfields@fieldses.org>, <chuck.lever@oracle.com>,
        <linux-nfs@vger.kernel.org>
Message-ID: <f4559282-c12d-d422-c42b-d2285451dd22@Netapp.com>
Date: Wed, 18 May 2016 10:12:07 -0400
MIME-Version: 1.0
In-Reply-To: <1462993705-14673-4-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On 05/11/2016 03:08 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> For session trunking, to compare nfs41_exchange_id_res with
> existing nfs_client
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4client.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index c9177a4..5a14fda 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -578,11 +578,9 @@ static bool nfs4_match_clientids(u64 a, u64 b)
>   * Returns true if the server major ids match
>   */
>  static bool
> -nfs4_check_clientid_trunking(struct nfs_client *a, struct nfs_client *b)
> +nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
> +				struct nfs41_server_owner *o2)
>  {

It looks like you update the dprintk() in this function with the next patch.  Can you please update it in this one, instead?

Thanks,
Anna

> -	struct nfs41_server_owner *o1 = a->cl_serverowner;
> -	struct nfs41_server_owner *o2 = b->cl_serverowner;
> -
>  	if (o1->major_id_sz != o2->major_id_sz)
>  		goto out_major_mismatch;
>  	if (memcmp(o1->major_id, o2->major_id, o1->major_id_sz) != 0)
> @@ -658,7 +656,8 @@ int nfs41_walk_client_list(struct nfs_client *new,
>  		 * client id trunking. In either case, we want to fall back
>  		 * to using the existing nfs_client.
>  		 */
> -		if (!nfs4_check_clientid_trunking(pos, new))
> +		if (!nfs4_check_serverowner_major_id(pos->cl_serverowner,
> +						     new->cl_serverowner))
>  			continue;
>  
>  		/* Unlike NFSv4.0, we know that NFSv4.1 always uses the
> 

