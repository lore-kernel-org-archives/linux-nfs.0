From: Erik Thiele <erik@thiele-hydraulik.de>
Subject: trouble with file locking
Date: Wed, 12 Nov 2003 10:50:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031112105043.020c1548.erik@thiele-hydraulik.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AJrh2-0008Jz-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 01:53:44 -0800
Received: from moutng.kundenserver.de ([212.227.126.187])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AJrgh-0001bt-KZ
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 01:53:23 -0800
Received: from [212.227.126.206] (helo=mrelayng.kundenserver.de)
	by moutng.kundenserver.de with esmtp (Exim 3.35 #1)
	id 1AJrge-0003VN-00
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 10:53:20 +0100
Received: from [80.131.204.136] (helo=goofy.thiele-intern)
	by mrelayng.kundenserver.de with asmtp (Exim 3.35 #1)
	id 1AJre8-00086K-00
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 10:50:44 +0100
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

Hi.

I am using as a fileserver

ii  nfs-kernel-ser 1.0-2woody1    Kernel NFS server support
ii  kernel-image-2 2.4.18-5       Linux kernel image for version 2.4.18 on AMD
ii  nfs-common     1.0-2woody1    NFS support files common to client and serve

on a AMD K6-2/400 with 128MB Ram.

the server has / mounted as ext2.

i am exporting to old hp-ux machines a subdirectory of / like this:

/Archiv xxx.unix.yyy-intern(rw,no_root_squash)

i also export my homedirectory to my linux woody debian machines like this:

/home/erik str.blafoo-intern(rw,no_root_squash)


i have written a test-program like this:

#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>

int main()
{
  int h=open("delmelockfile", O_WRONLY|O_CREAT, 0700);
  struct flock l;
  memset(&l,0,sizeof l);
  l.l_type=F_WRLCK;
  l.l_whence=SEEK_SET;
  l.l_start=0;
  l.l_len=0;
  fcntl(h,F_SETLK,&l);
  sleep(100);
  return 0;
}

i strace it, and it gets a no lock availiable error on the fcntl.
i use ethereal to analyze traffic and get a V4 LOCK CALL with the right inode,
and a V4 xxxxxx (i forgot to write) which has a NLM_DENIED or NLM_NO_LOCKS or something like that.

using rpcinfo i found nlockmgr running.
now if i restart the rpc.statd (!!!) suddenly it works and i get locks granted packages (NLM_GRANTED)

someone please enlighten me :)

cu
erik


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
