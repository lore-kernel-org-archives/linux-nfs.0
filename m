Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59102 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab1HAWfJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2011 18:35:09 -0400
Date: Mon, 1 Aug 2011 18:35:04 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org,
        Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH 0/6] pynfs patches
Message-ID: <20110801223503.GB10680@fieldses.org>
References: <1311883384-20260-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311883384-20260-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 28, 2011 at 04:02:58PM -0400, J. Bruce Fields wrote:
> This fixes a RECLAIM_COMPLETE bug that makes the tests work for me
> again.
> 
> And also try sharing a few more things between 4.0 and 4.1.
> 
> The same patches are available from
> 
> 	git://linux-nfs.org/~bfields/pynfs.git master
> 
> My biggest remaining annoyance is that the rename tests all go over the
> nfs server's maximum op count.  pynfs should really be smart enough to
> do the lookups in reasonable chunks.  Or we could probably find a
> simpler workaround for the rename case.

Here's a hack for the case of rename, also applied on top of the
"master" branch above.

I'd also like to make all lookups relative to the root of the test
tree--that just makes sense anyway, and it'd make the maximum length of
paths used a property of the tests rather than of the environment (so
somebody doesn't get different results just because their test tree is
at a longer path).

The obstacle is the useblock/usechar/etc. options which take absolute
paths.  Maybe they should just be looked up once at the start.

--b.

>From 9a477cc5f3ffa3a956f68f5c5b08860f3360c2a4 Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@redhat.com>
Date: Mon, 1 Aug 2011 18:05:43 -0400
Subject: [PATCH] server41tests: separate lookup from rename

The length of the rename compounds is ridiculous, and can cause spurious
failures against the linux server, depending on the length of the path
to the pynfs test root.

So do the lookups in separate compounds from the rename itself.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 nfs4.1/server41tests/environment.py |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index b987e9d..43cb12b 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -545,12 +545,19 @@ def maketree(sess, tree, root=None, owner=None):
         else:
             create_confirm(sess, owner, root + [obj])
 
+def lookup_obj(sess, path):
+    compound = [op.putrootfh()]
+    compound += [op.lookup(comp) for comp in path]
+    compound += [op.getfh()]
+    res = sess.compound(compound)
+    check(res)
+    return res.resarray[-1].object
+
 def rename_obj(sess, oldpath, newpath):
-    # Set (sfh) to olddir
-    ops = use_obj(oldpath[:-1]) + [op.savefh()]
-    # Set (cfh) to newdir
-    ops += use_obj(newpath[:-1])
-    # Call rename
+    olddir = lookup_obj(sess, oldpath[:-1])
+    newdir = lookup_obj(sess, newpath[:-1])
+    ops =  [op.putfh(olddir), op.savefh()]
+    ops += [op.putfh(newdir)]
     ops += [op.rename(oldpath[-1], newpath[-1])]
     return sess.compound(ops)
 
-- 
1.7.4.1

