From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 4 of 54] nfsd4: remove utf8 checking
Date: Tue, 08 Mar 2005 17:06:42 +1100
Message-ID: <E1D8Xre-000173-Gl@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xs7-0002Af-3G
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:11 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xs6-0007vp-6n
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:07:10 -0800
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



RFC3530 says NFSv4 filenames are in UTF-8, and that servers "should" reject
filenames that aren't valid UTF-8.  Currently we do some incomplete UTF-8
checking, but this turns out to be more of a hindrance than a help--if we
export a filesystem with non-UTF8 names, things break.  We might be able to
help things if we had some idea of the exported filesystem's charset and could
do some translation.  For now, though, the simplest solution by far seems to be
just to remove the UTF-8 checks, making NFSv4's behaviour just like NFSv2/v3's.

Similar problems exist with usernames.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |  125 ----------------------------------------------------
 1 files changed, 1 insertion(+), 124 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2005-03-07 11:35:08.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2005-03-07 11:35:08.000000000 +1100
@@ -60,121 +60,6 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
-static const char utf8_byte_len[256] = {
-	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
-	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
-	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
-	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
-	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
-	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
-	0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
-	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, 4,4,4,4,4,4,4,4,5,5,5,5,6,6,0,0
-};
-
-static inline int
-is_legal_utf8_sequence(unsigned char *source, int length)
-{
-	unsigned char *ptr;
-	unsigned char c;
-
-	if (length==1) return 1;
-
-	/* Check for overlong sequence, and check second byte */
-	c = *(source + 1);
-	switch (*source) {
-	case 0xE0: /* 3 bytes */
-		if ( c < 0xA0 ) return 0;
-		break;
-	case 0xF0: /* 4 bytes */
-		if ( c < 0x90 ) return 0;
-		break;
-	case 0xF8: /* 5 bytes */
-		if ( c < 0xC8 ) return 0;
-		break;
-	case 0xFC: /* 6 bytes */
-		if ( c < 0x84 ) return 0;
-		break;
-	default:
-		if ( (c & 0xC0) != 0x80) return 0;
-	}
-
-	/* Check that trailing bytes look like 10xxxxxx */
-	for (ptr = source++ + length - 1; ptr>source; ptr--)
-		if ( ((*ptr) & 0xC0) != 0x80 ) return 0;
-	return 1;
-}
-
-/* This does some screening on disallowed unicode characters.  It is NOT
- * comprehensive.
- */
-static int
-is_allowed_utf8_char(unsigned char *source, int length)
-{
-	/* We assume length and source point to a valid utf8 sequence */
-	unsigned char c;
-
-	/* Disallow F0000 and up (in utf8, F3B08080) */
-	if (*source > 0xF3 ) return 0;
-	c = *(source + 1);
-	switch (*source) {
-	case 0xF3:
-		if (c >= 0xB0) return 0;
-		break;
-	/* Disallow D800-F8FF (in utf8, EDA080-EFA3BF */
-	case 0xED:
-		if (c >= 0xA0) return 0;
-		break;
-	case 0xEE:
-		return 0;
-		break;
-	case 0xEF:
-		if (c <= 0xA3) return 0;
-	/* Disallow FFF9-FFFF (EFBFB9-EFBFBF) */
-		if (c==0xBF)
-			/* Don't need to check <=0xBF, since valid utf8 */
-			if ( *(source+2) >= 0xB9) return 0;
-		break;
-	}
-	return 1;
-}
-
-/* This routine should really check to see that the proper stringprep
- * mappings have been applied.  Instead, we do a simple screen of some
- * of the more obvious illegal values by calling is_allowed_utf8_char.
- * This will allow many illegal strings through, but if a client behaves,
- * it will get full functionality.  The other option (apart from full
- * stringprep checking) is to limit everything to an easily handled subset,
- * such as 7-bit ascii.
- *
- * Note - currently calling routines ignore return value except as boolean.
- */
-static int
-check_utf8(char *str, int len)
-{
-	unsigned char *chunk, *sourceend;
-	int chunklen;
-
-	chunk = str;
-	sourceend = str + len;
-
-	while (chunk < sourceend) {
-		chunklen = utf8_byte_len[*chunk];
-		if (!chunklen)
-			return nfserr_inval;
-		if (chunk + chunklen > sourceend)
-			return nfserr_inval;
-		if (!is_legal_utf8_sequence(chunk, chunklen))
-			return nfserr_inval;
-		if (!is_allowed_utf8_char(chunk, chunklen))
-			return nfserr_inval;
-		if ( (chunklen==1) && (!*chunk) )
-			return nfserr_inval; /* Disallow embedded nulls */
-		chunk += chunklen;
-	}
-
-	return 0;
-}
-
 static int
 check_filename(char *str, int len, int err)
 {
@@ -187,7 +72,7 @@ check_filename(char *str, int len, int e
 	for (i = 0; i < len; i++)
 		if (str[i] == '/')
 			return err;
-	return check_utf8(str, len);
+	return 0;
 }
 
 /*
@@ -403,8 +288,6 @@ nfsd4_decode_fattr(struct nfsd4_compound
 			READ_BUF(dummy32);
 			len += XDR_QUADLEN(dummy32) << 2;
 			READMEM(buf, dummy32);
-			if (check_utf8(buf, dummy32))
-				return nfserr_inval;
 			ace.whotype = nfs4_acl_get_whotype(buf, dummy32);
 			status = 0;
 			if (ace.whotype != NFS4_ACL_WHO_NAMED)
@@ -439,8 +322,6 @@ nfsd4_decode_fattr(struct nfsd4_compound
 		READ_BUF(dummy32);
 		len += (XDR_QUADLEN(dummy32) << 2);
 		READMEM(buf, dummy32);
-		if (check_utf8(buf, dummy32))
-			return nfserr_inval;
 		if ((status = nfsd_map_name_to_uid(argp->rqstp, buf, dummy32, &iattr->ia_uid)))
 			goto out_nfserr;
 		iattr->ia_valid |= ATTR_UID;
@@ -452,8 +333,6 @@ nfsd4_decode_fattr(struct nfsd4_compound
 		READ_BUF(dummy32);
 		len += (XDR_QUADLEN(dummy32) << 2);
 		READMEM(buf, dummy32);
-		if (check_utf8(buf, dummy32))
-			return nfserr_inval;
 		if ((status = nfsd_map_name_to_gid(argp->rqstp, buf, dummy32, &iattr->ia_gid)))
 			goto out_nfserr;
 		iattr->ia_valid |= ATTR_GID;
@@ -585,8 +464,6 @@ nfsd4_decode_create(struct nfsd4_compoun
 		READ32(create->cr_linklen);
 		READ_BUF(create->cr_linklen);
 		SAVEMEM(create->cr_linkname, create->cr_linklen);
-		if (check_utf8(create->cr_linkname, create->cr_linklen))
-			return nfserr_inval;
 		break;
 	case NF4BLK:
 	case NF4CHR:


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
