Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:64183 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbaEELPI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2014 07:15:08 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so5058795qcx.13
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2014 04:15:07 -0700 (PDT)
Date: Mon, 5 May 2014 07:08:12 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: David Rientjes <rientjes@google.com>
Cc: Marc Dietrich <marvin24@gmx.de>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: nfs oom on 3.15
Message-ID: <20140505070812.470c66bd@tlielax.poochiereds.net>
In-Reply-To: <alpine.DEB.2.02.1405050241180.11071@chino.kir.corp.google.com>
References: <2562595.ix17LO7uqe@fb07-iapwap2>
	<alpine.DEB.2.02.1405050241180.11071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 5 May 2014 02:42:35 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Mon, 5 May 2014, Marc Dietrich wrote:
> 
> > Hi,
> > 
> > this is spaming my log quite a bit.
> > 
> > Any idea?
> > 
> 
> I think rpc_malloc() really wants to be __GFP_NOWARN so that the warnings 
> are suppressed, doing order-1 allocations with GFP_NOWAIT is never 
> guaranteed to succeed and will have difficulty if memory is fragmented.  


Yes. We made a similar fix to xprt_alloc_slot a while back. The RPC
engine has a mechanism to handle retrying these allocations, so this
warning isn't particularly helpful.

-- 
Jeff Layton <jlayton@poochiereds.net>
