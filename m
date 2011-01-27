Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636Ab1A0Sth (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jan 2011 13:49:37 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0RInbYF006567
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:37 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p0RInZcS018723
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:36 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/3] cthon04: add "nowarn" option to nroff.in tables
Date: Thu, 27 Jan 2011 13:49:34 -0500
Message-Id: <1296154174-13076-4-git-send-email-steved@redhat.com>
In-Reply-To: <1296154174-13076-1-git-send-email-steved@redhat.com>
References: <1296154174-13076-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Jeff Layton <jlayton@redhat.com>

This prevents the tbl preprocessor from stuffing warnings into the
resulting file, which subsequently can make nroff spew warnings like
this on stderr:
    warning: file `nroff.in', around line 47:
	  table wider than line width

Unfortunately, I'm not sure how non-gnu tbl programs will react to
this option, so YMMV.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 general/nroff.in |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/general/nroff.in b/general/nroff.in
index 5722733..ff57200 100644
--- a/general/nroff.in
+++ b/general/nroff.in
@@ -38,12 +38,12 @@ A bubble sort of integers.
 A prime number generator.
 .LP
 .TS
-center;
- c|c|c s|
- c|c|c s|
- c|c|c s|
- c|c|c s|
-|l|n|n|n|.
+center nowarn;
+ c|c|c s|c s|
+ c|c|c s|c s|
+ c|c|c s|c s|
+ c|c|c s|c s|
+|l|n|n|n|n|n|.
 	_	_	_	_	_
 .sp 4p
 	Matrix Inversion	Bubble Sort	Prime Numbers
-- 
1.7.3.3

