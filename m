From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 3 of 10 - complain if idmapd doesn't have channel open
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001Qk-Fm@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCE-0007hE-E9
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:10 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCE-0008W4-1K
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:10 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:05 +1000
To: Andrew Morton <akpm@osdl.org>
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


From: "J. Bruce Fields" <bfields@fieldses.org>

Currently if a user mounts a server that doesn't have idmapd running, the
mount may block for 10 seconds to a minute, and there's no useful errors on
the client or server side.

Help out by:
	1) Failing lookups immediately whenever no process has opened the
	   files in idmapd that are used to do idmapping upcalls.
	2) Doing a printk() in this situation so they know idmapd needs to
	   be run.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4idmap.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-04-08 10:50:13.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2004-04-08 10:50:15.000000000 +1000
@@ -505,6 +505,17 @@ init_mdr(struct idmap_defer_req *mdr, wa
 	mdr->req.defer = idmap_defer;
 }
 
+static inline void
+warn_no_idmapd(void) {
+	static time_t last_warning = 0;
+
+	if (last_warning < get_seconds() - 60) {
+		last_warning = get_seconds();
+		printk(KERN_WARNING "nfsd: idmap failing; check if idmapd"
+				" is running?\n");
+	}
+}
+
 static int
 idmap_lookup(struct svc_rqst *rqstp,
 		struct ent *(*lookup_fn)(struct ent *, int), struct ent *key,
@@ -514,6 +525,10 @@ idmap_lookup(struct svc_rqst *rqstp,
 	struct idmap_defer_req *mdr;
 	int ret;
 
+	if (atomic_read(&detail->readers) == 0) {
+		warn_no_idmapd();
+		return -ENOENT;
+	}
 	mdr = kmalloc(sizeof(*mdr), GFP_KERNEL);
 	if (!mdr)
 		return -ENOMEM;


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
