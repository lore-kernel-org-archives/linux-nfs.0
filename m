From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Change prognum, versnum, minvers, and maxvers in progping to u_int32_t from u_long
Date: Wed, 22 Apr 2009 17:56:54 -0400
Message-ID: <5FEB87E5-10FA-4586-9E0B-A07139D85A35@oracle.com>
References: <1240436748.2246.9.camel@dyn9047022153>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS List <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:45294 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbZDVV6n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 17:58:43 -0400
In-Reply-To: <1240436748.2246.9.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 22, 2009, at 5:45 PM, Frank Filz wrote:
> This fixes a problem where "rpcinfo -T transport host prognum" fails  
> on a PPC64
> because CLNT_CONTROL expects the version number to be a 32 bit  
> quantity. u_long
> probably works fine on little endian machines, but won't work on big  
> endian
> machines.
>
>
> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> ---
> src/rpcinfo.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/src/rpcinfo.c b/src/rpcinfo.c
> index 0170f65..698f4ca 100644
> --- a/src/rpcinfo.c
> +++ b/src/rpcinfo.c
> @@ -1591,7 +1591,7 @@ progping (netid, argc, argv)
>   CLIENT *client;
>   struct timeval to;
>   enum clnt_stat rpc_stat;
> -  u_long prognum, versnum, minvers, maxvers;
> +  u_int32_t prognum, versnum, minvers, maxvers;

Right, looking at the TI-RPC type definitions, we really want:

   rpcprog_t prognum;
   rpcvers_t versnum, minvers, maxvers;

Now, this won't work if rpcinfo is built against the legacy RPC  
headers in /usr/include.  The TI-RPC headers define these types  
correctly as u_int32_t, but the legacy headers use u_long.

>   struct rpc_err rpcerr;
>   int failure = 0;
>   struct netconfig *nconf;
> -- 
> 1.5.2.2
>
>
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




