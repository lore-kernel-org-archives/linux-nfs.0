From: Reinhard Dunkel <dunkel@sciencesoft.net>
Subject: NFS slow for Linux server and Solaris client
Date: Thu, 16 Oct 2003 18:25:41 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F8F3705.9000502@sciencesoft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAKP9-0003jX-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Oct 2003 19:31:51 -0700
Received: from host84.ipowerweb.com ([12.129.227.184])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1AAKP0-00022W-NY
	for nfs@lists.sourceforge.net; Thu, 16 Oct 2003 19:31:42 -0700
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

We changed to a RH Linux 9 file server (3 GHz Intel PC). MS Windows machines use 
Samba and have no problem with this file server. RH Linux computers use NFS with 
good speed. But for Solaris (8 or 9 on Sun Ultra 10/360) NFS still works, but is 
about 18 times slower than expected. Such Linux/Solaris issues were discussed on 
the Internet years ago. Is there a patch for the RH Linux NFS server or the 
Solaris NFS client I missed? What else could I try?

ThanX,
Reinhard




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
