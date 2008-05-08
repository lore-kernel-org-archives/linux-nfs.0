From: Christian Robottom Reis <kiko@canonical.com>
Subject: [NFS] Server-side locking issue
Date: Thu, 8 May 2008 19:18:16 -0300
Message-ID: <20080508221815.GB4583@async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56478 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752623AbYEHWdZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 May 2008 18:33:25 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JuEfy-0003ah-Hp
	for linux-nfs@vger.kernel.org; Fri, 09 May 2008 08:33:22 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Today, apparently at random, we had a locking problem on our LAN. Client
applications hung, restarting them led to hangs, and the client dmesgs
showed a familiar:

    [443619.682118] lockd: server anthem not responding, still trying

So the server lockd apparently stopped responding to clients, and
restarting clients got us nowhere. Eventually we cycled the server and
everything's back to normal, but I'm pretty confused as to what
happened. I couldn't scrape any evidence on the server that would point
to why this happened -- no OOPS, error or even warning output.

I was reading through the thread at
http://groups.google.com.br/group/fa.linux.kernel/browse_thread/thread/6c7b5e49a46aef75/91adbb9f298db509?lnk=st&q=nfs+locking+server#91adbb9f298db509
and figured that it might be a similar problem I'm facing, but I'm not
entirely sure as it's hard to say if somebody interrupted a client
program or not (it's a large diskless network).

Clients run 2.6.24-16-generic (stock Ubuntu Hardy) and server is
2.6.22-14-generic (stock Ubuntu Gutsy).

If the problem happens again, what can I do on server and client to
further debug the problem? And is there a utility that clears locks that
we could use to avoid having to restart the server (acking the risks in
cleared locks)?
-- 
Christian Robottom Reis | http://async.com.br/~kiko/ | [+55 16] 3376 0125

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

