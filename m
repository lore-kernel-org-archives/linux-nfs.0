From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: NFSv4 uninitialized mtime
Date: Wed, 27 Jun 2007 16:31:14 -0700
Message-ID: <20070627233114.GA14508@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3gyj-0000ll-PN
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 16:31:17 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3gyn-0004tH-2Y
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 16:31:21 -0700
Received: from alphard.ligo.caltech.edu (alphard [131.215.114.160])
	by acrux.ligo.caltech.edu (8.12.11/8.12.11) with ESMTP id
	l5RNVJrc020557
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 27 Jun 2007 16:31:19 -0700 (PDT)
Received: from alphard.ligo.caltech.edu (localhost.localdomain [127.0.0.1])
	by alphard.ligo.caltech.edu (8.13.7/8.13.4) with ESMTP id
	l5RNVEqc014972
	for <nfs@lists.sourceforge.net>; Wed, 27 Jun 2007 16:31:14 -0700
Received: (from anderson@localhost)
	by alphard.ligo.caltech.edu (8.13.7/8.13.4/Submit) id l5RNVEu9014971
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 16:31:14 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The following simple program creates files with un-initialized mtime values
on a Linux NFSv4 client mounting from a Solaris NFSv4 server--at least the
mtimes are wildly different each time the program is run. The problem is
reproducible but does not happen under any of the following circumstances:

1) Drop O_EXCL from open() call.
2) NFS mount using v3.
3) Switch NFS v4 client from Linux to Solaris.

This is on an FC4 machine with the 2.6.20.14 kernel plus Trond's recent
revalidate-the-fsid-on-the-current-dir-not-the-root-dir patch
and nfs-utils 1.0.9-16 backported from CentOS 5.

Thanks.


> cat badmtime.c 
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


main() {
int fd;

fd = open("badtime.out", O_CREAT|O_EXCL, 0664);
close(fd);
}
> vi badmtime.c
> gcc badmtime.c -o badmtime
> ./badmtime 
> ls -l badmtime.out 
-rw-r--r--  1 anderson anderson 0 Oct  9  1979 badmtime.out
> stat badmtime.out 
  File: `badmtime.out'
  Size: 0               Blocks: 1          IO Block: 1048576 regular empty file
Device: 20h/32d Inode: 107016      Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 5026/anderson)   Gid: ( 5026/anderson)
Access: 2007-06-27 16:07:24.184162655 -0700
Modify: 1979-10-09 12:54:39.549017000 -0700
Change: 2007-06-27 16:07:24.192792428 -0700


-- 
Stuart Anderson  anderson@ligo.caltech.edu
http://www.ligo.caltech.edu/~anderson

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
