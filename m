Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37124 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbbAZITs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jan 2015 03:19:48 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so7130264iga.0
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2015 00:19:48 -0800 (PST)
From: Eryu Guan <guaneryu@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Eryu Guan <guaneryu@gmail.com>
Subject: [nfs-utils PATCH] tests: fix typo and let make check work again
Date: Mon, 26 Jan 2015 16:19:41 +0800
Message-Id: <1422260381-29231-1-git-send-email-guaneryu@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Comments in bash starts with '#' not '*'

This has been broken since 2011 by

1254448 pdate addres for Free Software Foundation

Signed-off-by: Eryu Guan <guaneryu@gmail.com>
---
 tests/t0001-statd-basic-mon-unmon.sh | 2 +-
 tests/test-lib.sh                    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tests/t0001-statd-basic-mon-unmon.sh b/tests/t0001-statd-basic-mon-unmon.sh
index 51f0d22..92517a1 100755
--- a/tests/t0001-statd-basic-mon-unmon.sh
+++ b/tests/t0001-statd-basic-mon-unmon.sh
@@ -16,7 +16,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation, Inc.,
-* 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
+# 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
 #
 
 . ./test-lib.sh
diff --git a/tests/test-lib.sh b/tests/test-lib.sh
index ce4ecff..57af37b 100644
--- a/tests/test-lib.sh
+++ b/tests/test-lib.sh
@@ -16,7 +16,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program; if not, write to the Free Software Foundation, Inc.,
-* 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
+# 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA
 #
 
 # make sure $srcdir is set and sanity check it
-- 
2.1.0

