From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
Date: Tue, 19 May 2009 11:14:29 -0400
Message-ID: <x498wkt3z1m.fsf@segfault.boston.devel.redhat.com>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50175 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753442AbZESPOf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 May 2009 11:14:35 -0400
In-Reply-To: <20090518214756.786.28129.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org> (Trond
	Myklebust's message of "Mon, 18 May 2009 17:47:56 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> writes:

> I squashed the previous set of 4 incremental patches into 3. Otherwise
> there should be no differences w.r.t. the set that Jeff tested.

I applied your original patches, then reverted these three, and the
resulting tree shows that they are, in fact, the same.

So...

Tested-by: Jeff Moyer <jmoyer@redhat.com>

> ---
>
> Trond Myklebust (3):
>       SUNRPC: Fix svc_tcp_recvfrom()
>       SUNRPC: Fix the TCP write space reservations for deferred requests
>       SUNRPC: Fix the TCP server's send buffer accounting
>
>
>  include/linux/sunrpc/svc.h     |    1 
>  include/linux/sunrpc/svcsock.h |    1 
>  net/sunrpc/svc_xprt.c          |   10 +-
>  net/sunrpc/svcsock.c           |  203 ++++++++++++++++++++++++++++------------
>  4 files changed, 149 insertions(+), 66 deletions(-)
