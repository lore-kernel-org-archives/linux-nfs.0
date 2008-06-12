From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 35/37] NFS: Allow any value for the "retry" option
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.86710.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755189AbYFLTeM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:12 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

The kernel NFS mount option parser should ignore the retry= mount option
since it is meaningful only in user space.  Today it expects a number
rather than arbitrary text, so it ignores the option if the value is
numeric, but chokes if there are other characters in the value.

Change it to allow any text (except ",") as its value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4461c00..dea138b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -101,6 +101,8 @@ enum {
 static match_table_t nfs_mount_option_tokens = {
 	{ Opt_userspace, "bg" },
 	{ Opt_userspace, "fg" },
+	{ Opt_userspace, "retry=%s" },
+
 	{ Opt_soft, "soft" },
 	{ Opt_hard, "hard" },
 	{ Opt_intr, "intr" },
@@ -136,7 +138,6 @@ static match_table_t nfs_mount_option_tokens = {
 	{ Opt_acdirmin, "acdirmin=%u" },
 	{ Opt_acdirmax, "acdirmax=%u" },
 	{ Opt_actimeo, "actimeo=%u" },
-	{ Opt_userspace, "retry=%u" },
 	{ Opt_namelen, "namlen=%u" },
 	{ Opt_mountport, "mountport=%u" },
 	{ Opt_mountvers, "mountvers=%u" },

