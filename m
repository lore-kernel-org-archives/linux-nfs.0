From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
 truncated by	the nfs rdma client.
Date: Mon, 27 Apr 2009 16:46:54 -0400
Message-ID: <1240865214.8818.73.camel@heimdal.trondhjem.org>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
	 <49F31A16.2080806@opengridcomputing.com>
	 <49F4AE86.4090908@opengridcomputing.com>
	 <49f515a5.1d1e640a.1c82.6677@mx.google.com>
	 <49F5ED55.1010607@opengridcomputing.com>
	 <1240855510.8818.9.camel@heimdal.trondhjem.org>
	 <1240856613.8818.16.camel@heimdal.trondhjem.org>
	 <49F60845.4010007@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Talpey <tmtalpey@gmail.com>, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44347 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219AbZD0UrB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Apr 2009 16:47:01 -0400
In-Reply-To: <49F60845.4010007@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-04-27 at 14:32 -0500, Steve Wise wrote:
> Clarification:  The iova_start isn't used to store dma handles.  The 
> iova_start is the "address" base value that is advertised to a peer to 
> describe the base address of a memory region.  The contents of that can 
> be more than just a dma handle...its up to the application.  For 
> instance, you could advertise a iova_start of zero or a kernel VA as the 
> rdma server does.  Also, the type is u64 because that is the size used 
> on the wire as part of the rdma (IB and iWARP) protocols. 

OK, but my point is we shouldn't be having this discussion at all. I
shouldn't be required to know that the wire protocol uses a 64-bit
unsigned little-endian/big endian integer in order to use the rdma api.

All I should need to know is that I can advertise either dma handles or
kernel VAs, and know that I can choose between two functions, say,
ib_send_wr_fastreg_dma_init() and ib_send_wr_fastreg_kva_init() to
initialise the ib_send_wr structure correctly.

Trond

