Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:41444 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751135AbeFVFGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Jun 2018 01:06:49 -0400
From: yongcheng.yang@gmail.com
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com, Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] nfsstat: fix typo causing --mounts unrecognized option
Date: Fri, 22 Jun 2018 13:06:44 +0800
Message-Id: <1529644004-15544-1-git-send-email-yongcheng.yang@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yongcheng Yang <yongcheng.yang@gmail.com>

This reverts commit acf95d32a44fd8357c24e8a04ec53fc6900bfc58

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---

Hi Steve,

To keep pace with the (nfsstat) man page, "mounted" should be replaced by "mounts".

Test logs:

[root@ nfsstat]# rpm -q nfs-utils
nfs-utils-2.3.1-xxx
[root@ nfsstat]# nfsstat --mounts
nfsstat: unrecognized option '--mounts'
Try `nfsstat --help' for more information.

[root@ nfsstat]# nfsstat.new --mounts
/mnt from localhost:/export_test
 Flags: rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp6,timeo=600,retrans=2,sec=sys,clientaddr=::1,local_lock=none,addr=::1

[root@ nfsstat]# 

Thanks,
Yongcheng

---

 utils/nfsstat/nfsstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 8fccea7..ca84532 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -340,7 +340,7 @@ static struct option longopts[] =
 	{ "all", 0, 0, 'v' },
 	{ "auto", 0, 0, '\3' },
 	{ "client", 0, 0, 'c' },
-	{ "mounted", 0, 0, 'm' },
+	{ "mounts", 0, 0, 'm' },
 	{ "nfs", 0, 0, 'n' },
 	{ "rpc", 0, 0, 'r' },
 	{ "server", 0, 0, 's' },
-- 
2.5.5

