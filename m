Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:60190 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab0K3TOG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 14:14:06 -0500
Date: Tue, 30 Nov 2010 14:14:03 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 3/5] disk signature fixes
Message-ID: <87fc19de9a71a12abc58bbad83298cabec55cc91.1291142529.git.rees@umich.edu>
References: <cover.1291142529.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1291142529.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

re-write decode_blk_signature to keep fd open
pretty print disk signature
remove unneeded syslog info messages

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-process.c |  105 +++++++++++++++++++++++-----------------
 1 files changed, 60 insertions(+), 45 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index a543769..4482bd5 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -47,6 +47,21 @@
 #include <linux/kdev_t.h>
 #include "device-discovery.h"
 
+static char *pretty_sig(char *sig, int siglen)
+{
+	static char rs[100];
+	unsigned int i;
+
+	if (siglen <= 4) {
+		memcpy(&i, sig, sizeof i);
+		sprintf(rs, "0x%0x", i);
+	} else {
+		memcpy(rs, sig, siglen);
+		rs[siglen] = '\0';
+	}
+	return rs;
+}
+
 uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
 {
 	uint32_t *q = p + ((nbytes + 3) >> 2);
@@ -55,10 +70,10 @@ uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
 	return p;
 }
 
-static int decode_blk_signature(uint32_t **pp, uint32_t *end,
+static int decode_blk_signature(uint32_t ** pp, uint32_t * end,
 				struct bl_sig *sig)
 {
-	int i, tmp;
+	int i, siglen;
 	uint32_t *p = *pp;
 
 	BLK_READBUF(p, end, 4);
@@ -73,19 +88,21 @@ static int decode_blk_signature(uint32_t **pp, uint32_t *end,
 		goto out_err;
 	}
 	for (i = 0; i < sig->si_num_comps; i++) {
+		struct bl_sig_comp *comp = &sig->si_comps[i];
+
 		BLK_READBUF(p, end, 12);
-		READ64(sig->si_comps[i].bs_offset);
-		READ32(tmp);
-		sig->si_comps[i].bs_length = tmp;
-		BLK_READBUF(p, end, tmp);
+		READ64(comp->bs_offset);
+		READ32(siglen);
+		comp->bs_length = siglen;
+		BLK_READBUF(p, end, siglen);
 		/* Note we rely here on fact that sig is used immediately
 		 * for mapping, then thrown away.
 		 */
-		sig->si_comps[i].bs_string = (char *)p;
+		comp->bs_string = (char *)p;
 		BL_LOG_INFO("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
-			   __func__, i, sig->si_comps[i].bs_length,
-			   sig->si_comps[i].bs_string);
-		p += ((tmp + 3) >> 2);
+			    __func__, i, siglen,
+			    pretty_sig(comp->bs_string, siglen));
+		p += ((siglen + 3) >> 2);
 	}
 	*pp = p;
 	return 0;
@@ -93,50 +110,45 @@ static int decode_blk_signature(uint32_t **pp, uint32_t *end,
 	return -EIO;
 }
 
-/* Read signature from device
- * return 0: read successfully
- * return -1: error
+/*
+ * Read signature from device and compare to sig_comp
+ * return: 0=match, 1=no match, -1=error
  */
-int
-read_cmp_blk_sig(const char *dev_name, struct bl_sig_comp *comp,
-		 int64_t bs_offset)
+static int
+read_cmp_blk_sig(struct bl_disk *disk, int fd, struct bl_sig_comp *comp)
 {
-	int fd, ret = -1;
+	const char *dev_name = disk->valid_path->full_path;
+	int ret = -1;
+	ssize_t siglen = comp->bs_length;
+	int64_t bs_offset = comp->bs_offset;
 	char *sig = NULL;
 
-	fd = open(dev_name, O_RDONLY | O_LARGEFILE);
-	if (fd < 0) {
-		BL_LOG_ERR("%s could not be opened for read\n", dev_name);
-		goto error;
-	}
-
-	sig = (char *)malloc(comp->bs_length);
+	sig = (char *)malloc(siglen);
 	if (!sig) {
 		BL_LOG_ERR("%s: Out of memory\n", __func__);
-		goto error;
+		goto out;
 	}
 
+	if (bs_offset < 0)
+		bs_offset += (((int64_t) disk->size) << 9);
 	if (lseek64(fd, bs_offset, SEEK_SET) == -1) {
 		BL_LOG_ERR("File %s lseek error\n", dev_name);
-		goto error;
+		goto out;
 	}
 
-	if (read(fd, sig, comp->bs_length) != comp->bs_length) {
+	if (read(fd, sig, siglen) != siglen) {
 		BL_LOG_ERR("File %s read error\n", dev_name);
-		goto error;
+		goto out;
 	}
 
-	BL_LOG_INFO
-	    ("%s: %s sig: %s, bs_string: %s, bs_length: %d, bs_offset: %lld\n",
-	     __func__, dev_name, sig, comp->bs_string, comp->bs_length,
-	     (long long)bs_offset);
-	ret = memcmp(sig, comp->bs_string, comp->bs_length);
+	ret = memcmp(sig, comp->bs_string, siglen);
+	if (!ret)
+		BL_LOG_INFO("%s: %s sig %s at %lld\n", __func__, dev_name,
+			    pretty_sig(sig, siglen), (long long)bs_offset);
 
- error:
+ out:
 	if (sig)
 		free(sig);
-	if (fd >= 0)
-		close(fd);
 	return ret;
 }
 
@@ -146,22 +158,25 @@ read_cmp_blk_sig(const char *dev_name, struct bl_sig_comp *comp,
  */
 static int verify_sig(struct bl_disk *disk, struct bl_sig *sig)
 {
+	const char *dev_name = disk->valid_path->full_path;
 	struct bl_sig_comp *comp;
-	int i, ret;
-	int64_t bs_offset;
+	int fd, i, ret;
+
+	fd = open(dev_name, O_RDONLY | O_LARGEFILE);
+	if (fd < 0) {
+		BL_LOG_ERR("%s could not be opened for read\n", dev_name);
+		return 0;
+	}
 
 	for (i = 0; i < sig->si_num_comps; i++) {
 		comp = &sig->si_comps[i];
-		bs_offset = comp->bs_offset;
-		if (bs_offset < 0)
-			bs_offset += (((int64_t) disk->size) << 9);
-		BL_LOG_INFO("%s: bs_offset: %lld\n",
-			   __func__, (long long) bs_offset);
-		ret = read_cmp_blk_sig(disk->valid_path->full_path,
-				       comp, bs_offset);
+		ret = read_cmp_blk_sig(disk, fd, comp);
 		if (ret)
 			return 0;
 	}
+
+	if (fd >= 0)
+		close(fd);
 	return 1;
 }
 
-- 
1.7.1

