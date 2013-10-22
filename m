Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0191.hostedemail.com ([216.40.44.191]:58376 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754793Ab3JVWbn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Oct 2013 18:31:43 -0400
From: Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 13/24] lockd: Convert use of typedef ctl_table to struct ctl_table
Date: Tue, 22 Oct 2013 15:29:56 -0700
Message-Id: <7dc73d7664e7f1d1cff10102bbcee82d06c6aac5.1382480758.git.joe@perches.com>
In-Reply-To: <cover.1382480758.git.joe@perches.com>
References: <cover.1382480758.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/lockd/svc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 10d6c41..140cc67 100644
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

