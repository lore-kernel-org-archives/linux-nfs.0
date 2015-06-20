Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0097.hostedemail.com ([216.40.44.97]:58818 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753651AbbFTAu1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 20:50:27 -0400
Date: Fri, 19 Jun 2015 20:50:24 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bruce James Fields <bfields@fieldses.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150619205024.0ad093f8@gandalf.local.home>
In-Reply-To: <20150619203745.16545a22@gandalf.local.home>
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
	<20150619122553.43d2d86c@gandalf.local.home>
	<20150619131759.7b38d9de@gandalf.local.home>
	<CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
	<20150619155226.7c5d6637@synchrony.poochiereds.net>
	<1434745818.8838.1.camel@primarydata.com>
	<20150619181440.22f54e6a@gandalf.local.home>
	<1434756359.8498.2.camel@primarydata.com>
	<20150619203745.16545a22@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Jun 2015 20:37:45 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:


> > Is it causing any other damage than the rkhunter warning you reported?
> 
> Well, not that I know of. Are you sure that this port will be
> reconnected, and is not just a leak. Not sure if you could waste more
> ports this way with connections to other machines. I only have my
> wife's box connect to this server. This server is actually a client to
> my other boxes.
> 
> Although the rkhunter warning is the only thing that triggers, I still
> would think this is a stable fix, especially if the port is leaked and
> not taken again.

I did some experiments. If I unmount the directories from my wife's
machine and remount them, the port that was hidden is fully closed.
Maybe it's not that big of a deal after all.

-- Steve
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
