Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f42.google.com ([209.85.160.42]:62219 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaAFD2s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jan 2014 22:28:48 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so18099868pbc.1
        for <linux-nfs@vger.kernel.org>; Sun, 05 Jan 2014 19:28:48 -0800 (PST)
Message-ID: <52CA22E9.9030802@gmail.com>
Date: Mon, 06 Jan 2014 11:28:41 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J.,Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFSD: fix compile warning without CONFIG_NFSD_V3
References: <01763B6D-C8CB-46B7-87AC-CE189496019A@oracle.com> <6E281EC9-49CB-4BDA-BDF3-7A6F4B703156@gmail.com> <CAB6yy34woYZaJ=k=Ga9iT_mmBWBiCUj1SprT=Se2SVrOu6YO_Q@mail.gmail.com> <5D65FDE6-D1AB-442C-BFD8-141AB87FF321@gmail.com> <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com> <52C1577B.9080100@gmail.com> <52C15847.9030208@gmail.com> <68E6D30F-B2D6-4919-9748-E7F1162AC3B7@oracle.com> <52C2377E.8040006@gmail.com> <52C2536A.5070906@gmail.com> <20140103231800.GF5164@fieldses.org>
In-Reply-To: <20140103231800.GF5164@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without CONFIG_NFSD_V3, compile will get warning as,

fs/nfsd/nfssvc.c: In function 'nfsd_svc':
>> fs/nfsd/nfssvc.c:246:60: warning: array subscript is above array bounds [-Warray-bounds]
        return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);
                                                               ^

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfssvc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 55b5b57..9a4a5f9 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -243,7 +243,11 @@ static void nfsd_shutdown_generic(void)
 
 static bool nfsd_needs_lockd(void)
 {
+#if defined(CONFIG_NFSD_V3)
 	return (nfsd_versions[2] != NULL) || (nfsd_versions[3] != NULL);
+#else
+	return (nfsd_versions[2] != NULL);
+#endif
 }
 
 static int nfsd_startup_net(int nrservs, struct net *net)
-- 
1.8.4.2
