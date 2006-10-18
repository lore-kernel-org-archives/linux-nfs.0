From: Paul Jackson <pj@sgi.com>
Subject: [PATCH] lib cpumask.c should include nodemask.h
Date: Wed, 18 Oct 2006 01:13:36 -0700
Message-ID: <20061018081336.18477.55297.sendpatchset@sam.engr.sgi.com>
Cc: neilb@suse.de, nfs@lists.sourceforge.net,
	Paul Jackson <pj@sgi.com>, linux-kernel@vger.kernel.org,
	gnb@melbourne.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932095AbWJRIOq@vger.kernel.org>
To: akpm@osdl.org
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Paul Jackson <pj@sgi.com>

With the addition of some nodemask related code to lib/cpumask.c, we
should now include nodemask.h in this file for the for_each_node_mask()
and node_possible_map definitions.

Signed-off-by: Paul Jackson <pj@sgi.com>

---

 lib/cpumask.c |    1 +
 1 files changed, 1 insertion(+)

--- 2.6.19-rc2-mm1.orig/lib/cpumask.c	2006-10-17 17:36:23.000000000 -0700
+++ 2.6.19-rc2-mm1/lib/cpumask.c	2006-10-17 17:37:23.000000000 -0700
@@ -1,6 +1,7 @@
 #include <linux/kernel.h>
 #include <linux/bitops.h>
 #include <linux/cpumask.h>
+#include <linux/nodemask.h>
 #include <linux/module.h>
 
 int __first_cpu(const cpumask_t *srcp)

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
