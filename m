Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:51808 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756077Ab0LEOl6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Dec 2010 09:41:58 -0500
Date: Sun, 5 Dec 2010 15:41:54 +0100 (CET)
From: Jan Engelhardt <jengelh@medozas.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: linux-nfs@vger.kernel.org
Subject: Re: NFS: server error: fileid changed
In-Reply-To: <20101128181942.GA23535@fieldses.org>
Message-ID: <alpine.LNX.2.01.1012051540560.7505@obet.zrqbmnf.qr>
References: <alpine.LNX.2.01.1011281518090.14665@obet.zrqbmnf.qr> <20101128160543.GA18889@fieldses.org> <alpine.LNX.2.01.1011281853520.7586@obet.zrqbmnf.qr> <20101128181942.GA23535@fieldses.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sunday 2010-11-28 19:19, J. Bruce Fields wrote:
>> >On Sun, Nov 28, 2010 at 03:23:23PM +0100, Jan Engelhardt wrote:
>> >> Sometime between 2.6.33 and 2.6.36 it seems, knfsd has become really 
>> >> unreliable, having clients start to emit messages like
>> >> 
>> >> (nfsv3)
>> >> [42306.521225] NFS: server nova error: fileid changed
>> >> [42306.521226] fsid 0:10: expected fileid 0x1b007be, got 0x1b006b0
>> >> 
>> >> On nfsv4, it is even worse, as updates on the server are not immediately 
>> >> reflected on the client like it was the case on nfsv3.
>> >> Unfortunately, that is all the information I currently have.
>> >> (Server is on 2.6.36-rc8, client on 2.6.37-rc1.)
>> >
>> >Have you really being changing only the server, or have you been
>> >changing the client at the same time?
>> >
>> >See e.g.
>> >	http://marc.info/?l=linux-nfs&m=129088225122788&w=2
>> 
>> For my definition of not touching the server yes. (There may be
>> atime updates, but that's about it.)
>
>I was asking about kernel versions; so:
>
>	client 2.6.37-rc1, server 2.6.33
>
>worked, but
>
>	client 2.6.37-rc1, server 2.6.36-rc8
>
>didn't?
>
>It would be worth trying the most recent client patches anyway, as your
>symptoms look suspiciously similar to those reported recently, and we'd
>like to rule out the known 2.6.37-rc1 client bugs.

So me doing what exactly?

>What filesystem are you exporting?

ext4.
