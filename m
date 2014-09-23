Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 170.107.broadband6.iol.cz ([88.101.107.170]:41621 "EHLO
	unused-4-157.brq.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754575AbaIWUTK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 16:19:10 -0400
Subject: [PATCH] mountd.man: mountd tcp wrappers support only NFS v2/v3
From: Jan Chaloupka <jchaloup@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: jchaloup@redhat.com, steved@redhat.com
Date: Tue, 23 Sep 2014 09:07:33 +0200
Message-ID: <20140923070733.25555.18292.stgit@unused-4-157.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mountd tcp wrappers support only NFSv2 and NFSv3, not NFSv4.

https://bugzilla.redhat.com/show_bug.cgi?id=1116283

This patch updates the man page

Signed-off-by: Jan Chaloupka <jchaloup@redhat.com>
---
 utils/mountd/mountd.man |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index a8828ae..1aae75b 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -217,6 +217,8 @@ listeners using the
 .B tcp_wrapper
 library or
 .BR iptables (8).
+Tcp wrappers are only in effect with NFS version 2 and 3 mounts.
+They do not work with NFS version 4.
 .PP
 Note that the
 .B tcp_wrapper

