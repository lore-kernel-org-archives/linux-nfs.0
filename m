Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0052.hostedemail.com ([216.40.44.52]:46400 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752333AbcGAXRs convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jul 2016 19:17:48 -0400
Date: Fri, 1 Jul 2016 19:17:45 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "Eric Dumazet" <eric.dumazet@gmail.com>,
        Schumaker Anna <anna.schumaker@netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Fields Bruce <bfields@fieldses.org>,
        Torvalds Linus <torvalds@linux-foundation.org>
Subject: Re: Revert: SUNRPC: xs_sock_mark_closed() does not need to trigger
 socket autoclose
Message-ID: <20160701191745.58ba1ef6@gandalf.local.home>
In-Reply-To: <CB98840B-1CEE-48C6-9ABB-82DA8D213BAF@primarydata.com>
References: <20160701172401.3ba89015@gandalf.local.home>
	<0A51DE9E-81B2-474A-BA07-55C3BE19629A@primarydata.com>
	<20160701183912.1f9d376b@gandalf.local.home>
	<CB98840B-1CEE-48C6-9ABB-82DA8D213BAF@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 1 Jul 2016 23:02:23 +0000
Trond Myklebust <trondmy@primarydata.com> wrote:

> Can we look into why the socket disconnect is happening in the first
> place? It’s presumably not the server, since that _would_ trigger an
> autoclose when the socket hits TCP_CLOSE_WAIT. That puts the two top
> suspects being the TCP keepalive and the TCP_USER_TIMEOUT. Are there
> any tracepoints we could use to look at whether or not they are
> triggering a close?

There's not many tracepoints, but from my previous emails I added some
trace_printk()s and converted some of your debug prints into
trace_printk():


+#undef dprintk
+#undef dprintk_rcu
+#define dprintk(args...)       trace_printk(args)
+#define dprintk_rcu(args...)   trace_printk(args)


See my previous email that describes all this (I removed the debugging
from my kernel, and I need to spend time with the family so I can't get
to this again till Tuesday)

http://lkml.kernel.org/r/20160630175618.51a725ee@gandalf.local.home

-- Steve
