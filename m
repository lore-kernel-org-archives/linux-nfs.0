Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:36579 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933150AbdC3R0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Mar 2017 13:26:44 -0400
Subject: Re: [PATCH 1/1] NFSv4.1 fix infinite loop on IO BAD_STATEID error
To: Olga Kornievskaia <kolga@netapp.com>,
        <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
References: <20170330140051.61886-1-kolga@netapp.com>
CC: <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <bdff27b8-152d-69dd-8dc1-0452aeff645d@Netapp.com>
Date: Thu, 30 Mar 2017 13:26:36 -0400
MIME-Version: 1.0
In-Reply-To: <20170330140051.61886-1-kolga@netapp.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 03/30/2017 10:00 AM, Olga Kornievskaia wrote:
> Commit 02bfab0414d7 "NFSv4.1: Don't recheck delegations that
> have already been checked" introduced a regression where when a
> client received BAD_STATEID error it would not send any TEST_STATEID
> and instead go into an infinite loop of resending the IO that caused
> the BAD_STATEID.

Can you double check the bad commit?  I found it as 63d63cbf5e03 and not 02bfab0414d7.  

> 
> Fixes: 02bfab0414d7 ("NFSv4.1: Don't recheck delegations that have already been checked")
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index dfa46e4..fb6d981 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2460,6 +2460,7 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
>  	}
>  
>  	if (!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags)) {
> +		nfs_finish_clear_delegation_stateid(state, &stateid);
>  		rcu_read_unlock();

The NFS_DELEGATION_REVOKED case does the rcu_read_unlock() before the call to nfs_finish_clear_delegation_stateid().  I'm not sure how much of a difference it makes, but can you swap the order of the calls here to match?

Thanks,
Anna

>  		return;
>  	}
> 
