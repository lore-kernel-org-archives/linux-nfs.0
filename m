Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB262C433F5
	for <linux-nfs@archiver.kernel.org>; Sat,  5 Mar 2022 00:37:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230267AbiCEAiO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 4 Mar 2022 19:38:14 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50392 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229587AbiCEAiN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2022 19:38:13 -0500
Received: from mx0a-00069f02.pphosted.com (mx0a-00069f02.pphosted.com [205.220.165.32])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 659792590E3;
        Fri,  4 Mar 2022 16:37:24 -0800 (PST)
Received: from pps.filterd (m0246617.ppops.net [127.0.0.1])
        by mx0b-00069f02.pphosted.com (8.16.1.2/8.16.1.2) with SMTP id 224Jx5ms020770;
        Sat, 5 Mar 2022 00:37:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2021-07-09;
 bh=t6BjpuZ9RtInSf1gfShJDJd5eYJCYibRkA8U7Opka74=;
 b=MF6+lLxBLOg1mz8gbHsrCNMrCYsrh2fQ1VnW+Z3bF+C+iTIOtsthZFuy88yPvul7OiJG
 uJ8y2QNAOgX4STL9aWtuck1ph7tXFVw5PHxlMzU4CvPeYbynz/g/UZjb5dtthhVVVMF5
 gNx/kA5/RwQv+B2Gdp59W/lIxy+J9djNU5rzbW6uK143zUiz+Apbb7Dpz2LDPiKbcxKr
 8DIESOXN39B5akOStPyqtm3vaAGX7jZT0QlnMK1pi686fjBQaLA/BYPxLZ6TqNSt1jVN
 niMa37cf27X9ULta/zxpYdHuCF/XQcPJQ23R3QMISdf9kzbaK/F+vXtiIhuYeK5NdStv ng== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
        by mx0b-00069f02.pphosted.com with ESMTP id 3ek4hw36jm-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 05 Mar 2022 00:37:21 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
        by aserp3030.oracle.com (8.16.1.2/8.16.1.2) with SMTP id 2250PxNV146639;
        Sat, 5 Mar 2022 00:37:20 GMT
Received: from pps.reinject (localhost [127.0.0.1])
        by aserp3030.oracle.com with ESMTP id 3ek4jh9bfj-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 05 Mar 2022 00:37:20 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
        by pps.reinject (8.16.0.36/8.16.0.36) with SMTP id 2250bJaF161402;
        Sat, 5 Mar 2022 00:37:20 GMT
Received: from ca-common-hq.us.oracle.com (ca-common-hq.us.oracle.com [10.211.9.209])
        by aserp3030.oracle.com with ESMTP id 3ek4jh9bfb-2;
        Sat, 05 Mar 2022 00:37:20 +0000
From:   Dai Ngo <dai.ngo@oracle.com>
To:     chuck.lever@oracle.com, bfields@fieldses.org
Cc:     jlayton@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH RFC v15 01/11] fs/lock: add helper locks_any_blockers to check for blockers
Date:   Fri,  4 Mar 2022 16:37:03 -0800
Message-Id: <1646440633-3542-2-git-send-email-dai.ngo@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1646440633-3542-1-git-send-email-dai.ngo@oracle.com>
References: <1646440633-3542-1-git-send-email-dai.ngo@oracle.com>
X-Proofpoint-ORIG-GUID: Pu-QuOWtoSgfKJfyc3DOh6xMjmkSidg1
X-Proofpoint-GUID: Pu-QuOWtoSgfKJfyc3DOh6xMjmkSidg1
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add helper locks_any_blockers to check if there is any blockers
for a file_lock.

Signed-off-by: Dai Ngo <dai.ngo@oracle.com>
---
 include/linux/fs.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 831b20430d6e..7f5756bfcc13 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1200,6 +1200,11 @@ extern void lease_unregister_notifier(struct notifier_block *);
 struct files_struct;
 extern void show_fd_locks(struct seq_file *f,
 			 struct file *filp, struct files_struct *files);
+
+static inline bool locks_has_blockers_locked(struct file_lock *lck)
+{
+	return !list_empty(&lck->fl_blocked_requests);
+}
 #else /* !CONFIG_FILE_LOCKING */
 static inline int fcntl_getlk(struct file *file, unsigned int cmd,
 			      struct flock __user *user)
@@ -1335,6 +1340,11 @@ static inline int lease_modify(struct file_lock *fl, int arg,
 struct files_struct;
 static inline void show_fd_locks(struct seq_file *f,
 			struct file *filp, struct files_struct *files) {}
+
+static inline bool locks_has_blockers_locked(struct file_lock *lck)
+{
+	return false;
+}
 #endif /* !CONFIG_FILE_LOCKING */
 
 static inline struct inode *file_inode(const struct file *f)
-- 
2.9.5

