Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57565 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab0LFQRD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Dec 2010 11:17:03 -0500
Date: Mon, 6 Dec 2010 11:17:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: server error: fileid changed
Message-ID: <20101206161701.GD27096@fieldses.org>
References: <alpine.LNX.2.01.1011281518090.14665@obet.zrqbmnf.qr>
 <20101128160543.GA18889@fieldses.org>
 <alpine.LNX.2.01.1011281853520.7586@obet.zrqbmnf.qr>
 <20101128181942.GA23535@fieldses.org>
 <alpine.LNX.2.01.1012051540560.7505@obet.zrqbmnf.qr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.01.1012051540560.7505@obet.zrqbmnf.qr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Dec 05, 2010 at 03:41:54PM +0100, Jan Engelhardt wrote:
> 
> On Sunday 2010-11-28 19:19, J. Bruce Fields wrote:
> >> >On Sun, Nov 28, 2010 at 03:23:23PM +0100, Jan Engelhardt wrote:
> >> >> Sometime between 2.6.33 and 2.6.36 it seems, knfsd has become really 
> >> >> unreliable, having clients start to emit messages like
> >> >> 
> >> >> (nfsv3)
> >> >> [42306.521225] NFS: server nova error: fileid changed
> >> >> [42306.521226] fsid 0:10: expected fileid 0x1b007be, got 0x1b006b0
> >> >> 
> >> >> On nfsv4, it is even worse, as updates on the server are not immediately 
> >> >> reflected on the client like it was the case on nfsv3.
> >> >> Unfortunately, that is all the information I currently have.
> >> >> (Server is on 2.6.36-rc8, client on 2.6.37-rc1.)
> >> >
> >> >Have you really being changing only the server, or have you been
> >> >changing the client at the same time?
> >> >
> >> >See e.g.
> >> >	http://marc.info/?l=linux-nfs&m=129088225122788&w=2
> >> 
> >> For my definition of not touching the server yes. (There may be
> >> atime updates, but that's about it.)
> >
> >I was asking about kernel versions; so:
> >
> >	client 2.6.37-rc1, server 2.6.33
> >
> >worked, but
> >
> >	client 2.6.37-rc1, server 2.6.36-rc8
> >
> >didn't?
> >
> >It would be worth trying the most recent client patches anyway, as your
> >symptoms look suspiciously similar to those reported recently, and we'd
> >like to rule out the known 2.6.37-rc1 client bugs.
> 
> So me doing what exactly?

I don't understand the question.  You may actually want to wait till the
discussion of the client changes dies down and then try the next -rc.

(But it would still be helpful to have an answer to my question about
kernel versions above.)

> >What filesystem are you exporting?
> 
> ext4.

OK, thanks.--b.
