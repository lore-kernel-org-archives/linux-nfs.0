From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 15 - Fix some bugs in qword management.
Date: Mon, 06 Jan 2003 11:05:03 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VKlL-0002XG-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18VKlf-0002XE-00
	for <nfs@lists.sourceforge.net>; Sun, 05 Jan 2003 16:05:23 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 6 Jan 2003 11:05:04 +1100
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


### Comments for ChangeSet

1/ converting to hex wasn't quite right
2/ make sure that decoding into the buffer holding
   original message works ok.




 ----------- Diffstat output ------------
 ./net/sunrpc/cache.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2003-01-06 09:52:33.000000000 +1100
+++ ./net/sunrpc/cache.c	2003-01-06 09:54:06.000000000 +1100
@@ -799,8 +799,8 @@ void qword_addhex(char **bpp, int *lp, c
 		len -= 2;
 		while (blen && len >= 2) {
 			unsigned char c = *buf++;
-			*bp++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'0');
-			*bp++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'0');
+			*bp++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'9'-1);
+			*bp++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'9'-1);
 			len -= 2;
 			blen--;
 		}
@@ -902,7 +902,7 @@ int qword_get(char **bpp, char *dest, in
 		}
 	} else {
 		/* text with \nnn octal quoting */
-		while (*bp != ' ' && *bp && len < bufsize-1) {
+		while (*bp != ' ' && *bp != '\n' && *bp && len < bufsize-1) {
 			if (*bp == '\\' &&
 			    isodigit(bp[1]) && (bp[1] <= '3') &&
 			    isodigit(bp[2]) &&
@@ -918,11 +918,12 @@ int qword_get(char **bpp, char *dest, in
 				len++;
 			}
 		}
-		*dest = '\0';
 	}
 
+	if (*bp != ' ' && *bp != '\n' && *bp != '\0')
+		return -1;
+	while (*bp == ' ') bp++;
 	*bpp = bp;
-	if (*bp == ' ' || *bp == '\n' || *bp == '\0')
-		return len;
-	return -1;
+	*dest = '\0';
+	return len;
 }


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
