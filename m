From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Libtirpc-devel] [PATCH] Change prognum, versnum, minvers, and maxvers in progping to u_int32_t from u_long
Date: Wed, 22 Apr 2009 18:08:58 -0400
Message-ID: <D9F240D4-2B18-4A32-8B86-926727368F13@oracle.com>
References: <1240436748.2246.9.camel@dyn9047022153> <5FEB87E5-10FA-4586-9E0B-A07139D85A35@oracle.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: NFS List <linux-nfs@vger.kernel.org>,
	Steve Dickson <SteveD@redhat.com>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:26659 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbZDVWOd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 18:14:33 -0400
In-Reply-To: <5FEB87E5-10FA-4586-9E0B-A07139D85A35@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 22, 2009, at 5:56 PM, Chuck Lever wrote:
> On Apr 22, 2009, at 5:45 PM, Frank Filz wrote:
>> This fixes a problem where "rpcinfo -T transport host prognum" fails
>> on a PPC64
>> because CLNT_CONTROL expects the version number to be a 32 bit
>> quantity. u_long
>> probably works fine on little endian machines, but won't work on big
>> endian
>> machines.
>>
>>
>> Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
>> ---
>> src/rpcinfo.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/src/rpcinfo.c b/src/rpcinfo.c
>> index 0170f65..698f4ca 100644
>> --- a/src/rpcinfo.c
>> +++ b/src/rpcinfo.c
>> @@ -1591,7 +1591,7 @@ progping (netid, argc, argv)
>>  CLIENT *client;
>>  struct timeval to;
>>  enum clnt_stat rpc_stat;
>> -  u_long prognum, versnum, minvers, maxvers;
>> +  u_int32_t prognum, versnum, minvers, maxvers;
>
> Right, looking at the TI-RPC type definitions, we really want:
>
>   rpcprog_t prognum;
>   rpcvers_t versnum, minvers, maxvers;
>
> Now, this won't work if rpcinfo is built against the legacy RPC
> headers in /usr/include.  The TI-RPC headers define these types
> correctly as u_int32_t, but the legacy headers use u_long.

I take that back.  Replacing u_long with rpcvers_t will work in both  
cases.  glibc's CLNT_CONTROL expects a u_long here, but TI-RPC expects  
an u_int32_t.  These match the typedef for rpcvers_t for each of these.

So, you have to make sure you are building with the headers that go  
with your RPC library.  The headers in /usr/include/rpc go with glibc,  
and the headers in /usr/include/tirpc/rpc go with libtirpc.

>>  struct rpc_err rpcerr;
>>  int failure = 0;
>>  struct netconfig *nconf;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
