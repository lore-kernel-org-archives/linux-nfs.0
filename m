From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 10 of 23] Find a delegation for a file given a stateid.
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002e0-6Z@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAbJ-000597-7G
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:25 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbI-0004CB-Gm
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:24:25 -0800
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


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 12:00:46.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 12:03:23.000000000 +1100
@@ -81,6 +81,7 @@ u32 free_delegation= 0;
 
 /* forward declarations */
 struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
+static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 
 /* Locking:
  *
@@ -2056,6 +2057,32 @@ find_stateid(stateid_t *stid, int flags)
 	return NULL;
 }
 
+static struct nfs4_delegation *
+find_delegation_stateid(struct inode *ino, stateid_t *stid)
+{
+	struct nfs4_delegation *dp = NULL;
+	struct nfs4_file *fp = NULL;
+	u32 st_id;
+	unsigned int fi_hashval;
+
+	dprintk("NFSD:find_delegation_stateid stateid=(%08x/%08x/%08x/%08x)\n",
+                    stid->si_boot, stid->si_stateownerid,
+                    stid->si_fileid, stid->si_generation);
+
+	if(!ino || !stid)
+		return NULL;
+	st_id = stid->si_stateownerid;
+	fi_hashval = file_hashval(ino);
+	if (find_file(fi_hashval, ino, &fp)) {
+		list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
+			if(dp->dl_stateid.si_stateownerid == st_id) {
+				dprintk("NFSD: find_delegation dp %p\n",dp);
+				return dp;
+			}
+		}
+	}
+	return NULL;
+}
 
 /*
  * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
