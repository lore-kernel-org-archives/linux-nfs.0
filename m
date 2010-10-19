From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 2/2] Updated rpc.mountd man page
Date: Tue, 19 Oct 2010 16:00:25 -0400
Message-ID: <1287518425-12962-3-git-send-email-steved@redhat.com>
References: <1287518425-12962-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520Ab0JST4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Oct 2010 15:56:07 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o9JJu7he032002
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 15:56:07 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx08.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o9JJu6hL028627
	for <linux-nfs@vger.kernel.org>; Tue, 19 Oct 2010 15:56:07 -0400
In-Reply-To: <1287518425-12962-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Updated the rpc.mountd man page to no longer reference
v3 as the "newer" version and also mentioned v4 as
a supported version.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/mountd.man |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index 4bb96e8..016a357 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -106,11 +106,11 @@ This option can be used to request that
 .B rpc.mountd
 do not offer certain versions of NFS. The current version of
 .B rpc.mountd
-can support both NFS version 2 and the newer version 3. If the
-NFS kernel module was compiled without support for NFSv3,
+can support both NFS version 2, 3 and 4. If the
+either one of these version should not be offered,
 .B rpc.mountd
 must be invoked with the option
-.B "\-\-no-nfs-version 3" .
+.B "\-\-no-nfs-version <vers>" .
 .TP
 .B \-n " or " \-\-no-tcp
 Don't advertise TCP for mount.
-- 
1.7.2.3

