From: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Subject: NFSv4  and vi
Date: Thu, 19 Feb 2004 09:58:38 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200402190958.38127.vincent.roqueta@ext.bull.net>
Reply-To: vincent.roqueta@ext.bull.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Atk3m-0000WU-GH
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 01:01:30 -0800
Received: from ecbull20.frec.bull.fr ([129.183.4.3])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AtjyX-000503-Dw
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 00:56:05 -0800
Received: from roquetav (roquetav.frec.bull.fr [129.183.101.52])
	by ecbull20.frec.bull.fr (8.9.2/8.9.1) with ESMTP id JAA10986
	for <nfs@lists.sourceforge.net>; Thu, 19 Feb 2004 09:56:50 +0100
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

Here are vi traces for opening "/mnt/nfs/vincent/suite-tests/toto3"

1/ The file toto3 do not exist
2/ There is no vi opened session
3/ there is no file (and so no .swp file) in this directory

Had a look to the traces...

stat64("/mnt/nfs/vincent/suite-tests/toto3", 0xbffff620) = -1 ENOENT (No such 
file or directory)
stat64("/mnt/nfs/vincent/suite-tests/toto3", 0xbffff7a0) = -1 ENOENT (No such 
file or directory)
access("/mnt/nfs/vincent/suite-tests/toto3", W_OK) = -1 ENOENT (No such file 
or directory)
open("/mnt/nfs/vincent/suite-tests/toto3", O_RDONLY|O_LARGEFILE) = -1 ENOENT 
(No such file or directory)


****Here is the problem: there is a "permission denied", error have to be "No 
****such file or directory"
open("/mnt/nfs/vincent/suite-tests/.toto3.swp", O_RDONLY|O_LARGEFILE) = -1 
EACCES (Permission denied) 

****Second error (same, I suppose) "File exist" that's WRONG!

open("/mnt/nfs/vincent/suite-tests/.toto3.swp", 
O_RDWR|O_CREAT|O_EXCL|O_LARGEFILE, 0600) = -1 EEXIST (File exists)


stat64("/mnt/nfs/vincent/suite-tests/.toto3.swp", {st_mode=S_IFREG, st_size=0, 
...}) = 0
stat64("/mnt/nfs/vincent/suite-tests/.toto3.swx", 0xbffff0e0) = -1 ENOENT (No 
such file or directory)
open("/mnt/nfs/vincent/suite-tests/.toto3.swp", O_RDONLY|O_LARGEFILE) = -1 
EACCES (Permission denied)
write(1, "\33[1;39r\33[?25h\33[?25h\33[27m\33[m\33[H\33["..., 62) = 62
stat64("/mnt/nfs/vincent/suite-tests/.toto3.swp", {st_mode=S_IFREG, st_size=0, 
...}) = 0


To end, when I quit the vi session (without saving anything) the swaped file 
YET exist, with a creation date 1 october 1970.

I'm trying to find the error.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
