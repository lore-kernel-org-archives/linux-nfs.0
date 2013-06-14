Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:35101 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759888Ab3FNClD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 22:41:03 -0400
From: Joe Perches <joe@perches.com>
To: Jiri Kosina <trivial@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [Trivial PATCH 19/33] lockd: Convert use of typedef ctl_table to struct ctl_table
Date: Thu, 13 Jun 2013 19:37:44 -0700
Message-Id: <faae8e9ce146510493e5d4e807e4b2a8266edecc.1371177118.git.joe@perches.com>
In-Reply-To: <cover.1371177118.git.joe@perches.com>
References: <cover.1371177118.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/lockd/svc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index a2aa97d..7df25d7 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -435,7 +435,7 @@ EXPORT_SYMBOL_GPL(lockd_down);
  * Sysctl parameters (same as module parameters, different interface).
  */
 
-static ctl_table nlm_sysctls[] = {
+static struct ctl_table nlm_sysctls[] = {
 	{
 		.procname	= "nlm_grace_period",
 		.data		= &nlm_grace_period,
@@ -489,7 +489,7 @@ static ctl_table nlm_sysctls[] = {
 	{ }
 };
 
-static ctl_table nlm_sysctl_dir[] = {
+static struct ctl_table nlm_sysctl_dir[] = {
 	{
 		.procname	= "nfs",
 		.mode		= 0555,
@@ -498,7 +498,7 @@ static ctl_table nlm_sysctl_dir[] = {
 	{ }
 };
 
-static ctl_table nlm_sysctl_root[] = {
+static struct ctl_table nlm_sysctl_root[] = {
 	{
 		.procname	= "fs",
 		.mode		= 0555,
-- 
1.8.1.2.459.gbcd45b4.dirty

