From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
 truncated by	the nfs rdma client.
Date: Mon, 11 May 2009 18:50:03 -0400
Message-ID: <1242082203.1743.11.camel@heimdal.trondhjem.org>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
	 <49F31A16.2080806@opengridcomputing.com>
	 <49F4AE86.4090908@opengridcomputing.com>
	 <49f515a5.1d1e640a.1c82.6677@mx.google.com>
	 <49F5ED55.1010607@opengridcomputing.com>
	 <1240855510.8818.9.camel@heimdal.trondhjem.org>
	 <1240856613.8818.16.camel@heimdal.trondhjem.org>
	 <49F60845.4010007@opengridcomputing.com>
	 <1240865214.8818.73.camel@heimdal.trondhjem.org>
	 <4A08A5C6.7040003@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tom Talpey <tmtalpey@gmail.com>, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55305 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbZEKWuI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 May 2009 18:50:08 -0400
In-Reply-To: <4A08A5C6.7040003@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-05-11 at 17:25 -0500, Steve Wise wrote:
> Hey Trond,
> 
> Will this bug fix make 2.6.30?
> 
> Thanks,
> 
> Steve.

Not in the form it is in now. As I've said earlier, I'm not happy about
the sunrpc layer having to circumvent ordinary type checking on
non-sunrpc structures.

Cheers
    Trond

