From: NeilBrown <neilb@suse.de>
Subject: [PATCH 010 of 14] knfsd: nfsd4: fix some open argument tests
Date: Tue, 27 Jun 2006 17:20:27 +1000
Message-ID: <1060627072027.26709@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7sA-0006OW-Be
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:34 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7sA-0007Mo-1U
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:34 -0700
To: Andrew Morton <akpm@osdl.org>
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

From: J. Bruce Fields <bfields@citi.umich.edu>


These tests always returned true; clearly that wasn't what was intended.

In keeping with kernel style, make them functions instead of macros while
we're at it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2006-06-27 14:44:03.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2006-06-27 15:00:26.000000000 +1000
@@ -1237,8 +1237,15 @@ find_file(struct inode *ino)
 	return NULL;
 }
 
-#define TEST_ACCESS(x) ((x > 0 || x < 4)?1:0)
-#define TEST_DENY(x) ((x >= 0 || x < 5)?1:0)
+static int access_valid(u32 x)
+{
+	return (x > 0 && x < 4);
+}
+
+static int deny_valid(u32 x)
+{
+	return (x >= 0 && x < 5);
+}
 
 static void
 set_access(unsigned int *access, unsigned long bmap) {
@@ -1745,7 +1752,8 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	int status;
 
 	status = nfserr_inval;
-	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
+	if (!access_valid(open->op_share_access)
+			|| !deny_valid(open->op_share_deny))
 		goto out;
 	/*
 	 * Lookup file; if found, lookup stateid and check open request,
@@ -2317,7 +2325,8 @@ nfsd4_open_downgrade(struct svc_rqst *rq
 			(int)current_fh->fh_dentry->d_name.len,
 			current_fh->fh_dentry->d_name.name);
 
-	if (!TEST_ACCESS(od->od_share_access) || !TEST_DENY(od->od_share_deny))
+	if (!access_valid(od->od_share_access)
+			|| !deny_valid(od->od_share_deny))
 		return nfserr_inval;
 
 	nfs4_lock_state();

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
