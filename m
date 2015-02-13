Return-Path: linux-kernel-owner@vger.kernel.org
Date: Fri, 13 Feb 2015 12:33:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Bas Peters <baspeters93@gmail.com>, hch@lst.de, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
        jim.epost@gmail.com
Subject: Re: [PATCH] fs: nfsd:xdr4.h: add missing conditional group
 CONFIG_NFSD_V3
Message-ID: <20150213173348.GD6808@fieldses.org>
References: <1423778953-28307-1-git-send-email-baspeters93@gmail.com>
 <20150212230201.GB17998@roeck-us.net>
 <20150213145121.GC6808@fieldses.org>
 <54DE2BE9.5030706@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54DE2BE9.5030706@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 13, 2015 at 08:52:57AM -0800, Guenter Roeck wrote:
> On 02/13/2015 06:51 AM, J. Bruce Fields wrote:
> >On Thu, Feb 12, 2015 at 03:02:01PM -0800, Guenter Roeck wrote:
> >>On Thu, Feb 12, 2015 at 11:09:13PM +0100, Bas Peters wrote:
> >>>This patch adds a missing conditional group that has been causing build
> >>>breakages due to undefined struct members being referenced when
> >>>CONFIG_NFSD_v3 is not set.
> >>>
> >>>This patch applies against linux-next.
> >>>
> >>>Signed-off-by: Bas Peters <baspeters93@gmail.com>
> >>>---
> >>>  fs/nfsd/xdr4.h | 6 ++++--
> >>>  1 file changed, 4 insertions(+), 2 deletions(-)
> >>>
> >>>diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> >>>index 0bda93e..5d1597f 100644
> >>>--- a/fs/nfsd/xdr4.h
> >>>+++ b/fs/nfsd/xdr4.h
> >>>@@ -630,9 +630,11 @@ void warn_on_nonidempotent_op(struct nfsd4_op *op);
> >>>  static inline void
> >>>  set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
> >>>  {
> >>>+	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
> >>>+
> >>>+#ifdef CONFIG_NFSD_V3
> >>>  	BUG_ON(!fhp->fh_pre_saved);
> >>>  	cinfo->atomic = fhp->fh_post_saved;
> >>>-	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
> >>>
> >>>  	cinfo->before_change = fhp->fh_pre_change;
> >>>  	cinfo->after_change = fhp->fh_post_change;
> >>>@@ -640,7 +642,7 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
> >>>  	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
> >>>  	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
> >>>  	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
> >>>-
> >>>+#endif
> >>>  }
> >>
> >>You'll want to include and example of the build failure in the description,
> >>bisect results after the '---' line, and a Fixes: line pointing to the patch
> >>breaking the build.
> >>
> >>In this case, I am not sure if the above really fixes the problem,
> >>or if it just hides it behind an #ifdef. To determine that, it will
> >>probably be necessary to know which patch actually caused the problem.
> >>This even more true since the code in question was not changed since
> >>around 2010, so making it conditional looks really suspicious.
> >>
> >>In the curent case, I suspect that the problem may have been introduced by
> >>commit 9cf514ccfac ("nfsd: implement pNFS operations"). That is just a guess,
> >>though; I didn't run bisect myself. The key really is to figure out why the
> >>code now fails to build, and not just to comment out the code that is causing
> >>the failure.
> >
> >Yeah, when Jim Davis reported this I took a quick look at the history,
> >didn't see an obvious explanation, and figured well maybe this is just
> >the first time anyone's hit that particular config in a while.  Sounds
> >like this actually is a recent regression?
> >
> 
> It was intruduced by 9cf514ccfac. Problem is that xdr4.h is only supposed to
> be used and included by NFSv4 code but is now included even if NFSv3 and/or
> NFSv4 are not configured. The variables in fhp accessed above do not exist
> unless NFSv3 is configured.
> 
> The patch here is therefore really just a kludge, though I don't really know
> an easy real fix.
> 
> If you ask me, I'd say that 9cf514ccfac was rushed into mainline a bit.
> It showed up in next on Feb 10 and pushed into mainline just a day or two
> later.

Blame me for that decision.

> Result is that every build with NFS configured but not NSFv3 is
> now broken.

Fortunately a v2-only server would be pretty unusual these days.

I don't know, maybe this?

--b.

commit 535c381153631af3bc708a97e267a2a6a86ee030
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Feb 13 12:27:39 2015 -0500

    nfsd4: fix v3-less build
    
    Includes of pnfs.h in export.c and fcntl.c also bring in xdr4.h, which
    won't build without CONFIG_NFSD_V3, breaking non-V3 builds.  Ifdef-out
    most of pnfs.h in that case.
    
    Reported-by: Bas Peters <baspeters93@gmail.com>
    Reported-by: Jim Davis <jim.epost@gmail.com>
    Fixes: 9cf514ccfac "nfsd: implement pNFS operations"
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/pnfs.h b/fs/nfsd/pnfs.h
index fedb4d6..d4c4453 100644
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
