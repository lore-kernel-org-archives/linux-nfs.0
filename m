Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34818 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbcDZTzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 15:55:19 -0400
Subject: Re: [PATCH v2 04/18] xprtrdma: Prevent inline overflow
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192120.3566.99978.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FC7A3.2010407@grimberg.me>
Date: Tue, 26 Apr 2016 22:55:15 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192120.3566.99978.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> When deciding whether to send a Call inline, rpcrdma_marshal_req
> doesn't take into account header bytes consumed by chunk lists.
> This results in Call messages on the wire that are sometimes larger
> than the inline threshold.

I'm not sure I understand why you need to account the chunk list size
when deciding on the inline data size., aren't chunk lists for remote
access only?

Is this a first-burst kind of functionality?

> Likewise, when a Write list or Reply chunk is in play, the server's
> reply has to emit an RDMA Send that includes a larger-than-minimal
> RPC-over-RDMA header.
>
> The actual size of a Call message cannot be estimated until after
> the chunk lists have been registered. Thus the size of each
> RPC-over-RDMA header can be estimated only after chunks are
> registered; but the decision to register chunks is based on the size
> of that header. Chicken, meet egg.

:)

> The best a client can do is estimate header size based on the
> largest header that might occur, and then ensure that inline content
> is always smaller than that.

Isn't that a big loss?
