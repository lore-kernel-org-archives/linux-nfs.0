From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Change prognum, versnum, minvers, and maxvers in progping to u_int32_t from u_long
Date: Wed, 22 Apr 2009 17:46:15 -0400
Message-ID: <AEAEC6BE-769B-4027-B427-041C65BB1EF8@oracle.com>
References: <1240436748.2246.9.camel@dyn9047022153>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS List <linux-nfs@vger.kernel.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:16999 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbZDVVrV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 17:47:21 -0400
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

Hrm.  These variables are unsigned long pretty much everywhere in the  
legacy RPC code.  And, isn't SPARC big endian?  Is the real problem  
32- v. 64- bit?

This might be fixed more generically by adding a type cast to  
CLNT_CONTROL.

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
>   struct rpc_err rpcerr;
>   int failure = 0;
>   struct netconfig *nconf;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
