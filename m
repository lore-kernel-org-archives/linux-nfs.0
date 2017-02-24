Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa12-09.prod.phx3.secureserver.net ([68.178.252.238]:57334
        "EHLO p3plsmtpa12-09.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750995AbdBXS5J (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Feb 2017 13:57:09 -0500
Subject: Re: [PATCH v2 0/4] nfs/nfsd/sunrpc: enforce NFSv4 transport
 requirements
To: Jeff Layton <jlayton@redhat.com>, bfields@fieldses.org,
        trond.myklebust@primarydata.com
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170224182525.10390-1-jlayton@redhat.com>
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com, jgunthorpe@obsidianresearch.com
From: Tom Talpey <tom@talpey.com>
Message-ID: <d57e143b-4fbc-a61c-d102-596f2f9166f9@talpey.com>
Date: Fri, 24 Feb 2017 13:53:21 -0500
MIME-Version: 1.0
In-Reply-To: <20170224182525.10390-1-jlayton@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/24/2017 1:25 PM, Jeff Layton wrote:
> v2: comment clarifications, and commit log cleanup. No functional changes.
>
> RFC5661 says:
>
>    NFSv4.1 works over Remote Direct Memory Access (RDMA) and non-RDMA-
>    based transports with the following attributes:
>
>
>    o  The transport supports reliable delivery of data, which NFSv4.1
>       requires but neither NFSv4.1 nor RPC has facilities for ensuring
>       [34].
>
>    o  The transport delivers data in the order it was sent.  Ordered
>       delivery simplifies detection of transmit errors, and simplifies
>       the sending of arbitrary sized requests and responses via the
>       record marking protocol [3].
>
> ...and then some hand-wavy stuff about congestion control. RFC7530
> doesn't mention needing reliable and ordered delivery, but it does need
> congestion control.

Snipping some stuff for a pedantic response :-)

There are several good reasons why RFC7530 does not specify reliable and
ordered. The most obvious being, it doesn't need them. Because it has
a session, it can handle out-of-order messages at its layer. This is in
fact critical to supporting trunking and multipathing. And with the
session comes the ability to detect replays, so reliability can be
obviated there too.

In fact, apart from congestion control, with the proper session support,
NFSv4.1 can run very nicely over an unreliable unordered transport.
Now, NFS4.0, and NFSv3 and NFSv2 before it, are another matter entirely.

Note that RDMA transports provide remote direct placement only in RC
(Reliable Connected) endpoints, which is why rpcrdma uses that mode.

Tom.
