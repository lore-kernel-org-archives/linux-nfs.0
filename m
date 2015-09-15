Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751468AbbIOOBX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2015 10:01:23 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id D146E8F305
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2015 14:01:21 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mountstats.man:  Remove a few bogus .R macros
Date: Tue, 15 Sep 2015 10:01:18 -0400
Message-Id: <1442325678-52516-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These have no effect on the rendering of the man page, but they do cause
the following error if you try to pipe or redirect the output:

`R' is a string (producing the registered sign), not a macro.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.man | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/mountstats/mountstats.man b/tools/mountstats/mountstats.man
index bfc4c46..a55130b 100644
--- a/tools/mountstats/mountstats.man
+++ b/tools/mountstats/mountstats.man
@@ -13,13 +13,13 @@ mountstats \- Displays various NFS client per-mount statistics
 .RB [ \-S | \-\-since
 .IR sincefile ]
 .\" .RB [ \-n | \-\-nfs | \-r | \-\-rpc | \-R | \-\-raw ]
-.R [
+[
 .RB [ \-n | \-\-nfs ]
-.R |
+|
 .RB [ \-r | \-\-rpc ]
-.R |
+|
 .RB  [ \-R | \-\-raw ]
-.R ]
+]
 .RI [ mountpoint ] ...
 .P
 .B mountstats iostat
-- 
1.9.3

