Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8978 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516Ab1A0Stg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jan 2011 13:49:36 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0RInan3024794
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:36 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p0RInZcR018723
	for <linux-nfs@vger.kernel.org>; Thu, 27 Jan 2011 13:49:36 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] Make the tbl table smaller to avoid a warning about line width
Date: Thu, 27 Jan 2011 13:49:33 -0500
Message-Id: <1296154174-13076-3-git-send-email-steved@redhat.com>
In-Reply-To: <1296154174-13076-1-git-send-email-steved@redhat.com>
References: <1296154174-13076-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 general/nroff.in |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/general/nroff.in b/general/nroff.in
index 522ac80..5722733 100644
--- a/general/nroff.in
+++ b/general/nroff.in
@@ -39,11 +39,11 @@ A prime number generator.
 .LP
 .TS
 center;
- c|c|c s|c s|
- c|c|c s|c s|
- c|c|c s|c s|
- c|c|c s|c s|
-|l|n|n|n|n|n|.
+ c|c|c s|
+ c|c|c s|
+ c|c|c s|
+ c|c|c s|
+|l|n|n|n|.
 	_	_	_	_	_
 .sp 4p
 	Matrix Inversion	Bubble Sort	Prime Numbers
-- 
1.7.3.3

