From: NeilBrown <neilb@suse.de>
Subject: [PATCH 008 of 8] knfsd: nfsd4: don't delegate files that have
	had conflicts
Date: Thu, 21 Jun 2007 14:31:19 +1000
Message-ID: <1070621043119.1159@suse.de>
References: <20070621142604.727.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1EKN-0005sh-6i
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:27 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1EKP-0002Kj-Rk
	for nfs@lists.sourceforge.net; Wed, 20 Jun 2007 21:31:30 -0700
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


From: "J. Bruce Fields" <bfields@fieldses.org>


One more incremental delegation policy improvement: don't give out a
delegation on a file if conflicting access has previously required that
a delegation be revoked on that file.  (In practice we'll forget about
the conflict when the struct nfs4_file is removed on close, so this is
of limited use for now, though it should at least solve a temporary
problem with self-conflicts on write opens from the same client.)

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c        |    4 ++++
 ./include/linux/nfsd/state.h |    1 +
 2 files changed, 5 insertions(+)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2007-06-21 14:14:47.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2007-06-21 14:16:21.000000000 +1000
@@ -194,6 +194,8 @@ alloc_init_deleg(struct nfs4_client *clp
 	struct nfs4_callback *cb = &stp->st_stateowner->so_client->cl_callback;
 
 	dprintk("NFSD alloc_init_deleg\n");
+	if (fp->fi_had_conflict)
+		return NULL;
 	if (num_delegations > max_delegations)
 		return NULL;
 	dp = kmem_cache_alloc(deleg_slab, GFP_KERNEL);
@@ -1002,6 +1004,7 @@ alloc_init_file(struct inode *ino)
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
+		fp->fi_had_conflict = false;
 		return fp;
 	}
 	return NULL;
@@ -1328,6 +1331,7 @@ do_recall(void *__dp)
 {
 	struct nfs4_delegation *dp = __dp;
 
+	dp->dl_file->fi_had_conflict = true;
 	nfsd4_cb_recall(dp);
 	return 0;
 }

diff .prev/include/linux/nfsd/state.h ./include/linux/nfsd/state.h
--- .prev/include/linux/nfsd/state.h	2007-06-21 14:09:31.000000000 +1000
+++ ./include/linux/nfsd/state.h	2007-06-21 14:16:21.000000000 +1000
@@ -224,6 +224,7 @@ struct nfs4_file {
 	struct inode		*fi_inode;
 	u32                     fi_id;      /* used with stateowner->so_id 
 					     * for stateid_hashtbl hash */
+	bool			fi_had_conflict;
 };
 
 /*

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
