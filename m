Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-01.prod.phx3.secureserver.net ([68.178.252.102]:42742
        "EHLO p3plsmtpa11-01.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751293AbdBWUeb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 15:34:31 -0500
Subject: Re: [PATCH 1/4] sunrpc: flag transports as using IETF approved
 congestion control protocols
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170223170337.10686-2-jlayton@redhat.com>
 <2152dfdf-f847-2511-1600-6499b6ea9708@talpey.com>
 <1487880034.3448.8.camel@redhat.com>
 <65056db6-f30a-c44d-b01c-b549887c4895@talpey.com>
 <20170223201109.GC11882@fieldses.org>
 <20170223202609.GC26301@obsidianresearch.com>
Cc: Jeff Layton <jlayton@redhat.com>, trond.myklebust@primarydata.com,
        schumaker.anna@gmail.com, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org
From: Tom Talpey <tom@talpey.com>
Message-ID: <18ef37c3-95db-9a2c-dbcb-f579672065d6@talpey.com>
Date: Thu, 23 Feb 2017 15:33:53 -0500
MIME-Version: 1.0
In-Reply-To: <20170223202609.GC26301@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/23/2017 3:26 PM, Jason Gunthorpe wrote:
> On Thu, Feb 23, 2017 at 03:11:09PM -0500, J. Bruce Fields wrote:
>
>> (And if we really shouldn't be doing NFSv4 over some RDMA transports--is
>> it worth supporting them at all, if the only support we can get is
>> NFSv3-only?)
>
> This seems like a strange comment - NFSv4 should be supported on all
> RDMA transports, surely?
>
> Largely RDMA lives in its own congestion management world. If a site
> is running RDMA they have done something to mitigate interactions with
> TCP style congestion control on the same wire.

The key words are "IETF-approved". Mitigation and Interaction are
operational decisions, not protocol design.

We could argue that the requirement is bogus, or that all RDMA transports
comply, or that the RPCRDMA layer provides it, but none of these arguments
would grant IETF approval. That said, I think there's a lot of
room for interpretation here.

Tom.
