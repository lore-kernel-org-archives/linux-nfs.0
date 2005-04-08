From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 009 of 16] nfsd4: fix fh_expire_type
Date: Fri, 08 Apr 2005 11:00:16 +1000
Message-ID: <E1DJhr6-0006du-BJ@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Tv-5j
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikL-0004DE-9e
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:23 -0700
To: Andrew Morton <akpm@osdl.org>
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


We're returning NFS4_FH_NOEXPIRE_WITH_OPEN | NFS4_FH_VOL_RENAME for the
fh_expire_type attribute.  This is incorrect:
	1. The spec actually only allows NOEXPIRE_WITH_OPEN when
	   VOLATILE_ANY is also set.
	2. Filehandles for open files can expire, if the file is removed
	   and there is a reboot.
	3. Filehandles are only volatile on rename in the nosubtree check
	   case.

Unfortunately, there's no way to indicate that we only expire on remove.
So our only choice is FH4_VOLATILE_ANY.  Although it's redundant, we also set
FH4_VOL_RENAME in the subtree check case, since subtreecheck does actually
cause problems in practice and it seems possibly useful to give clients
some way to distinguish that case.

Fix a mispelled #define while we're at it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c    |    5 ++++-
 ./include/linux/nfs4.h |    2 +-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-04-08 10:31:12.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2005-04-08 10:42:53.000000000 +1000
@@ -1366,7 +1366,10 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE) {
 		if ((buflen -= 4) < 0)
 			goto out_resource;
-		WRITE32( NFS4_FH_NOEXPIRE_WITH_OPEN | NFS4_FH_VOL_RENAME );
+		if (exp->ex_flags & NFSEXP_NOSUBTREECHECK)
+			WRITE32(NFS4_FH_VOLATILE_ANY);
+		else
+			WRITE32(NFS4_FH_VOLATILE_ANY|NFS4_FH_VOL_RENAME);
 	}
 	if (bmval0 & FATTR4_WORD0_CHANGE) {
 		/*

diff ./include/linux/nfs4.h~current~ ./include/linux/nfs4.h
--- ./include/linux/nfs4.h~current~	2005-04-08 10:31:12.000000000 +1000
+++ ./include/linux/nfs4.h	2005-04-08 10:42:53.000000000 +1000
@@ -28,7 +28,7 @@
 #define NFS4_ACCESS_DELETE      0x0010
 #define NFS4_ACCESS_EXECUTE     0x0020
 
-#define NFS4_FH_PERISTENT		0x0000
+#define NFS4_FH_PERSISTENT		0x0000
 #define NFS4_FH_NOEXPIRE_WITH_OPEN	0x0001
 #define NFS4_FH_VOLATILE_ANY		0x0002
 #define NFS4_FH_VOL_MIGRATION		0x0004


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
