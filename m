From: =?iso-8859-1?q?Johan=20Thelin?= <e8johan@yahoo.se>
Subject: Problems when mounting
Date: Wed, 23 Oct 2002 12:05:16 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021023100517.78860.qmail@web14707.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web14707.mail.yahoo.com ([216.136.224.124])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184IO7-0003on-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 03:05:19 -0700
To: Network File System <nfs@lists.sourceforge.net>
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

Hi All!

  I'm running an embedded system running Linux 2.5.21
and a host system (x86) running RedHat 7.3.
The two units are connected by a twisted TP cable and
the IP communication works (they can ping each other
and traceroute knows the way).
  The host machine has been configured to share a
folder over NFS in /etc/exports, the only line reads: 

/home/johan/nfsexport 192.168.1.2(rw)

  The specified IP is the one used by the target
system. I have followed the NFS HOWTO and succesfully
got the daemons running (rpcinfo -p looks good). When
I try to mount from the target by using the line:

mount 192.168.1.1:/home/johan/nfsexport /tmp/local

  I get the following problem:

mount: Mounting 192.168.1.1:/home/johan/nfsexport on
/tmp/local failed: No such file or directory

  I have verified that /tmp/local exists as a
directory and so does /home/johan/nfsexport on the
host.

  I would be very thankful for some constructive
input, or even an solution. I cannot find this error
message documented anywhere, so I don't know where to
begin.

  Cheers!

/Johan

_____________________________________________________
Gratis e-mail resten av livet på www.yahoo.se/mail
Busenkelt!


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
