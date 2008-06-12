From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] Server-side locking issue
Date: Thu, 12 Jun 2008 19:50:40 -0400
Message-ID: <20080612195040.7f68f16e@tleilax.poochiereds.net>
References: <20080508221815.GB4583@async.com.br>
	<20080509154305.GA798@fieldses.org>
	<20080612214340.GA17293@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS@lists.sourceforge.net, Ronaldo Maia <romaia-Zkq4WM0RTTBfJ/NunPodnw@public.gmane.org>
To: Christian Robottom Reis <kiko@canonical.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56844 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035AbYFLXvQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 19:51:16 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K6wZW-0005NN-OP
	for linux-nfs@vger.kernel.org; Fri, 13 Jun 2008 09:51:14 +1000
In-Reply-To: <20080612214340.GA17293-Zkq4WM0RTTBfJ/NunPodnw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 12 Jun 2008 18:43:40 -0300
Christian Robottom Reis <kiko@canonical.com> wrote:

> On Fri, May 09, 2008 at 11:43:05AM -0400, J. Bruce Fields wrote:
> > I don't think the server stopped responding to clients in the case
> > Miklos described.
> 
> Okay. Well, one month later, it happened again to me.
> 
> > Perhaps a sysrq-T dump of lockd would show where (and whether) it's
> > blocked?  (So once lockd stops responding, log into the server, run
> > "echo t >/proc/sysrq-trigger", and collect the output from the logs,
> > especially the stacktrace for the lockd process).
> 
> This time I did a ps auxww locking for the lockd process. And guess
> what?
> 
> root      6323  0.0  0.0      0     0 ?        D    Jun01   0:50 [lockd]
> 
> I wonder why it's in the D state. I also wonder if there's a way to get
> it back once it's in this state -- without reloading the kernel module
> or rebooting, I guess.
> 
> I've collected a trace, at any rate, but lockd isn't even listed in it --
> I can send it in if it makes sense.
> 

That's not atypical at all. syslog uses unreliable transport. When you
send it a flood of data (say, with a sysrq-t) some of it can be lost.
Usually I recommend dumping the data straight out of the ring buffer
from a sysrq-t:

    # dmesg > /tmp/sysrq-t.out

...or something. You might still lose stuff that got pushed out of the
ring buffer, but the stuff that is there will at least be complete.

> What sort of debugging can I do to figure out what's wrong here?
> 

You'll really need that sysrq-t info...or a core dump, or to run a
debugger on the running kernel (like Wendy recommended).

> (This is a dual-Xeon running:
> 
>     Linux anthem 2.6.22-14-generic #1 SMP Tue Feb 12 07:42:25 UTC 2008 i686 GNU/Linux)

There were some patches that went into 2.6.25 (I think) that fix
problems that could cause lockd to hang in some cases. This patch,
in particular, may be of interest:

Subject: [PATCH 1/4] NLM: set RPC_CLNT_CREATE_NOPING for NLM RPC clients

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

