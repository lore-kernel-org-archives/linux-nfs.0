From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 27 of 54] nfsd4: simplify find_openstateowner_str
Date: Tue, 08 Mar 2005 17:06:44 +1100
Message-ID: <E1D8Xrg-00018X-69@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8XsK-0002BD-GY
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8XsJ-0007xF-MS
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:24 -0800
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



There's no need to return duplicate information through the return value and an
argument.  Other minor cleanup.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 11:35:58.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 11:35:58.000000000 +1100
@@ -1233,18 +1233,16 @@ cmp_owner_str(struct nfs4_stateowner *so
 	  (sop->so_client->cl_clientid.cl_id == clid->cl_id));
 }
 
-/* search ownerstr_hashtbl[] for owner */
-static int
-find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open, struct nfs4_stateowner **op) {
-	struct nfs4_stateowner *local = NULL;
+static struct nfs4_stateowner *
+find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
+{
+	struct nfs4_stateowner *so = NULL;
 
-	list_for_each_entry(local, &ownerstr_hashtbl[hashval], so_strhash) {
-		if (!cmp_owner_str(local, &open->op_owner, &open->op_clientid))
-			continue;
-		*op = local;
-		return(1);
+	list_for_each_entry(so, &ownerstr_hashtbl[hashval], so_strhash) {
+		if (cmp_owner_str(so, &open->op_owner, &open->op_clientid))
+			return so;
 	}
-	return 0;
+	return NULL;
 }
 
 /* search file_hashtbl[] for file */
@@ -1461,7 +1459,8 @@ nfsd4_process_open1(struct nfsd4_open *o
 		return nfserr_stale_clientid;
 
 	strhashval = ownerstr_hashval(clientid->cl_id, open->op_owner);
-	if (find_openstateowner_str(strhashval, open, &sop)) {
+	sop = find_openstateowner_str(strhashval, open);
+	if (sop) {
 		open->op_stateowner = sop;
 		/* check for replay */
 		if (open->op_seqid == sop->so_seqid){
@@ -1504,7 +1503,8 @@ nfsd4_process_open1(struct nfsd4_open *o
 			goto out;
 	}
 	status = nfserr_resource;
-	if (!(sop = alloc_init_open_stateowner(strhashval, clp, open))) 
+	sop = alloc_init_open_stateowner(strhashval, clp, open);
+	if (sop == NULL)
 		goto out;
 	open->op_stateowner = sop;
 renew:


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
