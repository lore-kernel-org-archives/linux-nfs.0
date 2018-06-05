Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:27676 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751816AbeFET3e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 15:29:34 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 2/2] nfs(5): update clientaddr value options
Date: Tue, 5 Jun 2018 15:29:09 -0400
Message-ID: <20180605192909.27578-2-kolga@netapp.com>
In-Reply-To: <20180605192909.27578-1-kolga@netapp.com>
References: <20180605192909.27578-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Document the use of IPv4/IPv6_ANY address as values to the clientaddr
as a way to tell the server that the client does not want delegations.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 utils/mount/nfs.man | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index bd1508c..9ee9bd9 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -835,6 +835,9 @@ to perform NFS version 4.0 callback requests against
 files on this mount point. If  the  server is unable to
 establish callback connections to clients, performance
 may degrade, or accesses to files may temporarily hang.
+Can specify a value of IPv4_ANY (0.0.0.0) or equivalent
+IPv6 any address which will signal to the NFS server that
+this NFS client does not want delegations.
 .IP
 If this option is not specified, the
 .BR mount (8)
-- 
1.8.3.1

