Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55048 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754972AbeFNNcj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 09:32:39 -0400
Date: Thu, 14 Jun 2018 09:32:38 -0400
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] exports: document change to "insecure" export option
Message-ID: <20180614133238.GA24594@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We're changing the kernel to allow gss requests from high ports even
when "secure" is set.

If the change gets backported to distro kernels, the kernel version may
be an imperfect predictor of the behavior, but I think it's the best we
can do.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/exportfs/exports.man | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 4f95f3a2197e..e3a16f6b276a 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -131,10 +131,12 @@ this way are ro, rw, no_root_squash, root_squash, and all_squash.
 understands the following export options:
 .TP
 .IR secure
-This option requires that requests originate on an Internet port less
-than IPPORT_RESERVED (1024). This option is on by default. To turn it
-off, specify
+This option requires that requests not using gss originate on an
+Internet port less than IPPORT_RESERVED (1024). This option is on by default.
+To turn it off, specify
 .IR insecure .
+(NOTE: older kernels (before upstream kernel version 4.17) enforced this
+requirement on gss requests as well.)
 .TP
 .IR rw
 Allow both read and write requests on this NFS volume. The
-- 
2.17.1

