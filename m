From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 004 of 16] nfsd4: find_delegation_file()
Date: Fri, 08 Apr 2005 11:00:16 +1000
Message-ID: <E1DJhr6-0006da-1e@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006Tt-5W
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikL-0004DD-85
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


Factor out a bit of common code that will be useful elsewhere.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-04-08 10:35:24.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-04-08 10:38:38.000000000 +1000
@@ -1526,6 +1526,18 @@ out:
 	return status;
 }
 
+static struct nfs4_delegation *
+find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
+{
+	struct nfs4_delegation *dp;
+
+	list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
+		if (dp->dl_stateid.si_stateownerid == stid->si_stateownerid)
+			return dp;
+	}
+	return NULL;
+}
+
 static int
 nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_stateid **stpp)
 {
@@ -2419,24 +2431,15 @@ find_stateid(stateid_t *stid, int flags)
 static struct nfs4_delegation *
 find_delegation_stateid(struct inode *ino, stateid_t *stid)
 {
-	struct nfs4_delegation *dp = NULL;
 	struct nfs4_file *fp = NULL;
-	u32 st_id;
 
 	dprintk("NFSD:find_delegation_stateid stateid=(%08x/%08x/%08x/%08x)\n",
                     stid->si_boot, stid->si_stateownerid,
                     stid->si_fileid, stid->si_generation);
 
-	st_id = stid->si_stateownerid;
 	fp = find_file(ino);
-	if (fp) {
-		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
-			if(dp->dl_stateid.si_stateownerid == st_id) {
-				dprintk("NFSD: find_delegation dp %p\n",dp);
-				return dp;
-			}
-		}
-	}
+	if (fp)
+		return find_delegation_file(fp, stid);
 	return NULL;
 }
 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
