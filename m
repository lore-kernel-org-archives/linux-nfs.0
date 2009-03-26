From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 02/23] SUNRPC: Fix return type of svc_addr_len()
Date: Thu, 26 Mar 2009 12:03:14 -0400
Message-ID: <762B6D1D-78A9-4C29-9095-3F40C95C6B5B@oracle.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004535.32404.37120.stgit@ingres.1015granger.net> <20090324203206.GH19389@fieldses.org> <B9961123-78C4-414A-BC5D-84BDC85771B7@oracle.com> <49CB3233.4070106@sgi.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:30397 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbZCZQDm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 12:03:42 -0400
In-Reply-To: <49CB3233.4070106@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 26, 2009, at 3:43 AM, Greg Banks wrote:
> Chuck Lever wrote:
>> On Mar 24, 2009, at 4:32 PM, J. Bruce Fields wrote:
>>
>>>>
>>>> @@ -563,9 +564,20 @@ static void handle_connect_req(struct
>>>> rdma_cm_id *new_cma_id, size_t client_ird)
>>>>
>>>> /* Set the local and remote addresses in the transport */
>>>> sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
>>>> - svc_xprt_set_remote(&newxprt->sc_xprt, sa, svc_addr_len(sa));
>>>> + len = svc_addr_len(sa);
>>>> + if (len < 0) {
>>>> + dprintk("svcrdma: dst_addr has a bad address family\n");
>>>> + return;
>>>
>>> we're probably leaking something here.
> Just a bit. The svcxprt_rdma, the rdma_cm_id, a bunch of other IB  
> state...
>>>
>>> I don't want to fix this until it's understood well enough to fix it
>>> correctly.
>>
>> Tom needs respond to this, but I think it would be safe to simply
>> BUG() here.
>
> My 2c. If I understand the RDMA CM behaviour correctly, it should  
> not be
> possible at this point in the code for
> newxprt->sc_cm_id->route.addr.{src,dst}_addr to be anything but a  
> valid
> sockaddr_storages holding the IPv4 or (theoretically) the IPv6 address
> of the server and client. So I would be happy with a BUG_ON(len < 0).
> That would also render the leakage moot.

My primary objection is the negative return value from  
svc_addr_len().  Perhaps it would be safer all around if  
svc_addr_len() returned zero if it didn't recognize the address family  
in the passed in sockaddr.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
