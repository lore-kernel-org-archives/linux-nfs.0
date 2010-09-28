Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31103 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794Ab0I1Kpp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 06:45:45 -0400
Message-ID: <4CA1C71D.70109@parallels.com>
Date: Tue, 28 Sep 2010 14:44:45 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/8] sunrpc: Factor out rpc_xprt freeing
References: <4CA06C7A.5060307@parallels.com> <4CA06CA0.6060606@parallels.com> <02506D5E-BD8D-40AC-822F-00BBC14792E9@oracle.com>
In-Reply-To: <02506D5E-BD8D-40AC-822F-00BBC14792E9@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/27/2010 11:40 PM, Chuck Lever wrote:
> 
> On Sep 27, 2010, at 6:06 AM, Pavel Emelyanov wrote:
> 
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> ---
>> net/sunrpc/xprtsock.c |   20 ++++++++++++--------
>> 1 files changed, 12 insertions(+), 8 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index b6309db..98d4b7b 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -759,6 +759,8 @@ static void xs_tcp_close(struct rpc_xprt *xprt)
>> 		xs_tcp_shutdown(xprt);
>> }
>>
>> +static void xs_free_xprt(struct rpc_xprt *xprt);
> 
> Style nit: we usually like forward declarations at the top of source files.

OK.

> Do you need to fix up xprtrdma too?  (eg. xprt_rdma_destroy)  It looks like it has 
> similar logic around freeing xprts. 

Indeed. Bruce, which way would you prefer - should I re-send the whole set or
can apply this change incrementally?

> Even though it doesn't use sockets, do we need to be concerned about net namespaces
> for RDMA transports?

I believe we should, since at least its initialization goes to the rdma_resolve_addr
which in turn resolves the address using IP-level routing. But I wanted to finish with
the tcp/udp transports first.

Thanks,
Pavel
