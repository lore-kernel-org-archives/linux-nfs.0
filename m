From: Steffen Kolbe <kolbe@vwi.tu-dresden.de>
Subject: trace attached - Folders in NFS-share: permission denied, prob. not
 16+ groups problem
Date: Mon, 08 May 2006 11:08:59 +0200
Message-ID: <445F0AAB.8040305@vwi.tu-dresden.de>
Reply-To: kolbe@vwi.tu-dresden.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fd9D8-0000vJ-QY
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:07:54 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1Fd1js-0002qc-Uy
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 02:09:12 -0700
Received: from rks36.urz.tu-dresden.de ([141.30.66.166] helo=mailgate.urz.tu-dresden.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fd1jq-0005H5-9g
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 02:09:12 -0700
Received: from [127.0.0.1] (helo=localhost)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1Fd1je-000387-75; Mon, 08 May 2006 11:08:58 +0200
Received: from mailgate.urz.tu-dresden.de ([127.0.0.1])
 by localhost (rks36 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 27761-55 for <nfs@lists.sourceforge.net>;
 Mon,  8 May 2006 11:08:57 +0200 (MEST)
Received: from [141.30.186.11] (helo=vwitme011.vwi.vkw.tu-dresden.de)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1Fd1jd-000383-Nz; Mon, 08 May 2006 11:08:57 +0200
Received: from vwitme048.vwi.vkw.tu-dresden.de ([141.30.186.48])
	by vwitme011.vwi.vkw.tu-dresden.de with esmtp (Exim 4.52)
	id 1Fd1jX-0002bv-Tq
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 11:08:51 +0200
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

Hi,

- a client has mounted some nfs shares
- in these shares are folders wich are owned by different groups
- rights of these folders are 2770
- getent group: user is member in these groups (on server and client via 
ldap)

but access to these folders says "Permission denied"

- if I copy the folder to local disk this error does not occur and the 
user has access

After a tip from Neil Brown I've reduced the 2 test users to 14 / 15 
groups - same problem.

I've traced the folder access traffic on client and server with 
ethereal. They are here:
http://vwitme011.vkw.tu-dresden.de/~kolbe/nfs/nfs-trace-client.ethereal
http://vwitme011.vkw.tu-dresden.de/~kolbe/nfs/nfs-trace-server.ethereal

Any help  ist welcome

-----------------------------------------------------------
general question:
Is their a real solution to use ~50 groups with nfs? Because we've many 
project groups some team leaders, many crossover memberships over some 
departments and .......
How is this solved in bigger environments?
------------------------------------------------------------

NFS-Server: Debian amd64 with nfs-kernel-server 1.0.7-12
NFS-Client: Debian i386 with nfs-common 1.0.7-11

best regards
Steffen



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
