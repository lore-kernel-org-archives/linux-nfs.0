Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41050 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758733Ab0DASAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 14:00:53 -0400
Subject: Re: why does each NFS mount have (at least) 2 rpc_clnt's ?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
In-Reply-To: <20100401132619.24278811@barsoom.rdu.redhat.com>
References: <20100401084620.3475d4c0@barsoom.rdu.redhat.com>
	 <1270127869.3533.12.camel@localhost.localdomain>
	 <20100401132619.24278811@barsoom.rdu.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Apr 2010 14:00:48 -0400
Message-ID: <1270144848.3533.27.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-04-01 at 13:26 -0400, Jeff Layton wrote: 
> That said, I still am not certain I see why we want to have an rpc_clnt
> that's shared between the mounts though clearly there's benefit to
> sharing the xprt between them.

Sharing the xprt is by far the main (and most important) benefit.
Without it, we would have the same mess with running out of privileged
port numbers that we had with the 2.4.x series.

Cheers
  Trond

