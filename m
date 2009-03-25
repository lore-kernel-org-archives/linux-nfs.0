From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH 2.2] CAP_FS_MASK: add CAP_LINUX_IMMUTABLE
Date: Wed, 25 Mar 2009 12:39:04 -0500
Message-ID: <20090325173904.GA19269@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mtk.manpages@gmail.com, Stephen Smalley <sds@epoch.ncsc.mil>,
	Andrew Morgan <morgan@kernel.org>,
	linux-security-module@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Igor Zhbanov <izh1979@gmail.com>, stable@kernel.org,
	linux-api@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>
To: Marc-Christian Petersen <m.c.p@wolk-project.de>
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When POSIX capabilities were introduced during the 2.1 Linux
cycle, the fs mask, which represents the capabilities which having
fsuid==0 is supposed to grant, did not include CAP_MKNOD and
CAP_LINUX_IMMUTABLE.  However, before capabilities the privilege
to call these did in fact depend upon fsuid==0.

However, 2.2 does not have CAP_MKNOD, instead using CAP_SYS_ADMIN
to authorize sys_mknod.  We don't want to put CAP_SYS_ADMIN in
CAP_FS_MASK because it carries too many non-fs implications.

This patch introduces CAP_LINUX_IMMUTABLE into the fsmask.

See the thread starting at http://lkml.org/lkml/2009/3/11/157 for
reference.

Reported-by: Igor Zhbanov <izh1979@gmail.com>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Cc: stable@kernel.org
---
 include/linux/capability.h |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff -Nrup linux-2.2.26/include/linux/capability.h linux-2.2.26.new/include/linux/capability.h
--- linux-2.2.26/include/linux/capability.h	2004-02-23 07:44:47.000000000 -0600
+++ linux-2.2.26.new/include/linux/capability.h	2009-03-25 11:12:08.000000000 -0500
@@ -98,10 +98,6 @@ typedef __u32 kernel_cap_t;
 
 #define CAP_FSETID           4
 
-/* Used to decide between falling back on the old suser() or fsuser(). */
-
-#define CAP_FS_MASK          0x1f
-
 /* Overrides the restriction that the real or effective user ID of a
    process sending a signal must match the real or effective user ID
    of the process receiving the signal. */
@@ -288,6 +284,15 @@ extern kernel_cap_t cap_bset;
 
 #endif
 
+/* Used to decide between falling back on the old suser() or fsuser(). */
+
+#define CAP_FS_MASK	(CAP_TO_MASK(CAP_CHOWN)			\
+			| CAP_TO_MASK(CAP_DAC_OVERRIDE)		\
+			| CAP_TO_MASK(CAP_DAC_READ_SEARCH)	\
+			| CAP_TO_MASK(CAP_FOWNER)		\
+			| CAP_TO_MASK(CAP_FSETID)		\
+			| CAP_TO_MASK(CAP_LINUX_IMMUTABLE))
+
 #define CAP_EMPTY_SET       to_cap_t(0)
 #define CAP_FULL_SET        to_cap_t(~0)
 #define CAP_INIT_EFF_SET    to_cap_t(~0 & ~CAP_TO_MASK(CAP_SETPCAP))
