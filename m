Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:48702 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752203Ab0I0SEB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 14:04:01 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1P0Hhr-0004af-4D
	for linux-nfs@vger.kernel.org; Mon, 27 Sep 2010 13:41:39 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Added the -p <principal> flag to the svcgssd manpage
Date: Mon, 27 Sep 2010 13:41:37 -0400
Message-Id: <1285609297-3424-3-git-send-email-steved@redhat.com>
In-Reply-To: <1285609297-3424-1-git-send-email-steved@redhat.com>
References: <1285609297-3424-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Eberhard Kuemmerle <e.kuemmerle@fz-juelich.de>

Signed-off-by:  Eberhard Kuemmerle <E.Kuemmerle@fz-juelich.de>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/svcgssd.man |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/svcgssd.man b/utils/gssd/svcgssd.man
index 1a015e1..1c7bb32 100644
--- a/utils/gssd/svcgssd.man
+++ b/utils/gssd/svcgssd.man
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.svcgssd \- server-side rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p pipefsdir]"
+.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p principal]"
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -35,7 +35,9 @@ increases the verbosity of the output (can be specified multiple times).
 .B -i
 If the nfsidmap library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
-
+.TP
+.B -p
+Use \fIprincipal\fR instead of the default nfs/host.domain.
 .SH SEE ALSO
 .BR rpc.gssd(8),
 .SH AUTHORS
-- 
1.7.2.3

