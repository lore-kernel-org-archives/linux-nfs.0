From: Omar Armas <oarmas@mpsnet.net.mx>
Subject: slow response
Date: Tue, 5 Apr 2005 14:07:52 -0500
Message-ID: <200504051407.52917.oarmas@mpsnet.net.mx>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DItOt-0006JD-Sj
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 12:07:47 -0700
Received: from mail3.optical.com.mx ([200.53.122.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DItOs-0006f3-0F
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 12:07:47 -0700
Received: from unknown (HELO kaos.mpsnet.net.mx) (oarmas@quakerstate.com.mx@[200.38.40.2])
          (envelope-sender <oarmas@mpsnet.net.mx>)
          by mail3.optical.com.mx (qmail-ldap-1.03) with SMTP
          for <nfs@lists.sourceforge.net>; 5 Apr 2005 20:05:22 -0000
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

I have a NFS server with debian stable and kernel 2.6.10. The package 
nfs-kernel-server setup the server.
The clients, with same software, mount it with:

IP_ADD:/home/vmail       /home/vmail     nfs     rw,hard,intr    0       0

in fstab.


I use NFS to store mailboxes in a qmail-ldap cluster.
My problem is that suddenly  the clients received extremely slow responses 
from the server. 
In the client a simple "ls" in the mounted partition took minutes to execute.

While this happens, ping and other protocols run well between server and 
client, only NFS had problems.


I made a simple test, with no traffic I can access the share without problems, 
very fast, but as soon as I redirect traffic to this client(which is a qmail 
server), it turns very very slow.

Any idea why and how to fix it?


Omar


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
