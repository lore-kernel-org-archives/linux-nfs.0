From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Fix incorrect XDR buffer reservations under NFSv4
Date: Wed, 4 Dec 2002 22:03:40 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15854.28076.248335.539905@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JggM-0001WH-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Dec 2002 13:03:46 -0800
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


With this patch, the NFSv4 client should work correctly again.

Cheers,
  Trond

(Sent from the OPLUG meeting via wireless LAN)

diff -u --recursive --new-file linux-2.5.49/fs/nfs/nfs4xdr.c linux-2.5.49-00-nfsv4_xdr1/fs/nfs/nfs4xdr.c
--- linux-2.5.49/fs/nfs/nfs4xdr.c	2002-11-21 19:34:30.000000000 -0500
+++ linux-2.5.49-00-nfsv4_xdr1/fs/nfs/nfs4xdr.c	2002-11-22 22:16:34.000000000 -0500
@@ -161,9 +161,13 @@
 	 *          = 36 bytes, plus any contribution from variable-length fields
 	 *            such as owner/group/acl's.
 	 */
-	len = 36;
+	len = 16;
 
 	/* Sigh */
+	if (iap->ia_valid & ATTR_SIZE)
+		len += 8;
+	if (iap->ia_valid & ATTR_MODE)
+		len += 4;
 	if (iap->ia_valid & ATTR_UID) {
 		status = owner_namelen = encode_uid(owner_name, iap->ia_uid);
 		if (status < 0) {
@@ -171,7 +175,7 @@
 			       iap->ia_uid);
 			goto out;
 		}
-		len += XDR_QUADLEN(owner_namelen);
+		len += 4 + (XDR_QUADLEN(owner_namelen) << 2);
 	}
 	if (iap->ia_valid & ATTR_GID) {
 		status = owner_grouplen = encode_gid(owner_group, iap->ia_gid);
@@ -180,8 +184,16 @@
 			       iap->ia_gid);
 			goto out;
 		}
-		len += XDR_QUADLEN(owner_grouplen);
+		len += 4 + (XDR_QUADLEN(owner_grouplen) << 2);
 	}
+	if (iap->ia_valid & ATTR_ATIME_SET)
+		len += 16;
+	else if (iap->ia_valid & ATTR_ATIME)
+		len += 4;
+	if (iap->ia_valid & ATTR_MTIME_SET)
+		len += 16;
+	else if (iap->ia_valid & ATTR_MTIME)
+		len += 4;
 	RESERVE_SPACE(len);
 
 	/*
@@ -204,13 +216,11 @@
 		bmval1 |= FATTR4_WORD1_OWNER;
 		WRITE32(owner_namelen);
 		WRITEMEM(owner_name, owner_namelen);
-		p += owner_namelen;
 	}
 	if (iap->ia_valid & ATTR_GID) {
 		bmval1 |= FATTR4_WORD1_OWNER_GROUP;
 		WRITE32(owner_grouplen);
 		WRITEMEM(owner_group, owner_grouplen);
-		p += owner_namelen;
 	}
 	if (iap->ia_valid & ATTR_ATIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
@@ -238,6 +248,11 @@
 	/*
 	 * Now we backfill the bitmap and the attribute buffer length.
 	 */
+	if (len != ((char *)p - (char *)q) + 4) {
+		printk ("encode_attr: Attr length calculation error! %u != %u\n",
+				len, ((char *)p - (char *)q) + 4);
+		BUG();
+	}
 	len = (char *)p - (char *)q - 12;
 	*q++ = htonl(bmval0);
 	*q++ = htonl(bmval1);
@@ -265,7 +280,7 @@
 {
 	uint32_t *p;
 
-	RESERVE_SPACE(20);
+	RESERVE_SPACE(8+sizeof(nfs4_stateid));
 	WRITE32(OP_CLOSE);
 	WRITE32(close->cl_seqid);
 	WRITEMEM(close->cl_stateid, sizeof(nfs4_stateid));
@@ -380,7 +395,7 @@
 	uint32_t *p;
 	
 	/* seqid, share_access, share_deny, clientid, ownerlen, owner, opentype */
-	RESERVE_SPACE(52);
+	RESERVE_SPACE(36);
 	WRITE32(OP_OPEN);
 	WRITE32(0);                       /* seqid */
 	WRITE32(open->op_share_access);
@@ -392,7 +407,7 @@
 	
 	if (open->op_opentype == NFS4_OPEN_CREATE) {
 		if (open->op_createmode == NFS4_CREATE_EXCLUSIVE) {
-			RESERVE_SPACE(12);
+			RESERVE_SPACE(4+sizeof(nfs4_verifier));
 			WRITE32(open->op_createmode);
 			WRITEMEM(open->op_verifier, sizeof(nfs4_verifier));
 		}
@@ -427,7 +442,7 @@
 	 * Note: In this "stateless" implementation, the OPEN_CONFIRM
 	 * seqid is always equal to 1.
 	 */
-	RESERVE_SPACE(24);
+	RESERVE_SPACE(8+sizeof(nfs4_stateid));
 	WRITE32(OP_OPEN_CONFIRM);
 	WRITEMEM(open_confirm->oc_stateid, sizeof(nfs4_stateid));
 	WRITE32(1);
@@ -494,7 +509,7 @@
 	int replen;
 	uint32_t *p;
 
-	RESERVE_SPACE(40);
+	RESERVE_SPACE(32+sizeof(nfs4_verifier));
 	WRITE32(OP_READDIR);
 	WRITE64(readdir->rd_cookie);
 	WRITEMEM(readdir->rd_req_verifier, sizeof(nfs4_verifier));
@@ -558,7 +573,7 @@
 	WRITE32(rename->rn_oldnamelen);
 	WRITEMEM(rename->rn_oldname, rename->rn_oldnamelen);
 	
-	RESERVE_SPACE(8 + rename->rn_newnamelen);
+	RESERVE_SPACE(4 + rename->rn_newnamelen);
 	WRITE32(rename->rn_newnamelen);
 	WRITEMEM(rename->rn_newname, rename->rn_newnamelen);
 
@@ -605,7 +620,7 @@
 	int status;
 	uint32_t *p;
 	
-        RESERVE_SPACE(20);
+        RESERVE_SPACE(4+sizeof(nfs4_stateid));
         WRITE32(OP_SETATTR);
 	WRITEMEM(setattr->st_stateid, sizeof(nfs4_stateid));
 
@@ -626,7 +641,7 @@
 	len2 = strlen(setclientid->sc_netid);
 	len3 = strlen(setclientid->sc_uaddr);
 	total_len = XDR_QUADLEN(len1) + XDR_QUADLEN(len2) + XDR_QUADLEN(len3);
-	total_len = (total_len << 2) + 32;
+	total_len = (total_len << 2) + 24 + sizeof(nfs4_verifier);
 
 	RESERVE_SPACE(total_len);
 	WRITE32(OP_SETCLIENTID);


-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
