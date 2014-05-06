Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353AbaEFT1a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 15:27:30 -0400
Date: Tue, 6 May 2014 15:27:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Subject: Re: [PATCH V2 RFC 0/3] svcrdma: refactor marshalling logic
Message-ID: <20140506192730.GK18281@fieldses.org>
References: <20140506174621.18208.24242.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140506174621.18208.24242.stgit@build.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 06, 2014 at 12:46:21PM -0500, Steve Wise wrote:
> This patch series refactors the NFSRDMA server marshalling logic to
> remove the intermediary map structures.  It also fixes an existing bug
> where the NFSRDMA server was not minding the device fast register page
> list length limitations.
> 
> I've also made a git repo available with these patches on top of 3.15-rc4:
> 
> git://git.openfabrics.org/~swise/linux svcrdma-refactor
> 
> Changes since V1:
> 
> - fixed regression for devices that don't support FRMRs (see
>   rdma_read_chunk_lcl())
> 
> - split patch up for closer review.  However I request it be squashed
>   before merging as they is not bisectable, and I think these changes
>   should all be a single commit anyway.

If it's not split up in a way that's bisectable, then yes, just don't
bother.

--b.

> 
> Please review, and test if you can.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> 
> ---
> 
> Tom Tucker (3):
>       svcrdma: Sendto changes
>       svcrdma: Recvfrom changes
>       svcrdma: Transport and header file changes
> 
> 
>  include/linux/sunrpc/svc_rdma.h          |    3 
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  633 ++++++++++++------------------
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  230 +----------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   62 ++-
>  4 files changed, 318 insertions(+), 610 deletions(-)
> 
> -- 
> 
> Steve / Tom
