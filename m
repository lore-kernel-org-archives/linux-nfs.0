From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/3] CIFS: ignore mode change if it's just for clearing setuid/setgid bits
Date: Thu, 30 Aug 2007 11:06:59 -0400
Message-ID: <200708301506.l7UF6xHg002143@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

If the ATTR_KILL_S*ID bits are set then any mode change is only for
clearing the setuid/setgid bits. For CIFS, skip the mode change and
let the server handle it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/cifs/inode.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index dd41677..279f3c5 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -1538,6 +1538,11 @@ int cifs_setattr(struct dentry *direntry, struct iattr *attrs)
 	}
 
 	time_buf.Attributes = 0;
+
+	/* skip mode change if it's just for clearing setuid/setgid */
+	if (attrs->ia_valid & (ATTR_KILL_SUID|ATTR_KILL_SGID))
+		attrs->ia_valid &= ~ATTR_MODE;
+
 	if (attrs->ia_valid & ATTR_MODE) {
 		cFYI(1, ("Mode changed to 0x%x", attrs->ia_mode));
 		mode = attrs->ia_mode;
-- 
1.5.2.1

