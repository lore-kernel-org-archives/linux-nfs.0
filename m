From: Li Yewang <lyw@cn.fujitsu.com>
Subject: [PATCH] nfs:correct the spelling error
Date: Fri, 14 Mar 2008 08:49:03 +0800
Message-ID: <47D9CB7F.6060803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62302 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754007AbYCNAwi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 20:52:38 -0400
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 7751B170130
	for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 08:52:26 +0800 (CST)
Received: from fnst.cn.fujitsu.com (fnstmail.fnst.cn.fujitsu.com [10.167.129.18])
	by tang.cn.fujitsu.com (8.13.1/8.13.1) with ESMTP id m2E0qP5t022118
	for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 08:52:26 +0800
Received: from [10.167.141.206] (unknown [10.167.141.206])
	by fnst.cn.fujitsu.com (Postfix) with ESMTP id ECD98DC0A2
	for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 08:56:17 +0800 (CST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Correct the spelling error

Signed-off-by:Li Yewang <lyw@cn.fujitsu.com>

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 3d2ebb1..0c878fa 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -475,7 +475,7 @@ static int nfsmnt_check_compat(const struct pmap *nfs_pmap,
 	}
 
 	if (mnt_pmap->pm_vers > max_mnt_vers) {
-		nfs_error(_("%s: NFS mount version %ld s not supported"),
+		nfs_error(_("%s: NFS mount version %ld is not supported"),
 				progname, mnt_pmap->pm_vers);
 		goto out_bad;
 	}
