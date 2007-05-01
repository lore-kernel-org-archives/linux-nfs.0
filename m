From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] nfsd: trivial makefile cleanup
Date: Tue, 1 May 2007 12:45:12 +0200
Message-ID: <20070501104512.GA23320@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hj6bR-0005pu-03
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 21:38:09 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Hj6bQ-0002pZ-4x
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 21:38:11 -0700
Received: from verein.lst.de (localhost [127.0.0.1])
	by mail.lst.de (8.12.3/8.12.3/Debian-7.1) with ESMTP id l424bdmK017725
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Wed, 2 May 2007 06:37:41 +0200
Received: (from hch@localhost)
	by verein.lst.de (8.12.3/8.12.3/Debian-6.6) id l41AjC70023340
	for nfs@lists.sourceforge.net; Tue, 1 May 2007 12:45:12 +0200
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

kbuild directly interprets <modulename>-y as objects to build into
a module, no need to assign it to the old foo-objs variable.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/fs/nfsd/Makefile
===================================================================
--- linux-2.6.orig/fs/nfsd/Makefile	2007-05-01 11:42:57.000000000 +0200
+++ linux-2.6/fs/nfsd/Makefile	2007-05-01 11:43:00.000000000 +0200
@@ -11,4 +11,3 @@ nfsd-$(CONFIG_NFSD_V3)	+= nfs3proc.o nfs
 nfsd-$(CONFIG_NFSD_V3_ACL) += nfs3acl.o
 nfsd-$(CONFIG_NFSD_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4idmap.o \
 			   nfs4acl.o nfs4callback.o nfs4recover.o
-nfsd-objs		:= $(nfsd-y)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
