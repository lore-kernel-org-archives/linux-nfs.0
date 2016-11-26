Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60058 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753299AbcKZBjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Nov 2016 20:39:04 -0500
Date: Fri, 25 Nov 2016 20:39:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Eryu Guan <eguan@redhat.com>
Cc: Andreas Dilger <adilger@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>, fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] Document fstests mailing list
Message-ID: <20161126013901.GA32632@fieldses.org>
References: <20161123222054.GA7900@fieldses.org>
 <35420A4E-1698-4743-9523-CBF43F2A2DC6@dilger.ca>
 <20161125034706.GA20729@fieldses.org>
 <20161125113511.GI4609@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161125113511.GI4609@eguan.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 README | 6 ++++++
 1 file changed, 6 insertions(+)

> This looks fine to me. Can you please resend as a formal patch? Also the
> patch to fix dirstress.c.

Sure, here you go.--b.

diff --git a/README b/README
index 8a362bd51f49..9f20884ecd37 100644
--- a/README
+++ b/README
@@ -243,3 +243,9 @@ Pass/failure:
     The recent pass/fail history is maintained in the file "check.log".
     The elapsed time for the most recent pass for each test is kept
     in "check.time".
+
+__________________
+SUBMITTING PATCHES
+__________________
+
+Send patches to the fstests mailing list at fstests@vger.kernel.org.
-- 
2.9.3

