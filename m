From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: NFSv4 & /etc/exportfs
Date: Mon, 26 Jan 2004 15:44:07 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401261544.07589.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Al8RW-00024H-IP
	for nfs@lists.sourceforge.net; Mon, 26 Jan 2004 07:14:26 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Al8RV-0006u7-5h
	for nfs@lists.sourceforge.net; Mon, 26 Jan 2004 07:14:25 -0800
Received: from roquetav.frec.bull.fr (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id PAA13904
	for <nfs@lists.sourceforge.net>; Mon, 26 Jan 2004 15:44:03 +0100
To: nfs@lists.sourceforge.net
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

I tried to mount a directory using the old nfs conf. format (as indicated in 
the man) and using the new one, as described here : 
http://www.citi.umich.edu/projects/nfsv4/june_2002_rel/exports.html

I used nfs-util 1.0.6 (tarball version)

Well...
Using old format
1/ I can't mount the directory for rw... I tried approximatly all.

Using the new one: 
It seem the program exportfs 1.0.6 don't understand the new datas formats 
(that's confirmed by source code where I can't see the keyword "pseudo" for 
example)
So, is the new format supported by a version of exports, and where can I 
download the code?
If this new format is not supported at all, howto configure nfsv4 with the old 
one?

Thank you

Vincent ROQUETA
 


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
