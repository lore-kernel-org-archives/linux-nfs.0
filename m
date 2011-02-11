Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:45622 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab1BKK3k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 05:29:40 -0500
From: Jan Engelhardt <jengelh@medozas.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] configure: reduce minimum autoconf version to 2.65
Date: Fri, 11 Feb 2011 11:29:34 +0100
Message-Id: <1297420176-24960-2-git-send-email-jengelh@medozas.de>
In-Reply-To: <1297420176-24960-1-git-send-email-jengelh@medozas.de>
References: <1297420176-24960-1-git-send-email-jengelh@medozas.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Bumping AC_PREREQ to 2.66 in commit
fac889e58e61a8547f2de07e764eb1031b47d9a0 seems unwarranted; the
constructs also work with 2.65.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 configure.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 7ad3e5f..9341db1 100644
--- a/configure.in
+++ b/configure.in
@@ -1,7 +1,7 @@
 #                                               -*- Autoconf -*-
 # Process this file with autoconf to produce a configure script.
 
-AC_PREREQ([2.66])
+AC_PREREQ([2.65])
 AC_INIT([libnfsidmap],[0.24],[linux-nfs@vger.kernel.org])
 AC_CONFIG_SRCDIR([nfsidmap.h])
 AC_CONFIG_MACRO_DIR([m4])
-- 
1.7.1

