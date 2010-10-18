Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:41576 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab0JRVzR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 17:55:17 -0400
Subject: Re: [PATCH v2 9/13] sunrpc: Merge the xs_bind code
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101018214305.GE4740@fieldses.org>
Date: Mon, 18 Oct 2010 17:53:45 -0400
Cc: Pavel Emelyanov <xemul@parallels.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4480316F-74A4-4157-B685-056FD958890E@oracle.com>
References: <4CA9CDA8.4010407@parallels.com> <4CA9CEE8.9050404@parallels.com> <66FA6AAD-87DC-4B81-8DAC-8F1D4FF7B72E@oracle.com> <4CAABAAB.8040608@parallels.com> <4CAB11A4.7000306@parallels.com> <20101015160545.GB12268@fieldses.org> <9D130D08-1FD3-4088-AB43-8CEFFE6476B3@oracle.com> <20101015180852.GC18869@fieldses.org> <068F3C9A-2930-46F7-AC15-EB71ADA1933F@oracle.com> <20101018211537.GC4740@fieldses.org> <20101018214305.GE4740@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 18, 2010, at 5:43 PM, J. Bruce Fields wrote:

> On Mon, Oct 18, 2010 at 05:15:37PM -0400, J. Bruce Fields wrote:
>> On Fri, Oct 15, 2010 at 02:11:29PM -0400, Chuck Lever wrote:
>>> 
>>> On Oct 15, 2010, at 2:08 PM, J. Bruce Fields wrote:
>>> 
>>>> On Fri, Oct 15, 2010 at 12:39:36PM -0400, Chuck Lever wrote:
>>>>> 
>>>>> On Oct 15, 2010, at 12:05 PM, J. Bruce Fields wrote:
>>>>> 
>>>>>> On Tue, Oct 05, 2010 at 03:53:08PM +0400, Pavel Emelyanov wrote:
>>>>>>> There's the only difference betseen the xs_bind4 and the
>>>>>>> xs_bind6 - the size of sockaddr structure they use.
>>>>>>> 
>>>>>>> Fortunatelly its size can be indirectly get from the transport.
>>>>>>> 
>>>>>>> Change since v1:
>>>>>>> * use sockaddr_storage instead of sockaddr
>>>>>>> * use rpc_set_port instead of manual port assigning
>>>>>> 
>>>>>> Whoops, dropping this; it breaks nfsd startup.  I haven't figured out
>>>>>> why yet, but I get
>>>>>> 
>>>>>> RPC: server localhost requires stronger authentication.
>>>>>> svc: failed to register nfsdv2 RPC service (errno 13).
>>>>> 
>>>>> Capturing a network trace of lo during server initialization should reveal all.  Compare a trace from a working run and a non-working one.
>>>> 
>>>> Hm.  One difference is the source port of the portmap calls: 33471 in
>>>> the bad case, 1016 in the bad.--b.
>>> 
>>> 1016 in the good... yes, that's because the server's registration upcall needs a privileged port, and xs_bind is not obliging here.  That certainly would result in a "requires stronger authentication" error from rpcbind.
>> 
>> So, adding some printk's: the problem is that the patch assumes that the
>> trasnport->xprt.addrlen and transport->srcaddr.ss_family have been
>> initialized at this point.  But they haven't been.  I don't know where
>> that's supposed to happen.
> 
> Sorry, I meant just the family, the length seems fine.
> 
> I'll just fold this into the relevant patches and push out the result if
> nobody objects.
> 
> --b.
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 8dc287f..324d97a 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1625,6 +1625,7 @@ static struct socket *xs_create_sock(struct rpc_xprt *xprt,
> 				protocol, -err);
> 		goto out;
> 	}
> +	transport->srcaddr.ss_family = family;
> 	xs_reclassify_socket(family, sock);
> 
> 	if (xs_bind(transport, sock)) {

Can you post the full revised patch?  I'm wondering if it's OK to init the sockaddr's family that way, but I can't tell from just the snippet.

-- 
chuck[dot]lever[at]oracle[dot]com




