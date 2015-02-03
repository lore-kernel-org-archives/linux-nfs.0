Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx143.netapp.com ([216.240.21.24]:27293 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966485AbbBCVJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Feb 2015 16:09:50 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH] fsx: check for filesystem support of FALLOCATE_FL_KEEP_SIZE
Date: Tue, 3 Feb 2015 16:09:43 -0500
Message-ID: <1422997783-22484-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS implementation of fallocate() does not support passing the
KEEP_SIZE flag by itself, causing tests to randomly fail.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 ltp/fsx.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/ltp/fsx.c b/ltp/fsx.c
index 3709419..0bb8ae8 100644
--- a/ltp/fsx.c
+++ b/ltp/fsx.c
@@ -142,6 +142,7 @@ int	randomoplen = 1;		/* -O flag disables it */
 int	seed = 1;			/* -S flag */
 int     mapped_writes = 1;              /* -W flag disables */
 int     fallocate_calls = 1;            /* -F flag disables */
+int     keep_size_calls = 1;            /* -K flag disables */
 int     punch_hole_calls = 1;           /* -H flag disables */
 int     zero_range_calls = 1;           /* -z flag disables */
 int	collapse_range_calls = 1;	/* -C flag disables */
@@ -907,7 +908,7 @@ do_zero_range(unsigned offset, unsigned length)
 {
 	unsigned end_offset;
 	int mode = FALLOC_FL_ZERO_RANGE;
-	int keep_size;
+	int keep_size = 0;
 
 	if (length == 0) {
 		if (!quiet && testcalls > simulatedopcount)
@@ -916,7 +917,8 @@ do_zero_range(unsigned offset, unsigned length)
 		return;
 	}
 
-	keep_size = random() % 2;
+	if (keep_size_calls)
+		keep_size = random() % 2;
 
 	end_offset = keep_size ? 0 : offset + length;
 
@@ -1018,7 +1020,7 @@ void
 do_preallocate(unsigned offset, unsigned length)
 {
 	unsigned end_offset;
-	int keep_size;
+	int keep_size = 0;
 
         if (length == 0) {
                 if (!quiet && testcalls > simulatedopcount)
@@ -1027,7 +1029,8 @@ do_preallocate(unsigned offset, unsigned length)
                 return;
         }
 
-	keep_size = random() % 2;
+	if (keep_size_calls)
+		keep_size = random() % 2;
 
 	end_offset = keep_size ? 0 : offset + length;
 
@@ -1493,7 +1496,7 @@ main(int argc, char **argv)
 
 	setvbuf(stdout, (char *)0, _IOLBF, 0); /* line buffered stdout */
 
-	while ((ch = getopt(argc, argv, "b:c:dfl:m:no:p:qr:s:t:w:xyAD:FHzCLN:OP:RS:WZ"))
+	while ((ch = getopt(argc, argv, "b:c:dfl:m:no:p:qr:s:t:w:xyAD:FKHzCLN:OP:RS:WZ"))
 	       != EOF)
 		switch (ch) {
 		case 'b':
@@ -1590,6 +1593,9 @@ main(int argc, char **argv)
 		case 'F':
 			fallocate_calls = 0;
 			break;
+		case 'K':
+			keep_size_calls = 0;
+			break;
 		case 'H':
 			punch_hole_calls = 0;
 			break;
@@ -1751,6 +1757,8 @@ main(int argc, char **argv)
 
 	if (fallocate_calls)
 		fallocate_calls = test_fallocate(0);
+	if (keep_size_calls)
+		keep_size_calls = test_fallocate(FALLOC_FL_KEEP_SIZE);
 	if (punch_hole_calls)
 		punch_hole_calls = test_fallocate(FALLOC_FL_PUNCH_HOLE |
 						  FALLOC_FL_KEEP_SIZE);
-- 
2.2.2

