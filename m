From: James Pearson <james-p@moving-picture.com>
Subject: Questions about NFS over TCP
Date: Wed, 23 Apr 2003 11:30:48 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EA66B58.2B1E4A45@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198HXf-0007zz-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 03:31:55 -0700
Received: from darke.mpc.local ([172.16.11.6] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 3.22 #1)
	id 198HWa-0002gl-00
	for nfs@lists.sourceforge.net; Wed, 23 Apr 2003 11:30:48 +0100
To: nfs@lists.sourceforge.net
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
