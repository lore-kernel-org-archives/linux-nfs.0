From: Bernhard Busch <bbusch@biochem.mpg.de>
Subject: file locking error (37!) NFS problem
Date: Wed, 17 Sep 2003 17:08:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F6878DA.7070101@biochem.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19zdw2-0003pG-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 08:09:38 -0700
Received: from ns1.biochem.mpg.de ([141.61.1.32])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19zdw1-0000xL-OA
	for nfs@lists.sourceforge.net; Wed, 17 Sep 2003 08:09:37 -0700
Received: from mail01.biochem.mpg.de (mail01.biochem.mpg.de [192.168.20.21])
	by ns1.biochem.mpg.de (Postfix) with ESMTP id 1297FAEB9F
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 17:08:11 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by mail01.biochem.mpg.de (Postfix) with ESMTP id 3FE5F564
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 17:08:10 +0200 (CEST)
Received: from biochem.mpg.de (catherine.biochem.mpg.de [141.61.19.37])
	by mail01.biochem.mpg.de (Postfix) with ESMTP id BEE13561
	for <nfs@lists.sourceforge.net>; Wed, 17 Sep 2003 17:08:09 +0200 (CEST)
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

Hello  NFS Experts


I upgraded  a NFS Server from Suse 8.0 to Suse  8.1.

If  i use the EMAN program (Electron Image Processing Program, cluster 
version) from
a client  with Suse8.0   (the data files are on the fileserver) , i get 
the error message


file locking error (37!) NFS problem

and the application crashes.
Under Suse8.0  (file server) everything is working well.
On the fileserver with Suse8.2
the application also crashes.


Many thanks for every help.

Sincerely 

Bernhard Busch





--
 Dr. Bernhard Busch
Max-Planck-Institut für Biochemie

Rechenzentrum

Am Klopferspitz 18a
D-82152 Martinsried
Tel: +49(89)8578-2582
Fax: +49(89)8578-2479
Email bbusch@biochem.mpg.de





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
