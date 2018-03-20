Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44090 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751480AbeCTVho (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Mar 2018 17:37:44 -0400
Date: Tue, 20 Mar 2018 17:37:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Three short subjects for v4.17
Message-ID: <20180320213744.GE4288@fieldses.org>
References: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180320210219.13273.89049.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Tue, Mar 20, 2018 at 05:05:04PM -0400, Chuck Lever wrote:
> I have a bunch of patches left, but it looks like -rc7 is going to
> be the last -rc, and you are working on read delegation. So let's
> draw to a close with these three simple fixes, and I can postpone
> the rest until v4.18.
> 
> ---
> 
> Chuck Lever (3):
>       svcrdma: Use pr_err to report Receive errors
>       svcrdma: Consult max_qp_init_rd_atom when accepting connections
>       svcrdma: Clean up rdma_build_arg_xdr
> 
> 
>  net/sunrpc/xprtrdma/svc_rdma.c           |    4 ++--
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   33 +++++++++++++++---------------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   28 +++++++++++--------------
>  3 files changed, 30 insertions(+), 35 deletions(-)
> 
> --
> Chuck Lever
