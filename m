Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35366 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755502Ab2LMQ3S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 11:29:18 -0500
Message-ID: <50CA0254.4030308@suse.com>
Date: Thu, 13 Dec 2012 21:59:08 +0530
From: Suresh Jayaraman <sjayaraman@suse.com>
MIME-Version: 1.0
To: steved@redhat.com, linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] idmapd: allow non-ASCII characters (UTF-8) in NFSv4 domain
 name
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The validateascii() check in imconv() maps NFSv4 domain names with non-ASCII
characters to 'nobody'. In setups where Active directory or LDAP is used this
causes names with UTF-8 characters to be mapped to 'nobody' because of this
check.

As Bruce Fields puts it:

"idmapd doesn't seem like the right place to enforce restrictions on names.
Once the system has allowed a name it's too late to be complaining about it
here."

Remove the check from imconv() and remove the validateascii() function itself
as the only user of that function is being removed by this patch.


Signed-off-by: Suresh Jayaraman <sjayaraman@suse.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
---

 utils/idmapd/idmapd.c |   24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index e80efb4..fe47dac 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -145,7 +145,6 @@ static void svrreopen(int, short, void *);
 static int  nfsopen(struct idmap_client *);
 static void nfscb(int, short, void *);
 static void nfsdcb(int, short, void *);
-static int  validateascii(char *, u_int32_t);
 static int  addfield(char **, ssize_t *, char *);
 static int  getfield(char **, char *, size_t);
 
@@ -652,10 +651,6 @@ imconv(struct idmap_client *ic, struct idmap_msg *im)
 			    im->im_id, im->im_name);
 		break;
 	case IDMAP_CONV_NAMETOID:
-		if (validateascii(im->im_name, sizeof(im->im_name)) == -1) {
-			im->im_status |= IDMAP_STATUS_INVALIDMSG;
-			return;
-		}
 		nametoidres(im);
 		if (verbose > 1)
 			xlog_warn("%s %s: (%s) name \"%s\" -> id \"%d\"",
@@ -855,25 +850,6 @@ nametoidres(struct idmap_msg *im)
 }
 
 static int
-validateascii(char *string, u_int32_t len)
-{
-	u_int32_t i;
-
-	for (i = 0; i < len; i++) {
-		if (string[i] == '\0')
-			break;
-
-		if (string[i] & 0x80)
-			return (-1);
-	}
-
-	if ((i >= len) || string[i] != '\0')
-		return (-1);
-
-	return (i + 1);
-}
-
-static int
 addfield(char **bpp, ssize_t *bsizp, char *fld)
 {
 	char ch, *bp = *bpp;

