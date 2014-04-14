Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0189.hostedemail.com ([216.40.44.189]:56362 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753897AbaDNCFd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 22:05:33 -0400
Received: from smtprelay.hostedemail.com (ff-bigip1 [10.5.19.254])
	by smtpgrave01.hostedemail.com (Postfix) with ESMTP id 4B8A35D947
	for <linux-nfs@vger.kernel.org>; Mon, 14 Apr 2014 01:57:06 +0000 (UTC)
From: Joe Perches <joe@perches.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -next 3.16 11/19] nfs: Convert use of typedef ctl_table to struct ctl_table
Date: Sun, 13 Apr 2014 18:55:43 -0700
Message-Id: <b1fdb97c4cf51a478a593bf17f6ecb6a9a158c28.1397438826.git.joe@perches.com>
In-Reply-To: <cover.1397438826.git.joe@perches.com>
References: <cover.1397438826.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/nfs/nfs4sysctl.c | 6 +++---
 fs/nfs/sysctl.c     | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4sysctl.c b/fs/nfs/nfs4sysctl.c
index 2628d92..b6ebe7e 100644
--- a/fs/nfs/nfs4sysctl.c
+++ b/fs/nfs/nfs4sysctl.c
@@ -16,7 +16,7 @@ static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
 static struct ctl_table_header *nfs4_callback_sysctl_table;
 
-static ctl_table nfs4_cb_sysctls[] = {
+static struct ctl_table nfs4_cb_sysctls[] = {
 	{
 		.procname = "nfs_callback_tcpport",
 		.data = &nfs_callback_set_tcpport,
@@ -36,7 +36,7 @@ static ctl_table nfs4_cb_sysctls[] = {
 	{ }
 };
 
-static ctl_table nfs4_cb_sysctl_dir[] = {
+static struct ctl_table nfs4_cb_sysctl_dir[] = {
 	{
 		.procname = "nfs",
 		.mode = 0555,
@@ -45,7 +45,7 @@ static ctl_table nfs4_cb_sysctl_dir[] = {
 	{ }
 };
 
-static ctl_table nfs4_cb_sysctl_root[] = {
+static struct ctl_table nfs4_cb_sysctl_root[] = {
 	{
 		.procname = "fs",
 		.mode = 0555,
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 6b3f253..bb6ed81 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -13,7 +13,7 @@
 
 static struct ctl_table_header *nfs_callback_sysctl_table;
 
-static ctl_table nfs_cb_sysctls[] = {
+static struct ctl_table nfs_cb_sysctls[] = {
 	{
 		.procname	= "nfs_mountpoint_timeout",
 		.data		= &nfs_mountpoint_expiry_timeout,
@@ -31,7 +31,7 @@ static ctl_table nfs_cb_sysctls[] = {
 	{ }
 };
 
-static ctl_table nfs_cb_sysctl_dir[] = {
+static struct ctl_table nfs_cb_sysctl_dir[] = {
 	{
 		.procname = "nfs",
 		.mode = 0555,
@@ -40,7 +40,7 @@ static ctl_table nfs_cb_sysctl_dir[] = {
 	{ }
 };
 
-static ctl_table nfs_cb_sysctl_root[] = {
+static struct ctl_table nfs_cb_sysctl_root[] = {
 	{
 		.procname = "fs",
 		.mode = 0555,
-- 
1.8.1.2.459.gbcd45b4.dirty

