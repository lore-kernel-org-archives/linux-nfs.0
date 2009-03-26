From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH 02/23] SUNRPC: Fix return type of svc_addr_len()
Date: Thu, 26 Mar 2009 18:43:47 +1100
Message-ID: <49CB3233.4070106@sgi.com>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net> <20090319004535.32404.37120.stgit@ingres.1015granger.net> <20090324203206.GH19389@fieldses.org> <B9961123-78C4-414A-BC5D-84BDC85771B7@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:50276 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750911AbZCZHoC (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 03:44:02 -0400
In-Reply-To: <B9961123-78C4-414A-BC5D-84BDC85771B7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Mar 24, 2009, at 4:32 PM, J. Bruce Fields wrote:
>
>>>
>>> @@ -563,9 +564,20 @@ static void handle_connect_req(struct
>>> rdma_cm_id *new_cma_id, size_t client_ird)
>>>
>>> /* Set the local and remote addresses in the transport */
>>> sa = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.dst_addr;
>>> - svc_xprt_set_remote(&newxprt->sc_xprt, sa, svc_addr_len(sa));
>>> + len = svc_addr_len(sa);
>>> + if (len < 0) {
>>> + dprintk("svcrdma: dst_addr has a bad address family\n");
>>> + return;
>>
>> we're probably leaking something here.
Just a bit. The svcxprt_rdma, the rdma_cm_id, a bunch of other IB state...
>>
>> I don't want to fix this until it's understood well enough to fix it
>> correctly.
>
> Tom needs respond to this, but I think it would be safe to simply
> BUG() here.

My 2c. If I understand the RDMA CM behaviour correctly, it should not be
possible at this point in the code for
newxprt->sc_cm_id->route.addr.{src,dst}_addr to be anything but a valid
sockaddr_storages holding the IPv4 or (theoretically) the IPv6 address
of the server and client. So I would be happy with a BUG_ON(len < 0).
That would also render the leakage moot.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

