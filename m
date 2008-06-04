From: "David Konerding" <dakoner@gmail.com>
Subject: Re: [NFS] I/O Errors with hard mounts
Date: Wed, 4 Jun 2008 14:07:25 -0700
Message-ID: <4f0f0cb0806041407r482a152duacb9601193502c@mail.gmail.com>
References: <4f0f0cb0806040633x74fd0afbm94866cf85810f242@mail.gmail.com>
	<20080604121723.5b6a53e6@tleilax.poochiereds.net>
	<4f0f0cb0806041000m7926d1e7m93f71ebaacd6c976@mail.gmail.com>
	<20080604135817.0608273a@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:59661 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbYFDVHi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 17:07:38 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K40Cl-0002Iv-UU
	for linux-nfs@vger.kernel.org; Thu, 05 Jun 2008 07:07:36 +1000
In-Reply-To: <20080604135817.0608273a-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>
> Getting straces of the apps failing might be helpful, particularly if
> it's always in the same syscalls. I have a hunch though that you'll find
> yourself in the twisty maze of RPC code. In that case, knowing the
> particular syscalls might not be that informative.
>
> Looking at network captures might also be helpful. If you can correlate
> the straces with what's going over the wire, then you might be able to
> determine whether this error is being generated as a result of a NFS
> error from the server or something else entirely.
>

One hint is that if I run ls, and hit control-C while it's trolling
through filer directories
(but not local dirs), I get an I/O Error on the command line.  This
may not reproduce our rm
problems (since those don't have Control-C events), but here's the
last part of the strace:

open("src/modules", O_RDONLY|O_NONBLOCK|O_DIRECTORY) = 3
fstat(3, {st_mode=S_IFDIR|0755, st_size=4096, ...}) = 0
fcntl(3, F_SETFD, FD_CLOEXEC)           = 0
getdents64(3, 0x534808, 32768)          = -1 EIO (Input/output error)
--- SIGINT (Interrupt) @ 0 (0) ---

We're trying to reproduce the problem with an uninterrupted rm under strace.

Dave

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

