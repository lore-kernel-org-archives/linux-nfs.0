From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Server-side locking issue
Date: Fri, 9 May 2008 11:43:05 -0400
Message-ID: <20080509154305.GA798@fieldses.org>
References: <20080508221815.GB4583@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net
To: Christian Robottom Reis <kiko@canonical.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:36099 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754636AbYEIRXr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 May 2008 13:23:47 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JuWJs-0003Jm-3t
	for linux-nfs@vger.kernel.org; Sat, 10 May 2008 03:23:44 +1000
In-Reply-To: <20080508221815.GB4583-Zkq4WM0RTTBfJ/NunPodnw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 08, 2008 at 07:18:16PM -0300, Christian Robottom Reis wrote:
> Today, apparently at random, we had a locking problem on our LAN. Client
> applications hung, restarting them led to hangs, and the client dmesgs
> showed a familiar:
> 
>     [443619.682118] lockd: server anthem not responding, still trying
> 
> So the server lockd apparently stopped responding to clients, and
> restarting clients got us nowhere. Eventually we cycled the server and
> everything's back to normal, but I'm pretty confused as to what
> happened. I couldn't scrape any evidence on the server that would point
> to why this happened -- no OOPS, error or even warning output.
> 
> I was reading through the thread at
> http://groups.google.com.br/group/fa.linux.kernel/browse_thread/thread/6c7b5e49a46aef75/91adbb9f298db509?lnk=st&q=nfs+locking+server#91adbb9f298db509
> and figured that it might be a similar problem I'm facing, but I'm not
> entirely sure as it's hard to say if somebody interrupted a client
> program or not (it's a large diskless network).

I don't think the server stopped responding to clients in the case
Miklos described.

Perhaps a sysrq-T dump of lockd would show where (and whether) it's
blocked?  (So once lockd stops responding, log into the server, run
"echo t >/proc/sysrq-trigger", and collect the output from the logs,
especially the stacktrace for the lockd process).

> 
> Clients run 2.6.24-16-generic (stock Ubuntu Hardy) and server is
> 2.6.22-14-generic (stock Ubuntu Gutsy).
> 
> If the problem happens again, what can I do on server and client to
> further debug the problem? And is there a utility that clears locks that
> we could use to avoid having to restart the server (acking the risks in
> cleared locks)?

If the server lockd has completely stopped responding to lockd requests,
then the problem isn't just a stray file lock.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

