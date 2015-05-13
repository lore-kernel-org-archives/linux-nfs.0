Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45045 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555AbbEMSLo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 May 2015 14:11:44 -0400
Date: Wed, 13 May 2015 14:11:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-nfs@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: work around a gcc-5.1 warning
Message-ID: <20150513181143.GD2827@fieldses.org>
References: <2121336.tAfQfAWQ2u@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2121336.tAfQfAWQ2u@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 12, 2015 at 11:31:29PM +0200, Arnd Bergmann wrote:
> gcc-5.0 warns about a potential uninitialized variable use in nfsd:
> 
> fs/nfsd/nfs4state.c: In function 'nfsd4_process_open2':
> fs/nfsd/nfs4state.c:3781:3: warning: 'old_deny_bmap' may be used uninitialized in this function [-Wmaybe-uninitialized]
>    reset_union_bmap_deny(old_deny_bmap, stp);
>    ^
> fs/nfsd/nfs4state.c:3760:16: note: 'old_deny_bmap' was declared here
>   unsigned char old_deny_bmap;
>                 ^
> 
> This is a false positive, the code path that is warned about cannot
> actually be reached.
> 
> This adds an initialization for the variable to make the warning go
> away.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> This warning shows up in some ARM defconfig builds, which we try to
> build with no warnings to detect regressions.

OK, I guess.  How about simplifying slightly and doing it this way?--b

commit 3ae81ac291ec
Author: Arnd Bergmann <arnd@arndb.de>
Date:   Tue May 12 23:31:29 2015 +0200

    nfsd: work around a gcc-5.1 warning
    
    gcc-5.0 warns about a potential uninitialized variable use in nfsd:
    
    fs/nfsd/nfs4state.c: In function 'nfsd4_process_open2':
    fs/nfsd/nfs4state.c:3781:3: warning: 'old_deny_bmap' may be used uninitialized in this function [-Wmaybe-uninitialized]
       reset_union_bmap_deny(old_deny_bmap, stp);
       ^
    fs/nfsd/nfs4state.c:3760:16: note: 'old_deny_bmap' was declared here
      unsigned char old_deny_bmap;
                    ^
    
    This is a false positive, the code path that is warned about cannot
    actually be reached.
    
    This adds an initialization for the variable to make the warning go
    away.
    
    Signed-off-by: Arnd Bergmann <arnd@arndb.de>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 86f5c273c9ec..aef7c9bb6114 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3861,7 +3861,7 @@ static __be32
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
 {
 	__be32 status;
-	unsigned char old_deny_bmap;
+	unsigned char old_deny_bmap = stp->st_deny_bmap;
 
 	if (!test_access(open->op_share_access, stp))
 		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
@@ -3870,7 +3870,6 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 	spin_lock(&fp->fi_lock);
 	status = nfs4_file_check_deny(fp, open->op_share_deny);
 	if (status == nfs_ok) {
-		old_deny_bmap = stp->st_deny_bmap;
 		set_deny(open->op_share_deny, stp);
 		fp->fi_share_deny |=
 				(open->op_share_deny & NFS4_SHARE_DENY_BOTH);
