Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0199.hostedemail.com ([216.40.44.199]:58515 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932781AbbHZUaV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 16:30:21 -0400
Date: Wed, 26 Aug 2015 16:30:18 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Pratyush Anand <panand@redhat.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@primarydata.com>,
        linux-kernel@vger.kernel.org (open list),
        Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/2] net: sunrpc: fix trace print of &xprt->xpt_remote
Message-ID: <20150826163018.3c86a35b@gandalf.local.home>
In-Reply-To: <20150826063255.3cdd5475@tlielax.poochiereds.net>
References: <cover.1440482404.git.panand@redhat.com>
	<3e2f763f7701d7ff6915b52a3c80fd1f550ae951.1440482404.git.panand@redhat.com>
	<20150826063255.3cdd5475@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 26 Aug 2015 06:32:55 -0400
Jeff Layton <jlayton@poochiereds.net> wrote:

 
> >  	TP_fast_assign(
> > -		__entry->xprt = xprt,
> > -		xprt ? memcpy(&__entry->ss, &xprt->xpt_remote, sizeof(__entry->ss)) : memset(&__entry->ss, 0, sizeof(__entry->ss));
> > +		__entry->xprt = xprt;
> > +		__entry->addr =
> > +			xprt ? (struct sockaddr *)&xprt->xpt_remote : NULL;
> 
> NAK, this is wrong. %pIScp will dereference that address so you don't

Ug, I hate that printk option. It can be dangerous.

> want to pass a NULL pointer to it. We do want to save a copy of the
> sockaddr.

Save just enough for what you need to print out. Don't waste any space
on the ring buffer that isn't necessary.

-- Steve

> 
> >  		__entry->flags = xprt ? xprt->xpt_flags : 0;
> >  	),
> >  
> >  	TP_printk("xprt=0x%p addr=%pIScp flags=%s", __entry->xprt,
> > -		(struct sockaddr *)&__entry->ss,
> > -		show_svc_xprt_flags(__entry->flags))
> > +		__entry->addr, show_svc_xprt_flags(__entry->flags))
> >  );
> >  
> >  TRACE_EVENT(svc_wake_up,
> 
> 

