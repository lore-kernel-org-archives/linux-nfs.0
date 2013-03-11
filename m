Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:43299 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753735Ab3CKMF7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 08:05:59 -0400
Message-ID: <513DC8BF.5060503@cn.fujitsu.com>
Date: Mon, 11 Mar 2013 20:06:23 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: bhalevy@tonian.com
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] ctl: should return NULL when dmsetup fail in find_dm_name
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

when dmsetup fail in find_dm_name, it should return NULL,if don't
do it. it will cause core dump in get_dm when do free(name).

Signed-off-by: fanchaoting<fanchaoting@cn.fujitsu.com>

---
 ctl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ctl.c b/ctl.c
index 2071b0e..0ac1c44 100644
--- a/ctl.c
+++ b/ctl.c
@@ -489,7 +489,7 @@ find_dm_name(int major, int minor)
        if (((fd = get_output("/sbin/dmsetup", argv)) == -1) ||
            ((fp = fdopen(fd, "r")) == NULL)) {
                printf("%s: get_output/fdopen failed\n", __func__);
-               return;
+               return NULL;
        }
        while (fgets(buf, sizeof (buf), fp) != NULL) {
                t = __token_init(buf, '\t');
--
1.7.1

