Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:47560 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab1HFJ7L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 05:59:11 -0400
From: Luk Claes <luk@debian.org>
To: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Cc: Luk Claes <luk@debian.org>
Subject: [PATCH] start-statd: Use bash as -p is no POSIX
Date: Sat,  6 Aug 2011 11:59:28 +0200
Message-Id: <1312624768-2394-1-git-send-email-luk@debian.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

sh -p is not guaranteed to be provided by POSIX shells. dash for instance does not provide this, so use bash explicitly.

Signed-off-by: Luk Claes <luk@debian.org>
---
 utils/statd/start-statd |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index c7805ee..1b345a5 100644
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -1,8 +1,8 @@
-#!/bin/sh -p
+#!/bin/bash -p
 # nfsmount calls this script when mounting a filesystem with locking
 # enabled, but when statd does not seem to be running (based on
 # /var/run/rpc.statd.pid).
-# It should run run statd with whatever flags are apropriate for this
+# It should run statd with whatever flags are apropriate for this
 # site.
 PATH=/sbin:/usr/sbin
 exec rpc.statd --no-notify
-- 
1.7.5.4

