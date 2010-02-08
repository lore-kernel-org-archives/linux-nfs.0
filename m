From: chihau Chau <chihau@gmail.com>
Subject: [PATCH] fs: nfsd: export: fix coding style issues
Date: Mon,  8 Feb 2010 18:36:53 -0300
Message-ID: <1265665013-32162-1-git-send-email-chihau@gmail.com>
Cc: neilb@suse.de, viro@zeniv.linux.org.uk, Trond.Myklebust@netapp.com,
	bharrosh@panasas.com, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chihau Chau <chihau@gmail.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f193.google.com ([209.85.210.193]:50463 "EHLO
	mail-yx0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019Ab0BIFSr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2010 00:18:47 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chihau Chau <chihau@gmail.com>

This fixes some coding style issues like spaces required, lines over 80
characters, assignments in if conditions and trailing whitespaces.

Signed-off-by: Chihau Chau <chihau@gmail.com>
---
 fs/nfsd/export.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c487810..4ecb07b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -41,7 +41,7 @@ static int		exp_verify_string(char *cp, int max);
 
 #define	EXPKEY_HASHBITS		8
 #define	EXPKEY_HASHMAX		(1 << EXPKEY_HASHBITS)
-#define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX -1)
+#define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX - 1)
 static struct cache_head *expkey_table[EXPKEY_HASHMAX];
 
 static void expkey_put(struct kref *ref)
@@ -66,7 +66,7 @@ static void expkey_request(struct cache_detail *cd,
 	qword_add(bpp, blen, ek->ek_client->name);
 	snprintf(type, 5, "%d", ek->ek_fsidtype);
 	qword_add(bpp, blen, type);
-	qword_addhex(bpp, blen, (char*)ek->ek_fsid, key_len(ek->ek_fsidtype));
+	qword_addhex(bpp, blen, (char *)ek->ek_fsid, key_len(ek->ek_fsidtype));
 	(*bpp)[-1] = '\n';
 }
 
@@ -75,7 +75,8 @@ static int expkey_upcall(struct cache_detail *cd, struct cache_head *h)
 	return sunrpc_cache_pipe_upcall(cd, h, expkey_request);
 }
 
-static struct svc_expkey *svc_expkey_update(struct svc_expkey *new, struct svc_expkey *old);
+static struct svc_expkey *svc_expkey_update(struct svc_expkey *new,
+							struct svc_expkey *old);
 static struct svc_expkey *svc_expkey_lookup(struct svc_expkey *);
 static struct cache_detail svc_expkey_cache;
 
@@ -101,7 +102,8 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 		goto out;
 
 	err = -EINVAL;
-	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
+	len = qword_get(&mesg, buf, PAGE_SIZE);
+	if (len <= 0)
 		goto out;
 
 	err = -ENOENT;
@@ -111,15 +113,17 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	dprintk("found domain %s\n", buf);
 
 	err = -EINVAL;
-	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
+	len = qword_get(&mesg, buf, PAGE_SIZE);
+	if (len <= 0)
 		goto out;
 	fsidtype = simple_strtoul(buf, &ep, 10);
 	if (*ep)
 		goto out;
 	dprintk("found fsidtype %d\n", fsidtype);
-	if (key_len(fsidtype)==0) /* invalid type */
+	if (key_len(fsidtype) == 0) /* invalid type */
 		goto out;
-	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) <= 0)
+	len = qword_get(&mesg, buf, PAGE_SIZE);
+	if (len <= 0)
 		goto out;
 	dprintk("found fsid length %d\n", len);
 	if (len != key_len(fsidtype))
@@ -131,7 +135,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	if (key.h.expiry_time == 0)
 		goto out;
 
-	key.ek_client = dom;	
+	key.ek_client = dom;
 	key.ek_fsidtype = fsidtype;
 	memcpy(key.ek_fsid, buf, len);
 
@@ -181,16 +185,16 @@ static int expkey_show(struct seq_file *m,
 	struct svc_expkey *ek ;
 	int i;
 
-	if (h ==NULL) {
+	if (h == NULL) {
 		seq_puts(m, "#domain fsidtype fsid [path]\n");
 		return 0;
 	}
 	ek = container_of(h, struct svc_expkey, h);
 	seq_printf(m, "%s %d 0x", ek->ek_client->name,
 		   ek->ek_fsidtype);
-	for (i=0; i < key_len(ek->ek_fsidtype)/4; i++)
+	for (i = 0; i < key_len(ek->ek_fsidtype)/4; i++)
 		seq_printf(m, "%08x", ek->ek_fsid[i]);
-	if (test_bit(CACHE_VALID, &h->flags) && 
+	if (test_bit(CACHE_VALID, &h->flags) &&
 	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
 		seq_printf(m, " ");
 		seq_path(m, &ek->ek_path, "\\ \t\n");
-- 
1.5.6.3

