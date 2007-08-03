From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] nfs: tiny makefile cleanup
Date: Fri, 3 Aug 2007 16:20:32 +0200
Message-ID: <20070803142032.GA25075@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGy15-000533-1m
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 07:20:35 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IGy17-0002z5-K5
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 07:20:39 -0700
Received: from verein.lst.de (localhost [127.0.0.1])
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id l73EKWA5025109
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Fri, 3 Aug 2007 16:20:32 +0200
Received: (from hch@localhost)
	by verein.lst.de (8.12.3/8.12.3/Debian-6.6) id l73EKWhT025107
	for nfs@lists.sourceforge.net; Fri, 3 Aug 2007 16:20:32 +0200
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

no need to set up foo-objs these days.


Index: linux-2.6/fs/nfs/Makefile
===================================================================
--- linux-2.6.orig/fs/nfs/Makefile	2007-08-03 15:17:10.000000000 +0200
+++ linux-2.6/fs/nfs/Makefile	2007-08-03 15:17:18.000000000 +0200
@@ -16,4 +16,3 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4x
 			   nfs4namespace.o
 nfs-$(CONFIG_NFS_DIRECTIO) += direct.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
-nfs-objs		:= $(nfs-y)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
