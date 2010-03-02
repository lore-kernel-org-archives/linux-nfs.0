From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/7] nfsd4: edit comment for concision
Date: Tue,  2 Mar 2010 18:12:48 -0500
Message-ID: <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54592 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753054Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
In-Reply-To: <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also note units are seconds.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsctl.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 8bff674..f1ee549 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1228,23 +1228,14 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 /**
  * write_leasetime - Set or report the current NFSv4 lease time
  *
- * Input:
- *			buf:		ignored
- *			size:		zero
+ * If given a nonzero size, sets the NFSv4 lease time to a number of
+ * seconds (interpreting buf as a C string containing an ascii
+ * representation of the number).
  *
- * OR
+ * Returns the resulting lease time (as an ascii representation in a
+ * '\n'-terminated C string) in buf.
  *
- * Input:
- *			buf:		C string containing an unsigned
- *					integer value representing the new
- *					NFSv4 lease expiry time
- *			size:		non-zero length of C string in @buf
- * Output:
- *	On success:	passed-in buffer filled with '\n'-terminated C
- *			string containing unsigned integer value of the
- *			current lease expiry time;
- *			return code is the size in bytes of the string
- *	On error:	return code is zero or a negative errno value
+ * Given a zero size, just returns the lease time in buf.
  */
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 {
-- 
1.6.3.3

