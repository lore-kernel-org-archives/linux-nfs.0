Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37908 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824Ab1HIU4j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Aug 2011 16:56:39 -0400
Received: by fxh19 with SMTP id 19so396360fxh.19
        for <linux-nfs@vger.kernel.org>; Tue, 09 Aug 2011 13:56:38 -0700 (PDT)
Message-ID: <4E419F02.4060607@tonian.com>
Date: Tue, 09 Aug 2011 23:56:34 +0300
From: Benny Halevy <benny@tonian.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SQUASHME: pnfsd: Fix compile breakage when !CONFIG_PNFSD
References: <4E419971.8040006@panasas.com>
In-Reply-To: <4E419971.8040006@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On 2011-08-09 23:32, Boaz Harrosh wrote:
> 
> The _roc patch broke the !CONFIG_PNFSD compilation. Fix that!
> 
> Benny sorry for the breakage.
> 
> BTW:
> 	[PATCH] pnfsd: rename pnfs_roc to pnfsd_roc
>   should be:
> 	[PATCH] SQUASHME: pnfsd: rename pnfs_roc to pnfsd_roc

It is in the 3.1 tree, not in pnfs-all-3.0 as the latter won't be squashed ever.

> 
> This patch is ontop of that one
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Merged. Thanks!

Benny

> ---
>  fs/nfsd/pnfsd.h |    1 -
>  fs/nfsd/state.h |    2 ++
>  2 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
> index 541376e..8e7dd71 100644
> --- a/fs/nfsd/pnfsd.h
> +++ b/fs/nfsd/pnfsd.h
> @@ -125,7 +125,6 @@ int nfs4_pnfs_cb_change_state(struct pnfs_get_state *);
>  void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
>  int put_layoutrecall(struct nfs4_layoutrecall *);
>  void nomatching_layout(struct nfs4_layoutrecall *);
> -void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
>  void *layoutrecall_done(struct nfs4_layoutrecall *);
>  void nfsd4_cb_layout(struct nfs4_layoutrecall *);
>  int nfsd_layout_recall_cb(struct super_block *, struct inode *,
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 9b7552c..cba9140 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -519,12 +519,14 @@ extern void nfs4_pnfs_state_init(void);
>  extern void nfs4_pnfs_state_shutdown(void);
>  extern void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
>  extern int nfs4_preprocess_pnfs_ds_stateid(struct svc_fh *, stateid_t *);
> +extern void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
>  #else /* CONFIG_PNFSD */
>  static inline void nfsd4_free_pnfs_slabs(void) {}
>  static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
>  static inline void pnfs_expire_client(struct nfs4_client *clp) {}
>  static inline void release_pnfs_ds_dev_list(struct nfs4_stateid *stp) {}
>  static inline void nfs4_pnfs_state_shutdown(void) {}
> +static inline void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp){}
>  #endif /* CONFIG_PNFSD */
>  
>  static inline void

