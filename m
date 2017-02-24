Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-03.prod.phx3.secureserver.net ([68.178.252.104]:49202
        "EHLO p3plsmtpa11-03.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751218AbdBXPIp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Feb 2017 10:08:45 -0500
Subject: Re: [PATCH 1/4] sunrpc: flag transports as using IETF approved
 congestion control protocols
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170223170337.10686-2-jlayton@redhat.com>
 <2152dfdf-f847-2511-1600-6499b6ea9708@talpey.com>
 <1487880034.3448.8.camel@redhat.com>
 <65056db6-f30a-c44d-b01c-b549887c4895@talpey.com>
 <20170223201109.GC11882@fieldses.org>
 <20170223202609.GC26301@obsidianresearch.com>
 <18ef37c3-95db-9a2c-dbcb-f579672065d6@talpey.com>
 <20170223205502.GA29673@obsidianresearch.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>, trond.myklebust@primarydata.com,
        schumaker.anna@gmail.com, linux-nfs@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org
From: Tom Talpey <tom@talpey.com>
Message-ID: <4eb1da3d-2690-7647-2d85-cc574bc1d564@talpey.com>
Date: Fri, 24 Feb 2017 10:08:12 -0500
MIME-Version: 1.0
In-Reply-To: <20170223205502.GA29673@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/23/2017 3:55 PM, Jason Gunthorpe wrote:
> On Thu, Feb 23, 2017 at 03:33:53PM -0500, Tom Talpey wrote:
>
>> The key words are "IETF-approved". Mitigation and Interaction are
>> operational decisions, not protocol design.
>
> We are talking about this bit from RFC 3530 ?
>
>    Where an NFS version 4 implementation supports operation over the IP
>    network protocol, the supported transports between NFS and IP MUST be
>    among the IETF-approved congestion control transport protocols, which
>    include TCP and SCTP.
>
> This gives most of RDMA an out as it is not over the IP protocol. The
> only obvious troubled one is RoCEv2..

RFC7530 has updated this text somewhat, but it's similar, yes.

https://tools.ietf.org/html/rfc7530#section-3.1

The specification language specifically calls out IP-based transports,
which is why I mentioned that RoCEv1, being non-IP-based and not even
truly routable, could obtain a bye. But the NFS layer IMO should really
not be digging down to this level. I think it would be much better if
each transport could expose a relevant attribute, which NFS could
optionally inspect.

As you mention, RoCEv2 is a bit of a pickle. It's UDP/IP-based, and it
does have end-to-end congestion control, but technically speaking it
is not "IETF approved". I'm not sure what call to make there.

Tom.
