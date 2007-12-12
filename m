From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC][PATCH] SUNRPC xptrdma: simplify build configuration
Date: Wed, 12 Dec 2007 12:59:23 -0500
Message-ID: <EXNANE01pB8JPGbFqTn00000b38@exnane01.hq.netapp.com>
References: <Pine.LNX.4.64.0712121059260.12638@jlentini-linux.nane.netapp.com>
 <5A1B985E-0098-488C-8724-2E0C017FC764@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: James Lentini <jlentini@netapp.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41249 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962AbXLLSCW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2007 13:02:22 -0500
In-Reply-To: <5A1B985E-0098-488C-8724-2E0C017FC764@oracle.com>
References: <Pine.LNX.4.64.0712121059260.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
 <5A1B985E-0098-488C-8724-2E0C017FC764@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 12:52 PM 12/12/2007, Chuck Lever wrote:
>That's a step in the right direction, IMO.
>
>SUNRPC is always enabled (M or Y) if either the NFS client or server  
>are requested.  So, is the intent then always to build the RPC RDMA  
>transport module if NFS and INFINIBAND are enabled?

Yep, just like the sockets transport. Of course, the transport won't
be used unless a "mount -o rdma" is done on the client, or the rdma
port node below /proc is admin-configured on the server.

Tom.
