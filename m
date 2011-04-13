Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58865 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753556Ab1DMOWP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Apr 2011 10:22:15 -0400
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        khoa@us.ibm.com
In-Reply-To: <20110413100228.680ace66@tlielax.poochiereds.net>
References: <1302622335.3877.62.camel@badari-desktop>
	 <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com>
	 <1302624935.3877.66.camel@badari-desktop>
	 <FF1EE11E-62EB-42B9-A4C9-7A2FE4C60D2F@oracle.com>
	 <1302630360.3877.72.camel@badari-desktop>
	 <20110413083656.12e54a91@tlielax.poochiereds.net>
	 <4DA5A899.3040202@us.ibm.com>
	 <20110413100228.680ace66@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 13 Apr 2011 10:22:13 -0400
Message-ID: <1302704533.8571.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-04-13 at 10:02 -0400, Jeff Layton wrote:
> We could put the rpc_rqst's into a slabcache, and give each rpc_xprt a
> mempool with a minimum number of slots. Have them all be allocated with
> GFP_NOWAIT. If it gets a NULL pointer back, then the task can sleep on
> the waitqueue like it does today. Then, the clients can allocate
> rpc_rqst's as they need as long as memory holds out for it.
> 
> We have the reserve_xprt stuff to handle congestion control anyway so I
> don't really see the value in the artificial limits that the slot table
> provides.
> 
> Maybe I should hack up a patchset for this...

This issue has come up several times recently. My preference would be to
tie the availability of slots to the TCP window size, and basically say
that if the SOCK_ASYNC_NOSPACE flag is set on the socket, then we hold
off allocating more slots until we get a ->write_space() callback which
clears that flag.

For the RDMA case, we can continue to use the current system of a fixed
number of preallocated slots.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

