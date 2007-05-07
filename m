From: NeilBrown <neilb@suse.de>
Subject: [PATCH 006 of 8] knfsd: Trivial makefile cleanup
Date: Mon, 7 May 2007 10:35:51 +1000
Message-ID: <1070507003551.24173@suse.de>
References: <20070507103211.23855.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrD2-00057C-Qj
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:12 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrD5-0002nq-2k
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:15 -0700
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


From: Christoph Hellwig <hch@lst.de>

kbuild directly interprets <modulename>-y as objects to build into
a module, no need to assign it to the old foo-objs variable.


Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/Makefile |    1 -
 1 file changed, 1 deletion(-)

diff .prev/fs/nfsd/Makefile ./fs/nfsd/Makefile
--- .prev/fs/nfsd/Makefile	2007-05-07 10:30:15.000000000 +1000
+++ ./fs/nfsd/Makefile	2007-05-07 10:31:05.000000000 +1000
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
