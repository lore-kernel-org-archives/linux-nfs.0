From: Julius Schwartzenberg <julius@zgod.cjb.net>
Subject: Unable to access mountpoints over NFS
Date: Thu, 15 Sep 2005 00:58:13 +0200
Message-ID: <4328AB05.1040502@zgod.cjb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFgCz-0001zV-D8
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 15:58:29 -0700
Received: from netlx050.vf.utwente.nl ([192.87.17.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EFgCy-00009M-4G
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 15:58:29 -0700
Received: from [130.89.166.98] (middelvinger.student.utwente.nl [130.89.166.98])
          by netlx050.vf.utwente.nl (8.11.7/HKD) with ESMTP id j8EMw7NP022604
          for <nfs@lists.sourceforge.net>; Thu, 15 Sep 2005 00:58:12 +0200
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
I've exported / from my server and I have a harddisk mounted at 
/mnt/hdb1. The clients see /mnt/hdb1 as an empty directory though.
Is this normal?
Do I need to create an extra export or is it possible to allow access to 
it using the / export?
Thanks in advance,
Julius


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
