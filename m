Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.126.130]:59247 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381AbbBPLyX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Feb 2015 06:54:23 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: linaro-kernel@lists.linaro.org
Cc: Daniel Thompson <daniel.thompson@linaro.org>,
        Christoph Hellwig <hch@lst.de>, patches@linaro.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Fix v2-only build regression
Date: Mon, 16 Feb 2015 12:54:11 +0100
Message-ID: <2435499.xPpCe4zRXk@wuerfel>
In-Reply-To: <1424086563-25570-1-git-send-email-daniel.thompson@linaro.org>
References: <1424086563-25570-1-git-send-email-daniel.thompson@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 16 February 2015 11:36:03 Daniel Thompson wrote:
> Currently if nfsd is configured as v2 only then the kernel fails to build.
> This is a regression introduced by 9cf514ccfacb("nfsd: implement pNFS
> operations"). It occurs because inline code from the xdr4.h header is
> now included from generic nfsd code (via pnfs.h).
> 
> This patch takes the simplest route and makes conditional the problematic
> inline function.
> 
> Note: I also tried extending the #ifdef CONFIG_NFSD_PNFS to cover almost
>       all of the pnfs.h header file. That works great too but feels more
>       invasive. However I can dust this off if that were preferable for
>       any reason.
> 

I believe this was fixed last Friday in the patch below. Do you still
see the problem on today's linux-next?

	Arnd

commit 3cd9ac34d50121470859bc3fe7eddbd2d498f374
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Feb 13 12:34:25 2015 -0500

    nfsd4: fix v3-less build
    
    Includes of pnfs.h in export.c and fcntl.c also bring in xdr4.h, which
    won't build without CONFIG_NFSD_V3, breaking non-V3 builds.  Ifdef-out
    most of pnfs.h in that case.
    
    Reported-by: Bas Peters <baspeters93@gmail.com>
    Reported-by: Jim Davis <jim.epost@gmail.com>
    Fixes: 9cf514ccfac "nfsd: implement pNFS operations"
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index fedb4d620a81..d4c4453674c6 100644
--- a/fs/nfsd/pnfs.h
+++ b/fs/nfsd/pnfs.h
@@ -1,6 +1,7 @@
 #ifndef _FS_NFSD_PNFS_H
 #define _FS_NFSD_PNFS_H 1
 
+#ifdef CONFIG_NFSD_V4
 #include <linux/exportfs.h>
 #include <linux/nfsd/export.h>
 
@@ -50,6 +51,7 @@ __be32 nfsd4_return_client_layouts(struct svc_rqst *rqstp,
 int nfsd4_set_deviceid(struct nfsd4_deviceid *id, const struct svc_fh *fhp,
                u32 device_generation);
 struct nfsd4_deviceid_map *nfsd4_find_devid_map(int idx);
+#endif /* CONFIG_NFSD_V4 */
 
 #ifdef CONFIG_NFSD_PNFS
 void nfsd4_setup_layout_type(struct svc_export *exp);
@@ -59,6 +61,9 @@ void nfsd4_return_all_file_layouts(struct nfs4_client *clp,
 int nfsd4_init_pnfs(void);
 void nfsd4_exit_pnfs(void);
 #else
+struct nfs4_client;
+struct nfs4_file;
+
 static inline void nfsd4_setup_layout_type(struct svc_export *exp)
 {
 }


