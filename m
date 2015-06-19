Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0084.hostedemail.com ([216.40.44.84]:38369 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752636AbbFSDVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 23:21:04 -0400
Date: Thu, 18 Jun 2015 23:21:00 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>, bfields@fieldses.org
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150618232100.78318096@gandalf.local.home>
In-Reply-To: <20150618213702.33f64b20@synchrony.poochiereds.net>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
	<20150618213702.33f64b20@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Jun 2015 21:37:02 -0400
Jeff Layton <jlayton@poochiereds.net> wrote:

> > Note, the box has been rebooted since I posted my last trace.
> > 
> 
> Ahh pity. The port has probably changed...if you trace it again maybe
> try to figure out what it's talking to before rebooting the server?

I could probably re-enable the trace again.

Would it be best if I put back the commits and run it with the buggy
kernel. I could then run these commands after the bug happens and/or
before the port goes away.

 
> Oh! I was thinking that you were seeing this extra port on the
> _client_, but now rereading your original mail I see that it's
> appearing up on the NFS server. Is that correct?

Correct, the bug is on the NFS server, not the client. The client is
already up and running, and had the filesystem mounted when the server
rebooted. I take it that this happened when the client tried to
reconnect.

Just let me know what you would like to do. As this is my main
production server of my local network, I would only be able to do this
a few times. Let me know all the commands and tracing you would like to
have. I'll try it tomorrow (going to bed now).

-- Steve


> 
> So, assuming that this is NFSv4.0, then this port is probably bound
> when the server is establishing the callback channel to the client. So
> we may need to look at how those xprts are being created and whether
> there are differences from a standard client xprt.
> 

