From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 6/6] nfs-utils: add -4 and -6 options to nfsd manpage
Date: Tue, 26 May 2009 11:15:51 -0400
Message-ID: <1243350951-13462-7-git-send-email-jlayton@redhat.com>
References: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46743 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422AbZEZPP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 May 2009 11:15:58 -0400
In-Reply-To: <1243350951-13462-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.man |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 4eb3e21..f4c0475 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -22,6 +22,16 @@ server provides an ancillary service needed to satisfy mount requests
 by NFS clients.
 .SH OPTIONS
 .TP
+.B \-4
+Disable
+.B rpc.nfsd
+listening on IPv4 sockets.
+.TP
+.B \-6
+Disable
+.B rpc.nfsd
+listening on IPv6 sockets.
+.TP
 .B \-H " or " \-\-host  hostname
 specify a particular hostname (or address) that NFS requests will
 be accepted on. By default,
-- 
1.6.0.6

