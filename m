Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:48281 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab1HFHlY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 03:41:24 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH 1/6] exports.man: "\* d lets man complain
Date: Sat,  6 Aug 2011 09:41:14 +0200
Message-Id: <1312616479-312-2-git-send-email-luk@debian.org>
In-Reply-To: <1312616479-312-1-git-send-email-luk@debian.org>
References: <1312616479-312-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

man complains with "macro `d' not defined", so remove these seemingly unneeded characters

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/exportfs/exports.man |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index b202583..f9e8304 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -130,7 +130,7 @@ this way are ro, rw, no_root_squash, root_squash, and all_squash.
 .BR exportfs
 understands the following export options:
 .TP
-.IR secure "\*d
+.IR secure
 This option requires that requests originate on an Internet port less
 than IPPORT_RESERVED (1024). This option is on by default. To turn it
 off, specify
-- 
1.7.5.4

