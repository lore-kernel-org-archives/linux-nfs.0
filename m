Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f52.google.com ([209.85.216.52]:39047 "EHLO
	mail-vn0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbbFTCoa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 22:44:30 -0400
Received: by vnbf7 with SMTP id f7so438028vnb.6
        for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2015 19:44:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150619212706.2f13a44e@gandalf.local.home>
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
	<20150619212706.2f13a44e@gandalf.local.home>
Date: Fri, 19 Jun 2015 22:44:29 -0400
Message-ID: <CAHQdGtQWx8udzG6VT8NwX5eWoDgnfyx7B-n-+75kakXf=a-F1g@mail.gmail.com>
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

On Fri, Jun 19, 2015 at 9:27 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Fri, 19 Jun 2015 19:25:59 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>
>> 8<--------------------------------------------------------------
>> >From 4876cc779ff525b9c2376d8076edf47815e71f2c Mon Sep 17 00:00:00 2001
>> From: Trond Myklebust <trond.myklebust@primarydata.com>
>> Date: Fri, 19 Jun 2015 16:17:57 -0400
>> Subject: [PATCH v2] SUNRPC: Ensure we release the TCP socket once it has been
>>  closed
>>
>> This fixes a regression introduced by commit caf4ccd4e88cf2 ("SUNRPC:
>> Make xs_tcp_close() do a socket shutdown rather than a sock_release").
>> Prior to that commit, the autoclose feature would ensure that an
>> idle connection would result in the socket being both disconnected and
>> released, whereas now only gets disconnected.
>>
>> While the current behaviour is harmless, it does leave the port bound
>> until either RPC traffic resumes or the RPC client is shut down.
>
> Is there a way to test RPC traffic resuming? I'd like to try that before
> declaring this bug harmless.

You should be seeing the same issue if you mount an NFSv3 partition.
After about 5 minutes of inactivity, the client will close down the
connection to the server, and rkhunter should again see the phantom
socket. If you then try to access the partition, the RPC layer should
immediately release the socket and establish a new connection on the
same port.

Cheers
  Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
