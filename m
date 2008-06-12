From: Christian Robottom Reis <kiko@canonical.com>
Subject: Re: [NFS] Server-side locking issue
Date: Thu, 12 Jun 2008 18:43:40 -0300
Message-ID: <20080612214340.GA17293@async.com.br>
References: <20080508221815.GB4583@async.com.br>
	<20080509154305.GA798@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net, Ronaldo Maia <romaia-Zkq4WM0RTTBfJ/NunPodnw@public.gmane.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52482 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757463AbYFLVog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 17:44:36 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K6uat-00054B-Ki
	for linux-nfs@vger.kernel.org; Fri, 13 Jun 2008 07:44:31 +1000
In-Reply-To: <20080509154305.GA798@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 09, 2008 at 11:43:05AM -0400, J. Bruce Fields wrote:
> I don't think the server stopped responding to clients in the case
> Miklos described.

Okay. Well, one month later, it happened again to me.

> Perhaps a sysrq-T dump of lockd would show where (and whether) it's
> blocked?  (So once lockd stops responding, log into the server, run
> "echo t >/proc/sysrq-trigger", and collect the output from the logs,
> especially the stacktrace for the lockd process).

This time I did a ps auxww locking for the lockd process. And guess
what?

root      6323  0.0  0.0      0     0 ?        D    Jun01   0:50 [lockd]

I wonder why it's in the D state. I also wonder if there's a way to get
it back once it's in this state -- without reloading the kernel module
or rebooting, I guess.

I've collected a trace, at any rate, but lockd isn't even listed in it --
I can send it in if it makes sense.

What sort of debugging can I do to figure out what's wrong here?

(This is a dual-Xeon running:

    Linux anthem 2.6.22-14-generic #1 SMP Tue Feb 12 07:42:25 UTC 2008 i686 GNU/Linux)
-- 
Christian Robottom Reis | http://async.com.br/~kiko/ | [+55 16] 3376 0125

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

