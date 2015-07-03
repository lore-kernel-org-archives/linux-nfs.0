Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33129 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932156AbbGCLfD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 07:35:03 -0400
Received: by pacws9 with SMTP id ws9so57277557pac.0
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 04:35:03 -0700 (PDT)
Message-ID: <5596735D.9080500@gmail.com>
Date: Fri, 03 Jul 2015 19:34:53 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 2/5] nfsd: Drop including client's header file nfs_fs.h
References: <559672B7.4010802@gmail.com>
In-Reply-To: <559672B7.4010802@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_fs.h is a client's header file.

# ll fs/nfsd/nfs4acl.o fs/nfsd/nfsd.ko
-rw-r--r--. 1 root root 328248 Jul  3 19:26 fs/nfsd/nfs4acl.o
-rw-r--r--. 1 root root 7452016 Jul  3 19:26 fs/nfsd/nfsd.ko

After this patch,
# ll fs/nfsd/nfs4acl.o fs/nfsd/nfsd.ko
-rw-r--r--. 1 root root 150872 Jul  3 19:15 fs/nfsd/nfs4acl.o
-rw-r--r--. 1 root root 7273792 Jul  3 19:23 fs/nfsd/nfsd.ko

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4acl.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
index eb5accf..4b939b0 100644
--- a/fs/nfsd/nfs4acl.c
+++ b/fs/nfsd/nfs4acl.c
@@ -34,8 +34,10 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/fs.h>
 #include <linux/slab.h>
-#include <linux/nfs_fs.h>
+#include <linux/posix_acl.h>
+
 #include "nfsfh.h"
 #include "nfsd.h"
 #include "acl.h"
-- 
2.4.3

