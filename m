Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34652 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752234AbdKRT0g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2017 14:26:36 -0500
Subject: Re: [PATCH] NFSv4: Ensure gcc 4.4.4 can compile initialiser for
 "invalid_stateid"
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: "linux-nfs @ vger . kernel . org" <linux-nfs@vger.kernel.org>,
        "linux-kernel @ vger . kernel . org" <linux-kernel@vger.kernel.org>
References: <cce6f1be-0481-4ecc-85e2-a626cf381ce3@oracle.com>
 <20171118185011.4729-1-trond.myklebust@primarydata.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Message-ID: <5f7d708b-a362-1fc7-2993-cbcbdefe42cc@oracle.com>
Date: Sat, 18 Nov 2017 14:26:16 -0500
MIME-Version: 1.0
In-Reply-To: <20171118185011.4729-1-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/18/2017 01:50 PM, Trond Myklebust wrote:
> gcc 4.4.4 is too old to have full C11 anonymous union support, so
> the current initialiser fails to compile.
> 
> Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>


(compile-)Tested-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> ---
>   fs/nfs/nfs4state.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 980462d577ca..231b5ea2464a 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -71,8 +71,8 @@ const nfs4_stateid zero_stateid = {
>   };
>   const nfs4_stateid invalid_stateid = {
>   	{
> -		.seqid = cpu_to_be32(0xffffffffU),
> -		.other = { 0 },
> +		/* Funky initialiser keeps older gcc versions happy */
> +		.data = { 0xff, 0xff, 0xff, 0xff, 0 },
>   	},
>   	.type = NFS4_INVALID_STATEID_TYPE,
>   };
> 
