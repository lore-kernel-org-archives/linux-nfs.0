From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] rpcbind: Change prognum, versnum, minvers, and maxvers in progping to rpcprog_t and rpcvers_t from u_long
Date: Wed, 22 Apr 2009 18:37:50 -0400
Message-ID: <FD0391A5-4CE0-40EE-B699-5741CEF5703D@oracle.com>
References: <1240436748.2246.9.camel@dyn9047022153> <5FEB87E5-10FA-4586-9E0B-A07139D85A35@oracle.com> <D9F240D4-2B18-4A32-8B86-926727368F13@oracle.com> <1240439800.2246.24.camel@dyn9047022153>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS List <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:53894 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbZDVWi2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 18:38:28 -0400
In-Reply-To: <1240439800.2246.24.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 22, 2009, at 6:36 PM, Frank Filz wrote:
> On Wed, 2009-04-22 at 18:08 -0400, Chuck Lever wrote:
>> I take that back.  Replacing u_long with rpcvers_t will work in both
>> cases.  glibc's CLNT_CONTROL expects a u_long here, but TI-RPC  
>> expects
>> an u_int32_t.  These match the typedef for rpcvers_t for each of  
>> these.
>>
>> So, you have to make sure you are building with the headers that go
>> with your RPC library.  The headers in /usr/include/rpc go with  
>> glibc,
>> and the headers in /usr/include/tirpc/rpc go with libtirpc.
>
> Ok, here's a patch that implements it that way. It works fine on  
> PPC64.
>
> This fixes a problem where "rpcinfo -T transport host prognum" fails  
> on a PPC64
> because CLNT_CONTROL expects the version number to be a 32 bit  
> quantity. u_long
> probably works fine on little endian machines, but won't work on big  
> endian
> machines.

Thanks for testing.

The description is somewhat incorrect, though.  TI-RPC's CLNT_CONTROL  
expects the version number to be a 32-bit quantity.  glibc's RPC  
implementation of CLNT_CONTROL is just dandy with u_long.  I think  
that does bear some emphasis in the description.

Changing the types of these variables means that this code will now  
work unchanged with both glibc and TI-RPC (with a recompile, of course).

> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
> ---
> src/rpcinfo.c |    3 ++-
> 1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/src/rpcinfo.c b/src/rpcinfo.c
> index 0170f65..c9f51cf 100644
> --- a/src/rpcinfo.c
> +++ b/src/rpcinfo.c
> @@ -1591,7 +1591,8 @@ progping (netid, argc, argv)
>   CLIENT *client;
>   struct timeval to;
>   enum clnt_stat rpc_stat;
> -  u_long prognum, versnum, minvers, maxvers;
> +  rpcprog_t prognum;
> +  rpcvers_t versnum, minvers, maxvers;
>   struct rpc_err rpcerr;
>   int failure = 0;
>   struct netconfig *nconf;
> -- 
> 1.5.2.2
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




