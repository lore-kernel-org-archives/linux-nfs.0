From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: Build error of latest Linux-pnfs 2.6.31
Date: Sun, 13 Sep 2009 12:31:22 +0300
Message-ID: <4AACBBEA.9040006@panasas.com>
References: <4AA8C597.8080809@panasas.com>	<1252574717-30074-1-git-send-email-bhalevy@panasas.com><1252583366.8722.121.camel@heimdal.trondhjem.org> <4AA8F229.2060404@panasas.com> <44328C067A5E0945856BF1EF5BE23689A29888@CORPUSMX50C.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, Sacks_Larry@emc.com
To: Sun_Peixing@emc.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:28589 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750784AbZIMJa0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Sep 2009 05:30:26 -0400
In-Reply-To: <44328C067A5E0945856BF1EF5BE23689A29888-1Zg0zMUlrbepizOVUD2tfjjd7nCn89gW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2009-09-12 01:29, Sun_Peixing@emc.com wrote:
> I got the following error from include/linux/stats.h.  It looks
> obviously that the line 481 and line 499 are duplicated.   If I remove
> line 481 from that file, then I got error in the end  
> "ERROR: "nfs4_reset_lease" [fs/nfsd/nfsd.ko] undefined!".   
> 
> Could you tell me how to fix that?    I downloaded the package using git
> by doing:      

It looks like CONFIG_PNFSD is configured as 'n' isn't it?
Anyway, does the following patch help?

>From 9a0a09a7cb3116dcb2f1610eb7579e06e80a60f4 Mon Sep 17 00:00:00 2001
From: Benny Halevy <bhalevy@panasas.com>
Date: Sun, 13 Sep 2009 12:26:31 +0300
Subject: [PATCH] SQUASHME: pnfsd: fix compiler warnings when CONFIG_PNFSD is not defined

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/state.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 9c0df5b..28e491d 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -478,14 +478,14 @@ extern struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 extern struct nfs4_delegation * find_delegation_stateid(struct inode *ino,
 		stateid_t *stid);
 extern __be32 nfs4_check_stateid(stateid_t *stateid);
+extern void expire_client_lock(struct nfs4_client *clp);
+#if defined(CONFIG_PNFSD)
 extern void release_pnfs_ds_dev_list(struct nfs4_stateid *stp);
 extern void nfs4_pnfs_state_init(void);
 extern int put_layoutrecall(struct nfs4_layoutrecall *);
 extern void nomatching_layout(struct nfs4_layoutrecall *);
 extern void *layoutrecall_done(struct nfs4_layoutrecall *);
-extern void expire_client_lock(struct nfs4_client *clp);
 extern int nfsd4_cb_layout(struct nfs4_layoutrecall *lp);
-#if defined(CONFIG_PNFSD)
 extern void nfsd4_free_pnfs_slabs(void);
 extern void nfsd4_free_slab(struct kmem_cache **slab);
 extern int nfsd4_init_pnfs_slabs(void);
@@ -515,8 +515,8 @@ extern void pnfs_expire_client(struct nfs4_client *clp);
 #else /* CONFIG_PNFSD */
 static inline void nfsd4_free_pnfs_slabs(void) {}
 static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
-static void release_pnfs_ds_dev_list(struct nfs4_stateid *stp) {}
-static void pnfs_expire_client(struct nfs4_client *clp) {}
+static inline void release_pnfs_ds_dev_list(struct nfs4_stateid *stp) {}
+static inline void pnfs_expire_client(struct nfs4_client *clp) {}
 #endif /* CONFIG_PNFSD */
 
 static inline void
-- 
1.6.4


> 
> git clone git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git
> 
> On 09/11/2009.  So I got the latest patch.
> 
> When Make started,  I got error from 
> 
> Thanks for help
> 
> Peixing
> 
>   CC [M]  fs/nfsd/nfs4proc.o
> In file included from fs/nfsd/nfs4proc.c:47:
> include/linux/nfsd/state.h:483: warning: struct nfs4_layoutrecall
> declared inside parameter list
> include/linux/nfsd/state.h:483: warning: its scope is only this
> definition or declaration, which is probably not what you want
> include/linux/nfsd/state.h:484: warning: struct nfs4_layoutrecall
> declared inside parameter list
> include/linux/nfsd/state.h:485: warning: struct nfs4_layoutrecall
> declared inside parameter list
> include/linux/nfsd/state.h:487: warning: struct nfs4_layoutrecall
> declared inside parameter list
> include/linux/nfsd/state.h:518: error: static declaration of
> release_pnfs_ds_dev_list follows non-static declaration
> include/linux/nfsd/state.h:481: error: previous declaration of
> release_pnfs_ds_dev_list was here
> make[2]: *** [fs/nfsd/nfs4proc.o] Error 1
