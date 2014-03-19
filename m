Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4947 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964847AbaCSMKA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2014 08:10:00 -0400
Message-ID: <53298914.2090003@RedHat.com>
Date: Wed, 19 Mar 2014 08:09:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSv4: Schedule recovery if nfs40_walk_client_list()
 is interrupted
References: <1395173006-14871-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1395173006-14871-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/18/2014 04:03 PM, Trond Myklebust wrote:
> If a timeout or a signal interrupts the NFSv4 trunking discovery
> SETCLIENTID_CONFIRM call, then we don't know whether or not the
> server has changed the callback identifier on us.
> Assume that it did, and schedule a 'path down' recovery...
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Tested-by: Steve Dickson <steved@redhat.com>

steved.
> ---
>  fs/nfs/nfs4client.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
> index 0e46d3d1b6cc..aa9ef4876046 100644
> --- a/fs/nfs/nfs4client.c
> +++ b/fs/nfs/nfs4client.c
> @@ -531,6 +531,13 @@ int nfs40_walk_client_list(struct nfs_client *new,
>  			*result = pos;
>  			dprintk("NFS: <-- %s using nfs_client = %p ({%d})\n",
>  				__func__, pos, atomic_read(&pos->cl_count));
> +			goto out;
> +		case -ERESTARTSYS:
> +		case -ETIMEDOUT:
> +			/* The callback path may have been inadvertently
> +			 * changed. Schedule recovery!
> +			 */
> +			nfs4_schedule_path_down_recovery(pos);
>  		default:
>  			goto out;
>  		}
> 
