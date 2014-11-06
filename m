Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:63601 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbaKFV6j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2014 16:58:39 -0500
Received: by mail-qc0-f181.google.com with SMTP id w7so1573210qcr.26
        for <linux-nfs@vger.kernel.org>; Thu, 06 Nov 2014 13:58:38 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 6 Nov 2014 16:58:34 -0500
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] sunrpc: new tracepoints for call/reply tracking
Message-ID: <20141106165834.27863d4c@tlielax.poochiereds.net>
In-Reply-To: <20141106202009.GE22638@fieldses.org>
References: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
	<20141106202009.GE22638@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 6 Nov 2014 15:20:09 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Oct 28, 2014 at 02:24:11PM -0400, Jeff Layton wrote:
> > These patches add some tracepoints that I recently used when tracking
> > down the hang that Christoph reported recently. At this point, I still
> > haven't followed the trail to completion, but I think the problem is
> > not likely to be in the RPC code.
> > 
> > Please consider these for v3.19? Some of these are for client RPC and
> > some for server-side. I'll assume that Trond will merge these, but
> > review by others would be appreciated as well.
> 
> Looks fine to me, thanks, I'll assume Trond's applying all three unless
> I hear otherwise.
> 
> (Separate issue: the server-side rpc dprintk's need review: they're much
> too frequent to be useful, I think.)
> 

Thanks.

Yeah. Probably best to just slowly phase those out in favor of
tracepoints. Is there any way to do that that's less labor intensive?

> --b.
> 
> > 
> > Jeff Layton (3):
> >   sunrpc: add some tracepoints in svc_rqst handling functions
> >   sunrpc: add new tracepoints in xprt handling code
> >   sunrpc: add tracepoints in xs_tcp_data_recv
> > 
> >  include/linux/sunrpc/xprtsock.h |  59 +++++++++++++++
> >  include/trace/events/sunrpc.h   | 160 ++++++++++++++++++++++++++++++++++++++++
> >  net/sunrpc/svc.c                |  21 +++---
> >  net/sunrpc/svc_xprt.c           |  31 +++++---
> >  net/sunrpc/xprt.c               |   9 ++-
> >  net/sunrpc/xprtsock.c           |  69 +++--------------
> >  6 files changed, 269 insertions(+), 80 deletions(-)
> > 
> > -- 
> > 1.9.3
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@primarydata.com>
