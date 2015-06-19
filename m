Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0100.hostedemail.com ([216.40.44.100]:36333 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754204AbbFSVuG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 17:50:06 -0400
Date: Fri, 19 Jun 2015 17:50:02 -0400
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
Message-ID: <20150619175002.17a231b1@gandalf.local.home>
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

I unmounted the directories, removed the nfs modules, and then add this
file, and loaded the modules back and remounted the directories.

# netstat -ntap |grep 4048
tcp        0      0 0.0.0.0:4048            0.0.0.0:*               LISTEN      -               
tcp        0      0 192.168.23.22:4048      192.168.23.9:1010       ESTABLISHED -               
tcp6       0      0 :::4048                 :::*                    LISTEN      -               

-- Steve

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
