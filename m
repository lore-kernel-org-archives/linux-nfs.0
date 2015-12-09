Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752782AbbLIQBp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Dec 2015 11:01:45 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 12609C00040E
	for <linux-nfs@vger.kernel.org>; Wed,  9 Dec 2015 16:01:45 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-236-249.phx2.redhat.com [10.3.236.249])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tB9G1haF016486
	for <linux-nfs@vger.kernel.org>; Wed, 9 Dec 2015 11:01:44 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] rpc.idmapd: Added the -C and -S flags
Date: Wed,  9 Dec 2015 11:01:42 -0500
Message-Id: <1449676902-19575-2-git-send-email-steved@redhat.com>
In-Reply-To: <1449676902-19575-1-git-send-email-steved@redhat.com>
References: <1449676902-19575-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The C and S flags were missing for the SYNOPSIS

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.man | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
index c809f78..d45658e 100644
--- a/utils/idmapd/idmapd.man
+++ b/utils/idmapd/idmapd.man
@@ -10,8 +10,10 @@
 .Sh SYNOPSIS
 .\" For a program:  program [-abc] file ...
 .Nm rpc.idmapd
-.Op Fl v
 .Op Fl f
+.Op Fl v
+.Op Fl C
+.Op Fl S
 .Op Fl p Ar path
 .Op Fl c Ar path
 .Sh DESCRIPTION
-- 
2.4.3

