Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:40157 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753504Ab1A3N1g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 30 Jan 2011 08:27:36 -0500
Date: Sun, 30 Jan 2011 14:27:34 +0100 (CET)
From: Jan Engelhardt <jengelh@medozas.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: server error: fileid changed
In-Reply-To: <20101206161701.GD27096@fieldses.org>
Message-ID: <alpine.LNX.2.01.1101301424370.31459@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011281518090.14665@obet.zrqbmnf.qr> <20101128160543.GA18889@fieldses.org> <alpine.LNX.2.01.1011281853520.7586@obet.zrqbmnf.qr> <20101128181942.GA23535@fieldses.org> <alpine.LNX.2.01.1012051540560.7505@obet.zrqbmnf.qr>
 <20101206161701.GD27096@fieldses.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sunday 2010-11-28 19:19, J. Bruce Fields wrote:
>>>On Sun, Nov 28, 2010 at 03:23:23PM +0100, Jan Engelhardt wrote:
>>>> Sometime between 2.6.33 and 2.6.36 it seems, knfsd has become really 
>>>> unreliable, having clients start to emit messages like
>>>> 
>>>> (nfsv3)
>>>> [42306.521225] NFS: server nova error: fileid changed
>>>> [42306.521226] fsid 0:10: expected fileid 0x1b007be, got 0x1b006b0
>>>> 
>>>> On nfsv4, it is even worse, as updates on the server are not
>>>> immediately reflected on the client like it was the case on
>>>> nfsv3. Unfortunately, that is all the information I currently
>>>> have. (Server is on 2.6.36-rc8, client on 2.6.37-rc1.)
>>>
>>>Have you really being changing only the server, or have you been
>>>changing the client at the same time?

Fast forward. I have now a 2.6.38-rc1+ client with a 2.6.37 server, 
using nfs4 with ext4. The "fileid changes" messages seem to be gone.

I change a file on the server, compile it there, and then would expect 
the client to pick up the change, but some awkward internal caching 
mechanism pins the old copy and I don't get, say, new debug messages I 
have added to my program that was just recompiled.
