From: Steffen Kolbe <kolbe@vwi.tu-dresden.de>
Subject: Folder in NFS-Share-Permission denied-but the user is group member
Date: Fri, 05 May 2006 13:03:25 +0200
Message-ID: <445B30FD.9040103@vwi.tu-dresden.de>
Reply-To: kolbe@vwi.tu-dresden.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FbyQX-0008FU-2I
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 04:24:53 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1Fby5r-0001LB-IE
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 04:03:31 -0700
Received: from rks36.urz.tu-dresden.de ([141.30.66.166] helo=mailgate.urz.tu-dresden.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fby5r-0000EN-7J
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 04:03:31 -0700
Received: from [127.0.0.1] (helo=localhost)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1Fby5l-0004qF-Fx; Fri, 05 May 2006 13:03:25 +0200
Received: from mailgate.urz.tu-dresden.de ([127.0.0.1])
 by localhost (rks36 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 06039-68 for <nfs@lists.sourceforge.net>;
 Fri,  5 May 2006 13:03:25 +0200 (MEST)
Received: from [141.30.186.11] (helo=vwitme011.vwi.vkw.tu-dresden.de)
	  by mailgate.urz.tu-dresden.de with esmtp (exim-4.51)
	  for <nfs@lists.sourceforge.net>
	  id 1Fby5l-0004q8-0a; Fri, 05 May 2006 13:03:25 +0200
Received: from vwitme048.vwi.vkw.tu-dresden.de ([141.30.186.48])
	by vwitme011.vwi.vkw.tu-dresden.de with esmtp (Exim 4.52)
	id 1Fby5b-0008Vi-HH
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 13:03:15 +0200
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

NFS-Server: Debian amd64 with nfs-kernel-server 1.0.7-12
NFS-Client: Debian i386 with nfs-common 1.0.7-11

Can anybody help, where I should search ?

Thanks
Steffen




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
