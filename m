From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 10 of 12] Don't try to cache reply to nfsv2 readdir.
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006Vm-HS@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLir-0006vC-6m
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLiq-0004Fq-Lt
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:29 -0800
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


As readdir returns the reply in a separate page, the
cache code cannot find the reply (and it would probably
be too big anyway) so falg readdir or NOCACHE

Signed-off-by: okir@suse.de
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfsproc.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2005-02-08 10:42:31.000000000 +1100
+++ ./fs/nfsd/nfsproc.c	2005-02-08 10:42:39.000000000 +1100
@@ -540,7 +540,7 @@ static struct svc_procedure		nfsd_proced
   PROC(symlink,	 symlinkargs,	void,		none,		RC_REPLSTAT, ST),
   PROC(mkdir,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT),
   PROC(rmdir,	 diropargs,	void,		none,		RC_REPLSTAT, ST),
-  PROC(readdir,	 readdirargs,	readdirres,	none,		RC_REPLBUFF, 0),
+  PROC(readdir,	 readdirargs,	readdirres,	none,		RC_NOCACHE, 0),
   PROC(statfs,	 fhandle,	statfsres,	none,		RC_NOCACHE, ST+5),
 };
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
