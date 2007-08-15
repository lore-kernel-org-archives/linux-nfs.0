From: "Mitch Sako" <msako@cadence.com>
Subject: Compilation Error nfs-utils-1.1.0
Date: Wed, 15 Aug 2007 16:19:50 -0700
Message-ID: <862A0FDF1A4DC647A442EFD270291F7301AE5335@MAILSJ2.global.cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILS9W-0007ng-6T
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:19:50 -0700
Received: from mx-sanjose2.cadence.com ([158.140.2.61])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILS9a-0004e2-Bh
	for nfs@lists.sourceforge.net; Wed, 15 Aug 2007 16:19:54 -0700
Received: from MAILSJ2.global.cadence.com (localhost [127.0.0.1])
	by mx-sanjose2.Cadence.COM (8.12.9/8.12.9) with ESMTP id l7FNHIQB018218
	for <nfs@lists.sourceforge.net>; Wed, 15 Aug 2007 16:17:18 -0700 (PDT)
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

When I try to build 1.1.0 it gives this error message inside of
./mountd:

[root mountd]$ make
/bin/sh ../../libtool --tag=CC   --mode=link gcc -Wall  -pipe -g -O2
-o mountd mountd-mountd.o mountd-mount_dispatch.o mountd-auth.o
mountd-rmtab.o mountd-cache.o mountd-svc_run.o mountd-fsloc.o
../../support/export/libexport.a ../../support/nfs/libnfs.a
../../support/misc/libmisc.a  -lwrap  -lblkid 
gcc -Wall -pipe -g -O2 -o mountd mountd-mountd.o mountd-mount_dispatch.o
mountd-auth.o mountd-rmtab.o mountd-cache.o mountd-svc_run.o
mountd-fsloc.o  ../../support/export/libexport.a
../../support/nfs/libnfs.a ../../support/misc/libmisc.a -lwrap -lblkid
/usr/lib/libblkid.a(probe.o): In function `set_uuid':
/usr/local/e2fsprogs-1.40.2/lib/blkid/probe.c:128: undefined reference
to `uuid_is_null'
/usr/local/e2fsprogs-1.40.2/lib/blkid/probe.c:129: undefined reference
to `uuid_unparse'
/usr/lib/libblkid.a(probe.o): In function `probe_ext3':
/usr/local/e2fsprogs-1.40.2/lib/blkid/probe.c:176: undefined reference
to `uuid_is_null'
collect2: ld returned 1 exit status
make: *** [mountd] Error 1

I suspect I may have built e2fsprogs or uuid incorrectly?  1.0.6 does
not have this link error.

It's on an RHEL3 Update 5 system.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
