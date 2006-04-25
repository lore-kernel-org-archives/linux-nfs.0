From: christophe.caron@jouy.inra.fr
Subject: Small UDP frame
Date: Tue, 25 Apr 2006 18:20:41 +0200 (CEST)
Message-ID: <Pine.SOC.4.62.0604251811440.23035@diamant>
Reply-To: christophe.caron@jouy.inra.fr
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FYQHY-0000nO-Mz
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 09:20:56 -0700
Received: from diorite.jouy.inra.fr ([138.102.119.181])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FYQHW-0001M9-3z
	for nfs@lists.sourceforge.net; Tue, 25 Apr 2006 09:20:56 -0700
Received: from diamant (diamant [138.102.1.1])
	by diorite.jouy.inra.fr (/8.13.6) with ESMTP id k3PGKexN023216
	for <nfs@lists.sourceforge.net>; Tue, 25 Apr 2006 18:20:40 +0200 (CEST)
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


Hello

We've a cluster under Sun Grid Engine with a data NFS server and we've 
some performance problems on the server (it seems this is IO problems).

It seems we've also many,many smalls UDP packets between the node and the 
NFS server (5000 packet in 10 seconds...)

#tcpdump -v host server
18:13:26.212996 IP (tos 0x0, ttl  64, id 54076, offset 0, flags [DF], 
length: 140) server.nfs > n46.797: UDP, length: 112
18:13:26.213459 IP (tos 0x0, ttl  64, id 42208, offset 0, flags [DF], 
length: 140) n46.797 > server.nfs: UDP, length: 112

Actually i've no more idea about the performance problems. NFS which block 
IO ? How could i get more information about this network trafic ?

The data partition is mounted with noatime option.

Any clue ?

thanks

cc


Prenez note de ma nouvelle adresse : christophe.caron@jouy.inra.fr

***********************************************************
  Christophe Caron - INRA
  Mathematique, Informatique et Genome
  Domaine de Vilvert 78350 Jouy-en-Josas
  Web: http://migale.jouy.inra.fr/
  Tel: 01-34-65-28-88  Email: christophe.caron@jouy.inra.fr 
***********************************************************



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
