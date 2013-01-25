Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:53643 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751218Ab3AYIvs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2013 03:51:48 -0500
Message-ID: <510247B8.4020207@cn.fujitsu.com>
Date: Fri, 25 Jan 2013 16:52:08 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Check the nfsd support version when enable or disable
 the minorversion
References: <50FFB43A.8030105@cn.fujitsu.com> <20130123232458.GB6565@fieldses.org>
In-Reply-To: <20130123232458.GB6565@fieldses.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

when enable or disable the minorversion throw /proc/fs/nfsd/versions,
it should check the support version. now only nfs4 suppport minorversion.

Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>

---
 fs/nfsd/nfsctl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7493428..65889ec 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -534,7 +534,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
                        else
                                num = simple_strtol(vers, &minorp, 0);
                        if (*minorp == '.') {
-                               if (num < 4)
+                               if (num != 4)
                                        return -EINVAL;
                                minor = simple_strtoul(minorp+1, NULL, 0);
                                if (minor == 0)
--
1.7.10.1

