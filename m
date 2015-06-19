Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f52.google.com ([209.85.213.52]:35987 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581AbbFSTwc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 15:52:32 -0400
Received: by yhan67 with SMTP id n67so84437441yha.3
        for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2015 12:52:31 -0700 (PDT)
Date: Fri, 19 Jun 2015 15:52:26 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bruce James Fields <bfields@fieldses.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150619155226.7c5d6637@synchrony.poochiereds.net>
In-Reply-To: <CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Jun 2015 13:39:08 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Fri, Jun 19, 2015 at 1:17 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> > On Fri, 19 Jun 2015 12:25:53 -0400
> > Steven Rostedt <rostedt@goodmis.org> wrote:
> >
> >
> >> I don't see that 55201 anywhere. But then again, I didn't look for it
> >> before the port disappeared. I could reboot and look for it again. I
> >> should have saved the full netstat -tapn as well :-/
> >
> > Of course I didn't find it anywhere, that's the port on my wife's box
> > that port 947 was connected to.
> >
> > Now I even went over to my wife's box and ran
> >
> >  # rpcinfo -p localhost
> >    program vers proto   port  service
> >     100000    4   tcp    111  portmapper
> >     100000    3   tcp    111  portmapper
> >     100000    2   tcp    111  portmapper
> >     100000    4   udp    111  portmapper
> >     100000    3   udp    111  portmapper
> >     100000    2   udp    111  portmapper
> >     100024    1   udp  34243  status
> >     100024    1   tcp  34498  status
> >
> > which doesn't show anything.
> >
> > but something is listening to that port...
> >
> >  # netstat -ntap |grep 55201
> > tcp        0      0 0.0.0.0:55201           0.0.0.0:*               LISTEN
> 
> 
> Hang on. This is on the client box while there is an active NFSv4
> mount? Then that's probably the NFSv4 callback channel listening for
> delegation callbacks.
> 
> Can you please try:
> 
> echo "options nfs callback_tcpport=4048" > /etc/modprobe.d/nfs-local.conf
> 
> and then either reboot the client or unload and then reload the nfs
> modules before reattempting the mount. If this is indeed the callback
> channel, then that will move your phantom listener to port 4048...
> 

Right, it was a little unclear to me before, but it now seems clear
that the callback socket that the server is opening to the client is
the one squatting on the port.

...and that sort of makes sense, doesn't it? That rpc_clnt will stick
around for the life of the client's lease, and the rpc_clnt binds to a
particular port so that it can reconnect using the same one.

Given that Stephen has done the legwork and figured out that reverting
those commits fixes the issue, then I suspect that the real culprit is
caf4ccd4e88cf2.

The client is likely closing down the other end of the callback
socket when it goes idle. Before that commit, we probably did an
xs_close on it, but now we're doing a xs_tcp_shutdown and that leaves
the port bound.

I'm travelling this weekend and am not set up to reproduce it to
confirm, but that does seem to be a plausible scenario.
-- 
Jeff Layton <jlayton@poochiereds.net>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
