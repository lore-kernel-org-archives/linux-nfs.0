Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:60228 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965602AbcHBM51 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:27 -0400
From: Baole Ni <baolex.ni@intel.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tomi.valkeinen@ti.com, m.chehab@samsung.com,
        gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
        kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chuansheng.liu@intel.com, baolex.ni@intel.com, oneukum@suse.com
Subject: [PATCH 1052/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:12:02 +0800
Message-Id: <20160802121202.20246-1-baolex.ni@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 fs/nfs/objlayout/objlayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 919efd4..d4f003d 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -583,7 +583,7 @@ enum {
 static char osd_login_prog[OSD_LOGIN_UPCALL_PATHLEN] = "/sbin/osd_login";
 
 module_param_string(osd_login_prog, osd_login_prog, sizeof(osd_login_prog),
-		    0600);
+		    S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(osd_login_prog, "Path to the osd_login upcall program");
 
 struct __auto_login {
-- 
2.9.2

