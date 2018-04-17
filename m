Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42834 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752805AbeDQULT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 16:11:19 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 22F4E4023BAD
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 20:11:19 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 199437C37
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 20:11:19 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Fix possible stack smash in nfs_idmap_read_and_verify_message
Date: Tue, 17 Apr 2018 16:11:18 -0400
Message-Id: <20180417201118.17841-1-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nfs_idmap_read_and_verify_message there is an unprotected sprintf
that converts the __u32 'im_id' from struct idmap_msg to 'id_str'
that is a stack variable of 'NFS_UINT_MAXLEN' (defined as 11).
If a uid or gid value is > 2147483647 = 0x7fffffff we corrupt
kernel memory by one byte and if CONFIG_CC_STACKPROTECTOR_STRONG
is set we see a stack-protector panic as follows:

[11558053.616565] Kernel panic - not syncing: stack-protector: Kernel stack is corrupted in: ffffffffa05b8a8c

[11558053.639063] CPU: 6 PID: 9423 Comm: rpc.idmapd Tainted: G        W      ------------ T 3.10.0-514.el7.x86_64 #1
[11558053.641990] Hardware name: Red Hat OpenStack Compute, BIOS 1.10.2-3.el7_4.1 04/01/2014
[11558053.644462]  ffffffff818c7bc0 00000000b1f3aec1 ffff880de0f9bd48 ffffffff81685eac
[11558053.646430]  ffff880de0f9bdc8 ffffffff8167f2b3 ffffffff00000010 ffff880de0f9bdd8
[11558053.648313]  ffff880de0f9bd78 00000000b1f3aec1 ffffffff811dcb03 ffffffffa05b8a8c
[11558053.650107] Call Trace:
[11558053.651347]  [<ffffffff81685eac>] dump_stack+0x19/0x1b
[11558053.653013]  [<ffffffff8167f2b3>] panic+0xe3/0x1f2
[11558053.666240]  [<ffffffff811dcb03>] ? kfree+0x103/0x140
[11558053.682589]  [<ffffffffa05b8a8c>] ? idmap_pipe_downcall+0x1cc/0x1e0 [nfsv4]
[11558053.689710]  [<ffffffff810855db>] __stack_chk_fail+0x1b/0x30
[11558053.691619]  [<ffffffffa05b8a8c>] idmap_pipe_downcall+0x1cc/0x1e0 [nfsv4]
[11558053.693867]  [<ffffffffa00209d6>] rpc_pipe_write+0x56/0x70 [sunrpc]
[11558053.695763]  [<ffffffff811fe12d>] vfs_write+0xbd/0x1e0
[11558053.702236]  [<ffffffff810acccc>] ? task_work_run+0xac/0xe0
[11558053.704215]  [<ffffffff811fec4f>] SyS_write+0x7f/0xe0
[11558053.709674]  [<ffffffff816964c9>] system_call_fastpath+0x16/0x1b

Fix this by snprintf and a safe length based on sizeof(id_str).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
Reported-by: Stephen Johnston <sjohnsto@redhat.com>
---
 fs/nfs/nfs4idmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index 22dc30a679a0..a8c663f8dd99 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -627,7 +627,7 @@ static int nfs_idmap_read_and_verify_message(struct idmap_msg *im,
 		if (strcmp(upcall->im_name, im->im_name) != 0)
 			break;
 		/* Note: here we store the NUL terminator too */
-		len = sprintf(id_str, "%d", im->im_id) + 1;
+		len = snprintf(id_str, sizeof(id_str), "%u", im->im_id) + 1;
 		ret = nfs_idmap_instantiate(key, authkey, id_str, len);
 		break;
 	case IDMAP_CONV_IDTONAME:
-- 
2.14.3

