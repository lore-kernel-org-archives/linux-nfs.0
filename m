Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:36132 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbbFSRjJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 13:39:09 -0400
Received: by ykdr198 with SMTP id r198so97821889ykd.3
        for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2015 10:39:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150619131759.7b38d9de@gandalf.local.home>
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
Date: Fri, 19 Jun 2015 13:39:08 -0400
Message-ID: <CAHQdGtRCYoeToxyDHjnd+6f40J8SrScmQKKOW5O8AzJo3NefAA@mail.gmail.com>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bruce James Fields <bfields@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 19, 2015 at 1:17 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Fri, 19 Jun 2015 12:25:53 -0400
> Steven Rostedt <rostedt@goodmis.org> wrote:
>
>
>> I don't see that 55201 anywhere. But then again, I didn't look for it
>> before the port disappeared. I could reboot and look for it again. I
>> should have saved the full netstat -tapn as well :-/
>
> Of course I didn't find it anywhere, that's the port on my wife's box
> that port 947 was connected to.
>
> Now I even went over to my wife's box and ran
>
>  # rpcinfo -p localhost
>    program vers proto   port  service
>     100000    4   tcp    111  portmapper
>     100000    3   tcp    111  portmapper
>     100000    2   tcp    111  portmapper
>     100000    4   udp    111  portmapper
>     100000    3   udp    111  portmapper
>     100000    2   udp    111  portmapper
>     100024    1   udp  34243  status
>     100024    1   tcp  34498  status
>
> which doesn't show anything.
>
> but something is listening to that port...
>
>  # netstat -ntap |grep 55201
> tcp        0      0 0.0.0.0:55201           0.0.0.0:*               LISTEN


Hang on. This is on the client box while there is an active NFSv4
mount? Then that's probably the NFSv4 callback channel listening for
delegation callbacks.

Can you please try:

echo "options nfs callback_tcpport=4048" > /etc/modprobe.d/nfs-local.conf

and then either reboot the client or unload and then reload the nfs
modules before reattempting the mount. If this is indeed the callback
channel, then that will move your phantom listener to port 4048...

Cheers
   Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
