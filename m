From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Some interoperability testing
Date: Tue, 8 Feb 2005 10:22:47 +0100
Message-ID: <200502071839.24804.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyRUn-0003lr-Gf
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 01:17:21 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CyRUm-0007Zu-5E
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 01:17:21 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 5100819D907
	for <nfs@lists.sourceforge.net>; Tue,  8 Feb 2005 10:16:48 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 22201-04 for <nfs@lists.sourceforge.net>;
 Tue,  8 Feb 2005 10:16:46 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 2F71F19D904
	for <nfs@lists.sourceforge.net>; Tue,  8 Feb 2005 10:16:46 +0100 (CET)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

NFSv3:
Server : AIX 5.3
Client Linux 2.6.9
Test : connectathon 2004
* All tests passed, 2 warning.

NFSv3
Server AIX 5.3
Client Linux 2.6.10
* Big file test (test5 from BASIC tests) is blocked
* Lock tests blocked (Tests 14)

For the test5 (read/write a 30Mo file) a sequence of packet is sent many times 
in an infinite loop :

client to server 
NFS V3 WRITE CALL, FH: 0x38ad8e6 Offset:32768 Len:38768 UNSTABLE
client to server Fragmented IP protocol (UDP, 0x11, offset 1480 )
client to server Fragmented IP protocol (UDP, 0x11, offset... )
client to server Fragmented IP protocol (UDP, 0x11, offset... )
....
client to server Fragmented IP protocol (UDP, 0x11, offset... )
client to server Fragmented IP protocol (UDP, 0x11, offset 25160)

(there is a delay of 1,4 seconds before
previous sequence is repeted)
__________________________________________________________
dmesg is telling :
nfs: server aix_server not responding, still trying
...


Since all is right with kernel 2.6.9, that looks like a regression...
Even if that is the true behaviour it may exist a way to stop this process 
cleanly : since NFS umount is can't be done the client does not reboot, and I 
need  to turn the power off...

NFSv4
_____
Works a better...
All tests passed. Big file tests is _really_slow (many minutes to copy a 30Mo 
file over a 100Mo/s network)

Vincent


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
