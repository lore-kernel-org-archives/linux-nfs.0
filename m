Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50972 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751245AbdKHW31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Nov 2017 17:29:27 -0500
Date: Wed, 8 Nov 2017 17:29:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Bruce Fields <bfields@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] SUNRPC: Improve ordering of transport processing
Message-ID: <20171108222926.GR24262@fieldses.org>
References: <20171010173143.106492-1-trond.myklebust@primarydata.com>
 <20171010173143.106492-2-trond.myklebust@primarydata.com>
 <9D9E2C92-F1FF-4451-800D-54F74D815F7E@oracle.com>
 <20171019203347.GB6186@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171019203347.GB6186@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 04:33:47PM -0400, bfields wrote:
> On Thu, Oct 19, 2017 at 03:38:17PM -0400, Chuck Lever wrote:
> > 
> > > On Oct 10, 2017, at 1:31 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > > 
> > > Since it can take a while before a specific thread gets scheduled, it
> > > is better to just implement a first come first served queue mechanism.
> > > That way, if a thread is already scheduled and is idle, it can pick up
> > > the work to do from the queue.
> > > 
> > > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > Tested-by: Chuck Lever <chuck.lever@oracle.com>
> > 
> > Light performance testing, and a git software build / regression
> > suite run on NFSv4.1. All on NFS/RDMA.
> 
> Thanks!  And sorry for the slow response to this patch, the basic idea
> sounds fine I just haven't found the time to understand the code change
> yet!

Sorry, I'm slow.  Took me a little staring to realize that this:

> > > @@ -380,7 +380,6 @@ void svc_xprt_do_enqueue(struct svc_xprt *xprt)
...
> > > -			/* this one will do */
> > > -			rqstp->rq_xprt = xprt;

is the main change.  We'll let any thread running in svc_recv() pick up
an xprt from the queue rather than assigning an xprt to a specific
thread here in enqueue and then waiting for that specific thread to get
to it.

Makes sense, thanks, applied!

--b.
