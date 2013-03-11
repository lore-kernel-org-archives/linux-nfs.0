Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([70.99.223.143]:3787 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754371Ab3CKSvy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 14:51:54 -0400
Message-ID: <513E27C0.8050108@canonical.com>
Date: Mon, 11 Mar 2013 12:51:44 -0600
From: Tim Gardner <tim.gardner@canonical.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, Tom Tucker <tom@ogc.us>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH linux-next v2] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
References: <20130310202838.GL31448@fieldses.org> <1363023447-22453-1-git-send-email-tim.gardner@canonical.com> <20130311181450.GC30618@fieldses.org>
In-Reply-To: <20130311181450.GC30618@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/11/2013 12:14 PM, J. Bruce Fields wrote:
<snip>
>>
>> v2 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_req
>> and pass this request down through rpcrdma_register_external() and
>> rpcrdma_register_default_external(). This is less overhead then using
>> kmalloc() and requires no extra error checking as the allocation burden is
>> shifted to the transport client.
> 
> Oh good--so that works, and the req is the right place to put this?  How
> are you testing this?
> 
> (Just want to make it clear: I'm *not* an expert on the rdma code, so my
> suggestion to put this in the rpcrdma_req was a suggestion for something
> to look into, not a claim that it's correct.)
> 

Just compile tested so far. Incidentally, I've been through the call stack:

call_transmit
 xprt_transmit
  xprt->ops->send_request(task)
   xprt_rdma_send_request
    rpcrdma_marshal_req
     rpcrdma_create_chunks
      rpcrdma_register_external
       rpcrdma_register_default_external

It appears that the context for kmalloc() should be fine unless there is
a spinlock held around call_transmit() (which seems unlikely).

rtg
-- 
Tim Gardner tim.gardner@canonical.com
