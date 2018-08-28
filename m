Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:55858 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726669AbeH1JJl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2018 05:09:41 -0400
Date: Tue, 28 Aug 2018 07:19:42 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] xprtrdma: Fix disconnect regression
Message-ID: <20180828051942.GE2107@kroah.com>
References: <20180827232321.12635.40263.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180827232321.12635.40263.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 27, 2018 at 07:29:27PM -0400, Chuck Lever wrote:
> I found that injecting disconnects with v4.18-rc resulted in
> random failures of the multi-threaded git regression test.
> 
> The root cause appears to be that, after a reconnect, the
> RPC/RDMA transport is waking pending RPCs before the transport has
> posted enough Receive buffers to receive the Replies. If a Reply
> arrives before enough Receive buffers are posted, the connection
> is dropped. A few connection drops happen in quick succession as
> the client and server struggle to regain credit synchronization.
> 
> This regression was introduced with commit 7c8d9e7c8863 ("xprtrdma:
> Move Receive posting to Receive handler"). The client is supposed to
> post a single Receive when a connection is established because
> it's not supposed to send more than one RPC Call before it gets
> a fresh credit grant in the first RPC Reply [RFC 8166, Section
> 3.3.3].
> 
> Unfortunately there appears to be a longstanding bug in the Linux
> client's credit accounting mechanism. On connect, it simply dumps
> all pending RPC Calls onto the new connection. It's possible it has
> done this ever since the RPC/RDMA transport was added to the kernel
> ten years ago.
> 
> Servers have so far been tolerant of this bad behavior. Currently no
> server implementation ever changes its credit grant over reconnects,
> and servers always repost enough Receives before connections are
> fully established.
> 
> The Linux client implementation used to post a Receive before each
> of these Calls. This has covered up the flooding send behavior.
> 
> I could try to correct this old bug so that the client sends exactly
> one RPC Call and waits for a Reply. Since we are so close to the
> next merge window, I'm going to instead provide a simple patch to
> post enough Receives before a reconnect completes (based on the
> number of credits granted to the previous connection).
> 
> The spurious disconnects will be gone, but the client will still
> send multiple RPC Calls immediately after a reconnect.
> 
> Addressing the latter problem will wait for a merge window because
> a) I expect it to be a large change requiring lots of testing, and
> b) obviously the Linux client has interoperated successfully since
> day zero while still being broken.
> 
> Fixes: 7c8d9e7c8863 ("xprtrdma: Move Receive posting to ... ")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> Hi stable@ -
> 
> This fix has been merged into v4.19 as upstream commit 8d4fb8ff427a
> ("xprtrdma: Fix disconnect regression"). It addresses a regression
> in v4.18. I expected it to go into late v4.18-rc, which is why there
> is no "cc: stable" on the original submission.
> 
> Could you please apply it to 4.18.y ? Thank you!

That commit does have a cc: stable in it, it is in my very large queue
of patches to apply...

thanks,

greg k-h
