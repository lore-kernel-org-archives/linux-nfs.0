From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Build failure
Date: Fri, 8 Jun 2007 12:24:57 +0200
Message-ID: <20070608102457.GA3154@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HwbeQ-0003dO-0f
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 03:25:03 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HwbeR-0005jB-RU
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 03:25:05 -0700
Received: from trofast.sesse.net ([129.241.93.32])
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1HwbeM-0004nj-GW
	for nfs@lists.sourceforge.net; Fri, 08 Jun 2007 12:24:58 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1HwbeL-0000pB-00
	for <nfs@lists.sourceforge.net>; Fri, 08 Jun 2007 12:24:57 +0200
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

Hi,

Today nfs-utils stopped building for me, probably due to a libc update or
something. The failed part was, from support/include/nfs/nfs.h:

   #include <linux/version.h>
   #if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,70)
   # define __nfsd_dev_t  __kernel_old_dev_t
   #else
   # define __nfsd_dev_t  __kernel_dev_t
   #endif

The failure from gcc was:

   gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I../../support/include -D_GNU_SOURCE -Wall  -pipe -g -O2 -Wall -MT client.o -MD -MP -MF .deps/client.Tpo -c -o client.o client.c
   In file included from ../../support/include/nfslib.h:22,
                    from client.c:22:
   ../../support/include/nfs/nfs.h:73:24: error: operator '>' has no left operand
   In file included from ../../support/include/nfslib.h:22,
                    from client.c:22:
   ../../support/include/nfs/nfs.h:83: error: expected specifier-qualifier-list before '__kernel_dev_t'
   ../../support/include/nfs/nfs.h:104: error: expected specifier-qualifier-list before '__kernel_dev_t'

Is userspace allowed to assume that a symbol such as LINUX_VERSION_CODE
exists at all?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
