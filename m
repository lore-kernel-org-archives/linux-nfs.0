Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50688 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756062Ab1AaPkv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Jan 2011 10:40:51 -0500
Date: Mon, 31 Jan 2011 10:40:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: server error: fileid changed
Message-ID: <20110131154049.GB30447@fieldses.org>
References: <alpine.LNX.2.01.1011281518090.14665@obet.zrqbmnf.qr>
 <20101128160543.GA18889@fieldses.org>
 <alpine.LNX.2.01.1011281853520.7586@obet.zrqbmnf.qr>
 <20101128181942.GA23535@fieldses.org>
 <alpine.LNX.2.01.1012051540560.7505@obet.zrqbmnf.qr>
 <20101206161701.GD27096@fieldses.org>
 <alpine.LNX.2.01.1101301424370.31459@obet.zrqbmnf.qr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.01.1101301424370.31459@obet.zrqbmnf.qr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Jan 30, 2011 at 02:27:34PM +0100, Jan Engelhardt wrote:
> 
> On Sunday 2010-11-28 19:19, J. Bruce Fields wrote:
> >>>On Sun, Nov 28, 2010 at 03:23:23PM +0100, Jan Engelhardt wrote:
> >>>> Sometime between 2.6.33 and 2.6.36 it seems, knfsd has become really 
> >>>> unreliable, having clients start to emit messages like
> >>>> 
> >>>> (nfsv3)
> >>>> [42306.521225] NFS: server nova error: fileid changed
> >>>> [42306.521226] fsid 0:10: expected fileid 0x1b007be, got 0x1b006b0
> >>>> 
> >>>> On nfsv4, it is even worse, as updates on the server are not
> >>>> immediately reflected on the client like it was the case on
> >>>> nfsv3. Unfortunately, that is all the information I currently
> >>>> have. (Server is on 2.6.36-rc8, client on 2.6.37-rc1.)
> >>>
> >>>Have you really being changing only the server, or have you been
> >>>changing the client at the same time?
> 
> Fast forward. I have now a 2.6.38-rc1+ client with a 2.6.37 server, 
> using nfs4 with ext4. The "fileid changes" messages seem to be gone.

That leaves in the dark about that particular problem.

> I change a file on the server, compile it there, and then would expect 
> the client to pick up the change, but some awkward internal caching 
> mechanism pins the old copy and I don't get, say, new debug messages I 
> have added to my program that was just recompiled.

Remind me what the backend filesystem is?  Also, does

	echo 0 >/proc/sys/fs/leases-enable

on startup fix the problem?

--b.
