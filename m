From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 6 of 8 - Improve UTF8 checking.
Date: Thu, 25 Mar 2004 12:06:54 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B6JKg-0007Dw-00@notabene>
References: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKs-0006bg-An
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:06 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKr-0002a6-M4
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:05 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:07:01 +1100
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


>From Fred: We don't do all the utf8 checking we could in the kernel, but we do
some simple checks.  Implement slightly stricter, and probably more efficient,
checking.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4xdr.c |  153 +++++++++++++++++++++++++++-------------------------
 1 files changed, 80 insertions(+), 73 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-03-25 11:43:35.000000000 +1100
+++ ./fs/nfsd/nfs4xdr.c	2004-03-25 11:43:38.000000000 +1100
@@ -58,93 +58,94 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
-/*
- * From Peter Astrand <peter@cendio.se>: The following routines check
- * whether a filename supplied by the client is valid.
- */
-static const char trailing_bytes_for_utf8[256] = {
-	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
-	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
-	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
-	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
+static const char utf8_byte_len[256] = {
+	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
+	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
+	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
+	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
-	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
-	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5
+	0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
+	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3, 4,4,4,4,4,4,4,4,5,5,5,5,6,6,0,0
 };
 
 static inline int
-is_legal_iso_utf8_sequence(unsigned char *source, int length)
+is_legal_utf8_sequence(unsigned char *source, int length)
 {
-	unsigned char a;
-	unsigned char *srcptr;
+	unsigned char *ptr;
+	unsigned char c;
 
-	srcptr = source + length;
+	if (length==1) return 1;
 
-	switch (length) {
-		/* Everything else falls through when "1"... */
+	/* Check for overlong sequence, and check second byte */
+	c = *(source + 1);
+	switch (*source) {
+	case 0xE0: /* 3 bytes */
+		if ( c < 0xA0 ) return 0;
+		break;
+	case 0xF0: /* 4 bytes */
+		if ( c < 0x90 ) return 0;
+		break;
+	case 0xF8: /* 5 bytes */
+		if ( c < 0xC8 ) return 0;
+		break;
+	case 0xFC: /* 6 bytes */
+		if ( c < 0x84 ) return 0;
+		break;
 	default:
-		/* Sequences with more than 6 bytes are invalid */
-		return 0;
+		if ( (c & 0xC0) != 0x80) return 0;
+	}
 
-		/*
-		   Byte 3-6 must be 80..BF
-		*/
-	case 6:
-		if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return 0;
-	case 5:
-		if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return 0;
-	case 4:
-		if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return 0;
-	case 3:
-		if ((a = (*--srcptr)) < 0x80 || a > 0xBF) return 0;
-
-	case 2:
-		a = *--srcptr;
-
-		/* Upper limit */
-		if (a > 0xBF)
-			/* 2nd byte may never be > 0xBF */
-			return 0;
+	/* Check that trailing bytes look like 10xxxxxx */
+	for (ptr = source++ + length - 1; ptr>source; ptr--)
+		if ( ((*ptr) & 0xC0) != 0x80 ) return 0;
+	return 1;
+}
 
-		/*
-		   Lower limits checks, to detect non-shortest forms.
-		   No fall-through in this inner switch.
-		*/
-		switch (*source) {
-		case 0xE0: /* 3 bytes */
-			if (a < 0xA0) return 0;
-			break;
-		case 0xF0: /* 4 bytes */
-			if (a < 0x90) return 0;
-			break;
-		case 0xF8: /* 5 bytes */
-			if (a < 0xC8) return 0;
-			break;
-		case 0xFC: /* 6 bytes */
-			if (a < 0x84) return 0;
-			break;
-		default:
-			/* In all cases, 2nd byte must be >= 0x80 (because leading
-			   10...) */
-			if (a < 0x80) return 0;
-		}
+/* This does some screening on disallowed unicode characters.  It is NOT
+ * comprehensive.
+ */
+static int
+is_allowed_utf8_char(unsigned char *source, int length)
+{
+	/* We assume length and source point to a valid utf8 sequence */
+	unsigned char c;
 
-	case 1:
-		/* Invalid ranges */
-		if (*source >= 0x80 && *source < 0xC2)
-			/* Multibyte char with value < 0xC2, non-shortest */
-			return 0;
-		if (*source > 0xFD)
-			/* Leading byte starting with 11111110 is illegal */
-			return 0;
-		if (!*source)
-			return 0;
+	/* Disallow F0000 and up (in utf8, F3B08080) */
+	if (*source > 0xF3 ) return 0;
+	c = *(source + 1);
+	switch (*source) {
+	case 0xF3:
+		if (c >= 0xB0) return 0;
+		break;
+	/* Disallow D800-F8FF (in utf8, EDA080-EFA3BF */
+	case 0xED:
+		if (c >= 0xA0) return 0;
+		break;
+	case 0xEE:
+		return 0;
+		break;
+	case 0xEF:
+		if (c <= 0xA3) return 0;
+	/* Disallow FFF9-FFFF (EFBFB9-EFBFBF) */
+		if (c==0xBF)
+			/* Don't need to check <=0xBF, since valid utf8 */
+			if ( *(source+2) >= 0xB9) return 0;
+		break;
 	}
-
 	return 1;
 }
 
+/* This routine should really check to see that the proper stringprep
+ * mappings have been applied.  Instead, we do a simple screen of some
+ * of the more obvious illegal values by calling is_allowed_utf8_char.
+ * This will allow many illegal strings through, but if a client behaves,
+ * it will get full functionality.  The other option (apart from full
+ * stringprep checking) is to limit everything to an easily handled subset,
+ * such as 7-bit ascii.
+ *
+ * Note - currently calling routines ignore return value except as boolean.
+ */
 static int
 check_utf8(char *str, int len)
 {
@@ -155,11 +156,17 @@ check_utf8(char *str, int len)
 	sourceend = str + len;
 
 	while (chunk < sourceend) {
-		chunklen = trailing_bytes_for_utf8[*chunk]+1;
+		chunklen = utf8_byte_len[*chunk];
+		if (!chunklen)
+			return nfserr_inval;
 		if (chunk + chunklen > sourceend)
 			return nfserr_inval;
-		if (!is_legal_iso_utf8_sequence(chunk, chunklen))
+		if (!is_legal_utf8_sequence(chunk, chunklen))
+			return nfserr_inval;
+		if (!is_allowed_utf8_char(chunk, chunklen))
 			return nfserr_inval;
+		if ( (chunklen==1) && (!*chunk) )
+			return nfserr_inval; /* Disallow embedded nulls */
 		chunk += chunklen;
 	}
 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
