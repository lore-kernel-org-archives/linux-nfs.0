From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 11 - nfsd_xdr_name_encoding.patch
Date: Fri, 28 May 2004 14:37:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7a-0008EN-Uf@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkZb-0006tX-AP
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:03:19 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkZa-000707-Dh
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:03:18 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
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


Encode names directly into xdr buffer; this optimizes out a data copy, reduces
stack usage, and will make life simpler when doing acls.


From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |   80 +++++++++++++++++++++++++++++++++-------------------
 1 files changed, 51 insertions(+), 29 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-05-28 14:20:16.000000000 +1000
@@ -1289,6 +1289,49 @@ static u32 nfs4_ftypes[16] = {
         NF4SOCK, NF4BAD,  NF4LNK, NF4BAD,
 };
 
+static inline int
+xdr_padding(int l)
+{
+       return 3 - ((l - 1) & 3); /* smallest i>=0 such that (l+i)%4 = 0 */
+}
+
+static int
+nfsd4_encode_name(struct svc_rqst *rqstp, int group, uid_t id,
+			u32 **p, int *buflen)
+{
+	int status;
+	u32 len;
+
+	if (*buflen < (XDR_QUADLEN(IDMAP_NAMESZ) << 2) + 4)
+		return nfserr_resource;
+	if (group)
+		status = nfsd_map_gid_to_name(rqstp, id, (u8 *)(*p + 1));
+	else
+		status = nfsd_map_uid_to_name(rqstp, id, (u8 *)(*p + 1));
+	if (status < 0)
+		return nfserrno(status);
+	len = (unsigned)status;
+	*(*p)++ = htonl(len);
+	memset((u8 *)*p + len, 0, xdr_padding(len));
+	*p += XDR_QUADLEN(len);
+	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
+	BUG_ON(*buflen < 0);
+	return 0;
+}
+
+static inline int
+nfsd4_encode_user(struct svc_rqst *rqstp, uid_t uid, u32 **p, int *buflen)
+{
+	return nfsd4_encode_name(rqstp, uid, 0, p, buflen);
+}
+
+static inline int
+nfsd4_encode_group(struct svc_rqst *rqstp, uid_t gid, u32 **p, int *buflen)
+{
+	return nfsd4_encode_name(rqstp, gid, 1, p, buflen);
+}
+
+
 /*
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
@@ -1304,10 +1347,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 	u32 bmval0 = bmval[0];
 	u32 bmval1 = bmval[1];
 	struct kstat stat;
-	char owner[IDMAP_NAMESZ];
-	u32 ownerlen = 0;
-	char group[IDMAP_NAMESZ];
-	u32 grouplen = 0;
 	struct svc_fh tempfh;
 	struct kstatfs statfs;
 	int buflen = *countp << 2;
@@ -1338,23 +1377,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 			goto out;
 		fhp = &tempfh;
 	}
-	if (bmval1 & FATTR4_WORD1_OWNER) {
-		int temp = nfsd_map_uid_to_name(rqstp, stat.uid, owner);
-		if (temp < 0) {
-			status = temp;
-			goto out_nfserr;
-		}
-		ownerlen = (unsigned) temp;
-	}
-	if (bmval1 & FATTR4_WORD1_OWNER_GROUP) {
-		int temp = nfsd_map_gid_to_name(rqstp, stat.gid, group);
-		if (temp < 0) {
-			status = temp;
-			goto out_nfserr;
-		}
-		grouplen = (unsigned) temp;
-	}
-
 	if ((buflen -= 16) < 0)
 		goto out_resource;
 
@@ -1536,18 +1558,18 @@ nfsd4_encode_fattr(struct svc_fh *fhp, s
 		WRITE32(stat.nlink);
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER) {
-		buflen -= (XDR_QUADLEN(ownerlen) << 2) + 4;
-		if (buflen < 0)
+		status = nfsd4_encode_user(rqstp, stat.uid, &p, &buflen);
+		if (status == nfserr_resource)
 			goto out_resource;
-		WRITE32(ownerlen);
-		WRITEMEM(owner, ownerlen);
+		if (status)
+			goto out;
 	}
 	if (bmval1 & FATTR4_WORD1_OWNER_GROUP) {
-		buflen -= (XDR_QUADLEN(grouplen) << 2) + 4;
-		if (buflen < 0)
+		status = nfsd4_encode_group(rqstp, stat.gid, &p, &buflen);
+		if (status == nfserr_resource)
 			goto out_resource;
-		WRITE32(grouplen);
-		WRITEMEM(group, grouplen);
+		if (status)
+			goto out;
 	}
 	if (bmval1 & FATTR4_WORD1_RAWDEV) {
 		if ((buflen -= 8) < 0)


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
