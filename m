From: Sander Smeenk <ssmeenk@freshdot.net>
Subject: Re: rpc.mountd --manage-gids breaks on UID differences
Date: Thu, 26 Nov 2009 10:16:58 +0100
Message-ID: <20091126091657.GL15295@dot.freshdot.net>
References: <20091117153928.GA12493@dot.freshdot.net> <20091117200831.GA3969@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.229.18]:44554 "EHLO dot.freshdot.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759078AbZKZJnq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Nov 2009 04:43:46 -0500
In-Reply-To: <20091117200831.GA3969@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

** Sorry for messing up the thread - My mailconfig started rejecting
mail from vger.kernel.org for which i am eternally sorry. This message
i'm replying to was copied from marc.info **

Quoting J. Bruce Fields (bfields@fieldses.org):

> > The timeframe described above matches the lines from the beginning
> > up to 3732517.859721 in the server debug log[2]. I'd have to dig in
> > the kernel code to find out what lines 3732513.221898 through
> > 3732513.221913 exactly tell me.
> > Is anyone on this list an RPC-code ninja?
>
> I don't think there's anything interesting in there.
> If you do:
> 
> 	date +%s >/proc/net/rpc/auth.unix.gid/flush
> 	strace -e trace=read,write -s4096 -p`pidof rpc.mountd` 
> 
> then do whatever you do the client to reproduce the problem, the
> resulting strace output might be interesting.

This is the result of said strace. Server's auth.unix.gid was flushed,
client reboots and auto-mounts the NFS-share:

| [ .. ]
| read(12, "172.17.145.222:/mnt/data/exports/application:0x00000009\n", 4096) = 56
| write(12, "172.17.145.222:/mnt/data/exports/application:0x0000000a\n", 56) = 56
| read(4, "0\n", 2048)                    = 2
| write(4, "0 1259227707 1 0 \n", 18)     = 18

Again i flushed auth.unix.gid and directly accessed a file as root from
the client:

| read(4, "0\n", 2048)                    = 2
| write(4, "0 1259227903 1 0 \n", 18)     = 18

This works as expected, file contents returned. Again i flushed
auth.unix.gid and switched to the user with the mismatching uid on the
server & client, accessed the exact same file directly:

| read(4, "1002\n", 2048)                 = 5
| write(4, "1002 1259227918 \n", 17)      = -1 EINVAL (Invalid argument)

These two lines repeat at a very slow interval while the client retries:

| read(4, "1002\n", 2048)                 = 5
| write(4, "1002 1259228098 \n", 17)      = -1 EINVAL (Invalid argument)
| read(4, "1002\n", 2048)                 = 5
| write(4, "1002 1259228278 \n", 17)      = -1 EINVAL (Invalid argument)

Filedescriptor 4 for the rpc.mountd process is connected to
/proc/net/rpc/auth.unix.gid/channel. After this user has tried to access
the file, NFS-operation stalls for all users on the client.

> I can't reproduce the problem with nfs-utils from karmic
> (1:1.1.4-1ubuntu1) and a recent kernel.

Well, i've never ever seen this before either. It seems like it has been
introduced with some of the more recent updates to either the kernel or
the nfs-utils contained in Ubuntu Hardy 8.04.3 LTS.

HTH, with regards,
-Sander.
-- 
| When everything is coming your way, you're in the wrong lane.
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
