Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37469 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbFSX0W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2015 19:26:22 -0400
Received: by igblr2 with SMTP id lr2so23000225igb.0
        for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2015 16:26:21 -0700 (PDT)
Message-ID: <1434756359.8498.2.camel@primarydata.com>
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
Date: Fri, 19 Jun 2015 19:25:59 -0400
In-Reply-To: <20150619181440.22f54e6a@gandalf.local.home>
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
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2015-06-19 at 18:14 -0400, Steven Rostedt wrote:
> On Fri, 19 Jun 2015 16:30:18 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > Steven, how about something like the following patch?
> > 
> 
> OK, the box I'm running this on is using v4.0.5, can you make a patch
> based on that, as whatever you make needs to go to stable as well.

Is it causing any other damage than the rkhunter warning you reported?

> distcc[31554] ERROR: compile /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c on fedora/8 failed
> distcc[31554] (dcc_build_somewhere) Warning: remote compilation of 
> '/home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c' failed, retrying locally
> distcc[31554] Warning: failed to distribute 
> /home/rostedt/work/git/nobackup/linux-build.git/net/sunrpc/xprtsock.c 
> to fedora/8, running locally instead
> /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c: In function 'xs_tcp_shutdown':
> /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c:643:3: error: implicit declaration 
> of function 'xs_reset_transport' [-Werror=implicit-function
> -declaration]
> /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c: At top level:
> /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c:825:13: warning: conflicting types 
> for 'xs_reset_transport' [enabled by default]
> /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c:825:13: error: static declaration of 
> 'xs_reset_transport' follows non-static declaration
> /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c:643:3: note: previous implicit 
> declaration of 'xs_reset_transport' was here
> cc1: some warnings being treated as errors
> distcc[31554] ERROR: compile /home/rostedt/work/git/nobackup/linux
> -build.git/net/sunrpc/xprtsock.c on localhost failed
> /home/rostedt/work/git/nobackup/linux
> -build.git/scripts/Makefile.build:258: recipe for target 
> 'net/sunrpc/xprtsock.o' failed
> make[3]: *** [net/sunrpc/xprtsock.o] Error 1

Sorry. I sent that one off too quickly. Try the following.

8<--------------------------------------------------------------
