From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] lockd: bring a few function declarations up to date
Date: Fri, 14 Mar 2008 14:18:45 -0400
Message-ID: <20080314181844.29948.14864.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:31002 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256AbYCNSTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:19:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean-up: replace  __inline__ and use up-to-date function declaration
conventions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/lockd/lockd.h |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index d155950..acf39e1 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -219,8 +219,7 @@ void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 
-static __inline__ struct inode *
-nlmsvc_file_inode(struct nlm_file *file)
+static inline struct inode *nlmsvc_file_inode(struct nlm_file *file)
 {
 	return file->f_file->f_path.dentry->d_inode;
 }
@@ -228,8 +227,8 @@ nlmsvc_file_inode(struct nlm_file *file)
 /*
  * Compare two host addresses (needs modifying for ipv6)
  */
-static __inline__ int
-nlm_cmp_addr(const struct sockaddr_in *sin1, const struct sockaddr_in *sin2)
+static inline int nlm_cmp_addr(const struct sockaddr_in *sin1,
+			       const struct sockaddr_in *sin2)
 {
 	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
 }
@@ -238,8 +237,8 @@ nlm_cmp_addr(const struct sockaddr_in *sin1, const struct sockaddr_in *sin2)
  * Compare two NLM locks.
  * When the second lock is of type F_UNLCK, this acts like a wildcard.
  */
-static __inline__ int
-nlm_compare_locks(const struct file_lock *fl1, const struct file_lock *fl2)
+static inline int nlm_compare_locks(const struct file_lock *fl1,
+				    const struct file_lock *fl2)
 {
 	return	fl1->fl_pid   == fl2->fl_pid
 	     && fl1->fl_owner == fl2->fl_owner

