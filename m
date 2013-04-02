Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759752Ab3DBRtO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 13:49:14 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnDLu019607
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:14 -0400
Received: from willson.li.ssimo.org.com (ovpn-113-117.phx2.redhat.com [10.3.113.117])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnB4I006259
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:13 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] Document new -N option
Date: Tue,  2 Apr 2013 13:49:07 -0400
Message-Id: <1364924947-16985-4-git-send-email-simo@redhat.com>
In-Reply-To: <1364924947-16985-1-git-send-email-simo@redhat.com>
References: <1364924947-16985-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Options are not in alphabetical order but I put the new one after the -M,
let's see this slow bubble sort algorithm to go on in the next decade :)

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/gssd.man |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 79d9bf91ac6b976c57d167e60d07f828a3ff5b1f..d1851eb0c39d8fda3da6020b35566d391fe2daba 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -8,7 +8,7 @@
 rpc.gssd \- RPCSEC_GSS daemon
 .SH SYNOPSIS
 .B rpc.gssd
-.RB [ \-fMnlvr ]
+.RB [ \-fMnlvrN ]
 .RB [ \-k
 .IR keytab ]
 .RB [ \-p
@@ -245,6 +245,15 @@ is set,
 .B rpc.gssd
 stores machine credentials in memory instead.
 .TP
+.B -N [on|off]
+When -N is set to
+.BR on
+the program tries to avoid DNS Reverse (PTR) lookups for resolving the server 
+name if the name passed at mount point is not an IP address. 
+Currently defaults to
+.BR off
+for compatibility reasons.
+.TP
 .B -v
 Increases the verbosity of the output (can be specified multiple times).
 .TP
-- 
1.7.1

