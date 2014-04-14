Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0027.hostedemail.com ([216.40.44.27]:59898 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754033AbaDNCEw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 22:04:52 -0400
Received: from smtprelay.hostedemail.com (ff-bigip1 [10.5.19.254])
	by smtpgrave04.hostedemail.com (Postfix) with ESMTP id 9E786B1ABE
	for <linux-nfs@vger.kernel.org>; Mon, 14 Apr 2014 01:57:10 +0000 (UTC)
From: Joe Perches <joe@perches.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH -next 3.16 10/19] lockd: Convert use of typedef ctl_table to struct ctl_table
Date: Sun, 13 Apr 2014 18:55:42 -0700
Message-Id: <c69541c8e2b17be9ae9ecdaa001eea7f10cd7f26.1397438826.git.joe@perches.com>
In-Reply-To: <cover.1397438826.git.joe@perches.com>
References: <cover.1397438826.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This typedef is unnecessary and should just be removed.

Signed-off-by: Joe Perches <joe@perches.com>
---
 fs/lockd/svc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 6bf06a0..de051cb1 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -436,7 +436,7 @@ EXPORT_SYMBOL_GPL(lockd_down);
  * Sysctl parameters (same as module parameters, different interface).
  */
 
-static ctl_table nlm_sysctls[] = {
+static struct ctl_table nlm_sysctls[] = {
 	{
 		.procname	= "nlm_grace_period",
 		.data		= &nlm_grace_period,
@@ -490,7 +490,7 @@ static ctl_table nlm_sysctls[] = {
 	{ }
 };
 
-static ctl_table nlm_sysctl_dir[] = {
+static struct ctl_table nlm_sysctl_dir[] = {
 	{
 		.procname	= "nfs",
 		.mode		= 0555,
@@ -499,7 +499,7 @@ static ctl_table nlm_sysctl_dir[] = {
 	{ }
 };
 
-static ctl_table nlm_sysctl_root[] = {
+static struct ctl_table nlm_sysctl_root[] = {
 	{
 		.procname	= "fs",
 		.mode		= 0555,
-- 
1.8.1.2.459.gbcd45b4.dirty

