Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751866AbdI2HEB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 29 Sep 2017 03:04:01 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6A57781DE1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Sep 2017 07:04:01 +0000 (UTC)
From: Eryu Guan <eguan@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J . Bruce Fields" <bfields@redhat.com>,
        Eryu Guan <eguan@redhat.com>
Subject: [PATCH] nfsd4: define nfsd4_secinfo_no_name_release()
Date: Fri, 29 Sep 2017 15:01:10 +0800
Message-Id: <20170929070110.13442-1-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 34b1744c91cc ("nfsd4: define ->op_release for compound ops")
defined a couple ->op_release functions and run them if necessary.

But there's a problem with that is that it reused
nfsd4_secinfo_release() as the op_release of OP_SECINFO_NO_NAME, and
caused a leak on struct nfsd4_secinfo_no_name in
nfsd4_encode_secinfo_no_name(), because there's no .si_exp field in
struct nfsd4_secinfo_no_name.

I found this because I was unable to umount an ext4 partition after
exporting it via NFS & run fsstress on the nfs mount. A simplified
reproducer would be:

 # mount a local-fs device at /mnt/test, and export it via NFS with
 # fsid=0 export option (this is required)
 mount /dev/sda5 /mnt/test
 echo "/mnt/test *(rw,no_root_squash,fsid=0)" >> /etc/exports
 service nfs restart

 # locally mount the nfs export with all default, note that I have
 # nfsv4.1 configured as the default nfs version, because of the
 # fsid export option, v4 mount would fail and fall back to v3
 mount localhost:/mnt/test /mnt/nfs

 # try to umount the underlying device, but got EBUSY
 umount /mnt/nfs
 service nfs stop
 umount /mnt/test <=== EBUSY here

Fixed it by defining a separate nfsd4_secinfo_no_name_release()
function as the op_release method of OP_SECINFO_NO_NAME that
releases the correct nfsd4_secinfo_no_name structure.

Fixes: 34b1744c91cc ("nfsd4: define ->op_release for compound ops")
Signed-off-by: Eryu Guan <eguan@redhat.com>
---
 fs/nfsd/nfs4proc.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3c69db7d4905..8487486ec496 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -927,6 +927,13 @@ nfsd4_secinfo_release(union nfsd4_op_u *u)
 		exp_put(u->secinfo.si_exp);
 }
 
+static void
+nfsd4_secinfo_no_name_release(union nfsd4_op_u *u)
+{
+	if (u->secinfo_no_name.sin_exp)
+		exp_put(u->secinfo_no_name.sin_exp);
+}
+
 static __be32
 nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      union nfsd4_op_u *u)
@@ -2375,7 +2382,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_SECINFO_NO_NAME] = {
 		.op_func = nfsd4_secinfo_no_name,
-		.op_release = nfsd4_secinfo_release,
+		.op_release = nfsd4_secinfo_no_name_release,
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
 		.op_rsize_bop = nfsd4_secinfo_rsize,
-- 
2.13.6

