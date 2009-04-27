From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
 truncated by	the nfs rdma client.
Date: Mon, 27 Apr 2009 14:23:33 -0400
Message-ID: <1240856613.8818.16.camel@heimdal.trondhjem.org>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
	 <49F31A16.2080806@opengridcomputing.com>
	 <49F4AE86.4090908@opengridcomputing.com>
	 <49f515a5.1d1e640a.1c82.6677@mx.google.com>
	 <49F5ED55.1010607@opengridcomputing.com>
	 <1240855510.8818.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Talpey <tmtalpey@gmail.com>, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51464 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbZD0SXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Apr 2009 14:23:39 -0400
In-Reply-To: <1240855510.8818.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-04-27 at 14:05 -0400, Trond Myklebust wrote:
> It looks looks as though the bug is really that the IB code is using a
> u64 to store dma handles. As an external user of the IB api, we really
> shouldn't have to perform this sort of transformation. If it is
> absolutely necessary, then it should be done by means of specialised
> accessor functions to initialise/read iova_start value when given a
> dma_addr_t.
> 
> I'd therefore prefer the no-cast version (with eventual compiler
> warnings), in the hope that eventually the IB folks will fix their
> interface.

Translation: It looks to me as if the interface that we're using is a
bit too corrupted with IB low level implementation grime. In the future,
I'd like to see someone come up with a more high level interface for use
by external code such as the sunrpc module.

Cheers
  Trond

