From: "Chuck Lever" <chucklever@gmail.com>
Subject: connectathon special test failure in recent kernels
Date: Tue, 8 Aug 2006 15:20:19 -0400
Message-ID: <76bd70e30608081220q75c6c0f2v18e5ebb309b1c201@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAX7r-0004KT-3X
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 12:20:27 -0700
Received: from ug-out-1314.google.com ([66.249.92.174])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAX7q-0004oy-9n
	for nfs@lists.sourceforge.net; Tue, 08 Aug 2006 12:20:27 -0700
Received: by ug-out-1314.google.com with SMTP id s2so586161uge
	for <nfs@lists.sourceforge.net>; Tue, 08 Aug 2006 12:20:25 -0700 (PDT)
To: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Is the connectathon holey test failure going to be fixed before 2.6.18
is finalized?

This is from a 2.6.18-rc3 client:

test exclusive create.

test negative seek, you should get: read: Invalid argument
or lseek: Invalid argument
lseek: Invalid argument

test rename

test truncate
truncate succeeded

test holey file support
read (hole) offset 8192, sz = 56667, bytes = 5141 (ret -1), holesz = 9012
read: Input/output error
special tests failed
Tests failed, leaving /mnt/brahms mounted
[cel@picasso cthon04]$

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
