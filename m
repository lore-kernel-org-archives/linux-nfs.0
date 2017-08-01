Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28408 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752109AbdHAUHd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 16:07:33 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 5/5] NFSv4: Cleanup setting of the migration flags.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170801200251.130635-5-trond.myklebust@primarydata.com>
Date: Tue, 1 Aug 2017 16:07:20 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        davej@codemonkey.org.uk,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <AC277398-BD32-4517-AB34-4161129B3B46@oracle.com>
References: <20170801200251.130635-1-trond.myklebust@primarydata.com> <20170801200251.130635-2-trond.myklebust@primarydata.com> <20170801200251.130635-3-trond.myklebust@primarydata.com> <20170801200251.130635-4-trond.myklebust@primarydata.com> <20170801200251.130635-5-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 1, 2017, at 4:02 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/nfs4proc.c | 9 +++------
> 1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d9fc34dedcf8..15e91f003adc 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7498,13 +7498,10 @@ nfs4_run_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
> 				sizeof(calldata->args.verifier.data));
> 	}
> 	calldata->args.client = clp;
> -#ifdef CONFIG_NFS_V4_1_MIGRATION
> -	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
> -	EXCHGID4_FLAG_BIND_PRINC_STATEID |
> -	EXCHGID4_FLAG_SUPP_MOVED_MIGR,
> -#else
> 	calldata->args.flags = EXCHGID4_FLAG_SUPP_MOVED_REFER |
> -	EXCHGID4_FLAG_BIND_PRINC_STATEID,
> +	EXCHGID4_FLAG_BIND_PRINC_STATEID;
> +#ifdef CONFIG_NFS_V4_1_MIGRATION
> +	calldata->args.flags |= EXCHGID4_FLAG_SUPP_MOVED_MIGR;
> #endif
> 	msg.rpc_argp = &calldata->args;
> 	msg.rpc_resp = &calldata->res;

I think NFSv4.1 migration is supported well enough now
that the CONFIG_NFS_V4_1_MIGRATION configuration option
might be removed, leaving SUPP_MOVED_MIGR asserted all
the time.


--
Chuck Lever



