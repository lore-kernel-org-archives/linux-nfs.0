From: "Work" <daniel.brunner@duni.com>
Subject: Re: Questions about NFS over TCP
Date: Wed, 23 Apr 2003 13:00:57 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003901c309c2$4b1be2d0$c501d318@doggy>
References: <3EA66B58.2B1E4A45@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.168.147.194] (helo=mkeweb01.duni.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198OYQ-0007Xb-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 11:01:10 -0700
Received: from doggy (CPE-24-211-1-197.wi.rr.com [24.211.1.197])
	by mkeweb01.duni.com (8.11.6/linuxconf) with SMTP id h3NI1vo30584
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 13:01:57 -0500
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello!!

Actually I run NFS over TCP using RH 7.3 with a 2.4.20 recompiled kernel,
and all the clients run Mac OS X 10.2.5.

Besides some performance issues (10 MB/sec...ACK), rebooting the Linux box
doesn't lock up the Macs at all...

UNLESS, they try to access the NFS mount. But if files are open, and the
clients are working with them it's not a problem.

To me, it's better to shutdown all clients, then reboot the Linux box...

But my Linux server never crashes.

:)

So I can't tell you what to expect when that happens....



Dan Brunner



----- Original Message -----
From: <james-p@moving-picture.com>
To: <nfs@lists.sourceforge.net>
Sent: Wednesday, April 23, 2003 5:30 AM
Subject: [NFS] Questions about NFS over TCP


I've just started experimenting with NFS over TCP and have a few
questions:

The Linux NFS-HOWTO states that:

> The disadvantage of using TCP is that it is not a stateless
> protocol like UDP. If your server crashes in the middle of a
> packet transmission, the client will hang and any shares will
> need to be unmounted and remounted.

I take this to mean that any client that is not actively accessing data
on the server at the time of a crash will be OK after the server
reboots?

As, I believe, some other OS's use NFS over TCP by default, how do they
get round this problem (or not)?

What is the 'best' way to get mount to try an TCP mount first - if that
fails, then try a UDP mount - I had a look at the mount source and
hacked in something to do this if the options -o tcp,udp are given - my
hack is very simple, if the TCP mount fails (for whatever reason), the
try a UDP mount - however, I don't know how 'safe' this is ...

Thanks

James Pearson


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
