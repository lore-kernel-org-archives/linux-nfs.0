From: Eric Whiting <ewhiting@amis.com>
Subject: nobody -2 problems linux nfs client -- VMS multinet NFS server
Date: Wed, 26 Jun 2002 11:14:16 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D19F668.B62C14D8@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dermis.amis.com ([207.141.5.253])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NGN0-0004Wx-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 10:14:18 -0700
Received: from pop1.amis.com (pop1.amis.com [172.16.89.10])
	by kinport.pc.amis.com (8.11.6/8.11.6/SuSE Linux 0.5) with ESMTP id g5QHE2L12279
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 11:14:02 -0600
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I think I'm seeing a uid wrap/overflow problem in the linux nfs client
or userid libc stuff -- but it might be in the VMS NFS server...

SERVER: VMS multinet NFS server

CLIENT: 2.2.18 linux works ok with the 'nobody' account.

nobody@ogre:/home/falcon > ls -la |grep phurst
dr-x------   2 nobody   nogroup    199680 Jun 26 11:07 phurst

I can list this dir and access files in it.


CLIENT: 2.4.18 linux doesn't work with the 'nobody' account.

nobody@teton:/home/falcon> id
uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup),65533(nobody)
nobody@teton:/home/falcon> ls -la |grep phurst
dr-x------    2 4294967294 4294967294   199680 Jun 26 11:07 phurst

In this case the nobody account appears to go across as a -2 and the use
of long int instead of short int somewhere is bouncing the uid/gid
values up to the 4294967294 uid/gid number.. which causes some problems. 

Anyone else seeing this? Is this a linux NFS fix that is showing a
multinet bug?

eric


Here is a tcpdump showing the -2/-2 stuff.

teton:~ # tcpdump host pleiad
tcpdump: listening on eth0
11:12:07.657523 teton.2306391190 > tyco.nfs: 108 getattr [|nfs] (DF)
11:12:07.657987 tyco.nfs > teton.2306391190: reply ok 96 getattr DIR
40755 ids -2/-2 sz 1536
11:12:07.658160 teton.2323168406 > tyco.nfs: 108 getattr [|nfs] (DF)
11:12:07.658649 tyco.nfs > teton.2323168406: reply ok 96 getattr DIR
40755 ids -2/-2 sz 1536


-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabberConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
