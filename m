From: "Erik Hensema / HostingXS Internet Services" <hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
Subject: [NFS] nfs locking problems maybe solved
Date: Wed, 21 May 2008 13:20:35 +0200
Message-ID: <200805211320.35610.hensema@hostingxs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34824 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755205AbYEULVj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 May 2008 07:21:39 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JymO0-0005xy-VD
	for linux-nfs@vger.kernel.org; Wed, 21 May 2008 21:21:37 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I may have solved the locking problems I experience every once in a 
while on my machines. It seems the nfs server needs access to the 
portmapper on the clients. So, I granted access in hosts.allow and 
that seems to have solved a lot of problems.

I experienced two kinds of locking problems:

1) sometimes rrdtool could not lock rrd files

rrdtool runs every 5 minutes on all clients, this problem always 
solved itself

2) sometimes it was impossible to lock any file on an entire 
filesystem and it would be impossible to release those locks even by 
unmounting the filesystem and mounting it again


This morning I started receiving mails from all client machines 
complaining they couldn't lock rrd files. The nfs server was spewing 
the following lines in its log:

May 21 09:25:02 ananke kernel: lockd: server voyager not responding, 
timed out
May 21 09:25:02 ananke kernel: lockd: couldn't create RPC handle for 
voyager

Meanwhile the client said:
May 21 09:09:25 voyager portmap[13799]: connect from 192.168.200.45 to 
getport(nlockmgr): request from unauthorized host

So I granted 192.168.200.45 access to the portmapper on voyager, and 
most clients were unstuck. I updated hosts.allow on most clients to 
grant access to the portmapper now.

Now I still have about 4 clients which can't lock rrd files. Umounting 
the filesystem doesn't help. Umounting the filesystem for about 10 
minutes doesn't help. So, I remounted the fs nolock on these 
machines.

So, now I've got problem #2 on these clients on the filesystem 
containing rrd files. Never had that before.

Problem #2 was always on the mail spool. Not sure if the problem is 
still there, however currently the clients do seem to be able to lock 
mailboxes.

I think problem #1 is gone now, I haven't received any mails of 
servers not being able to lock rrd files anymore, except for the 4 
clients which are never ever able to lock those files.


So, in short: locking is still unreliable for me, but the situation 
has improved.

Everything is NFSv3 by the way. Most clients are opensuse 10.2 (kernel 
2.6.18.8), server is opensuse 10.3 (kernel 2.6.22.17).


Met vriendelijke groet,


Erik Hensema
-- 
HostingXS
eXcellent Service

Telefoon: 024 - 324 91 77
E-mail:   hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org
Website:  http://www.hostingxs.nl/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

