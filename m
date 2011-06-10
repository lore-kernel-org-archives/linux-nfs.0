From: greearb@candelatech.com
Subject: [PATCH v2 6/6] nfs-utils:  Update man page for srcaddr= option.
Date: Fri, 10 Jun 2011 12:41:38 -0700
Message-ID: <1307734898-12860-7-git-send-email-greearb@candelatech.com>
References: <1307734898-12860-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46874 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617Ab1FJTn3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 15:43:29 -0400
In-Reply-To: <1307734898-12860-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 be91a25... 622d7cb... M	utils/mount/nfs.man
 utils/mount/nfs.man |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index be91a25..622d7cb 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -463,6 +463,13 @@ by other clients, but can impact application and server performance.
 .IP
 The DATA AND METADATA COHERENCE section contains a
 detailed discussion of these trade-offs.
+.TP 1.5i
+.BI srcaddr= n
+Specifies a single IPv4 or IPv6 address
+to which the NFS client will bind its sockets.
+This can help force NFS to use a particular IP
+address on a multi-homed machine.  This option is not required
+in most cases.
 .SS "Options for NFS versions 2 and 3 only"
 Use these options, along with the options in the above subsection,
 for NFS versions 2 and 3 only.
-- 
1.7.3.4

