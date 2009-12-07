From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH v2 0/35] Initial pnfsd file layout support
Date: Mon, 07 Dec 2009 11:54:53 +0200
Message-ID: <4B1CD0ED.9020305@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36331 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933573AbZLGJx4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:53:56 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patchset is also available here:
git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfsd-files-next

Benny

On Dec. 07, 2009, 11:26 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Bruce,
> 
> The following patches implement initial pnfsd server support for
> the files layout and the dlm-based file systems, including GETDEVICELIST,
> GETDEVICEINFO, and LAYOUTGET.
> LAYOUTCOMMIT and LAYOUTRETURN generic implementation provides the
> complete implementation that was tested by Andy in the Austin Fall
> 2010 Bakeathon.
> 
> The patchset is based onto your nfsd-next branch at
> d1ecbbf Merge branch 'for-2.6.33-incoming' into HEAD
> post Boaz' headers cleanup patchset.
> 
> v2 includes the fixes posted here:
> http://linux-nfs.org/pipermail/pnfs/2009-December/009607.html
> as well as some cosmetic cleanups and cleanup of CONFIG_PNFSD usage
> on the lines Christoph suggested aimed at minimizing its use
> See diff -w at the bottom of this email for details
> 
> [PATCH v2 01/35] pnfsd: Define CONFIG_PNFSD
> [PATCH v2 02/35] pnfsd: define NFSDDBG_PNFS
> [PATCH v2 03/35] pnfsd, pnfs: protocol level pnfs constants
> [PATCH v2 04/35] pnfsd: return pnfs flags on exchange_id
> [PATCH v2 05/35] pnfsd: don't set up back channel on create_session for ds
> [PATCH v2 06/35] pnfsd: introduce pnfsd header files
> [PATCH v2 07/35] pnfsd: define pnfs_export_operations
> [PATCH v2 08/35] pnfsd: add pnfs export option
> [PATCH v2 09/35] pnfsd: layout verify
> [PATCH v2 10/35] pnfsd: introduce exp_xdr.h
> [PATCH v2 11/35] pnfsd: get device list/info
> [PATCH v2 12/35] pnfsd: filelayout: get device list/info
> [PATCH v2 13/35] pnfsd: layout get
> [PATCH v2 14/35] pnfsd: filelayout: layout encoding
> [PATCH v2 15/35] pnfsd: Helper functions for layout stateid processing.
> [PATCH v2 16/35] pnfsd: helper function for stateid checking
> [PATCH v2 17/35] pnfsd: process the layout stateid
> [PATCH v2 18/35] pnfsd: add helper functions for identifying DS stateids.
> [PATCH v2 19/35] pnfsd: accept all ds stateids
> [PATCH v2 20/35] pnfsd: LAYOUTGET layout stateid processing
> [PATCH v2 21/35] pnfsd: destroy layout on expire_client
> [PATCH v2 22/35] pnfsd: support layout_type attribute
> [PATCH v2 23/35] pnfsd: per block device dlm data server list cache
> [PATCH v2 24/35] pnfsd: new nfsd filesystem file: pnfs_dlm_device
> [PATCH v2 25/35] pnfsd: nfsd4_pnfs_dlm_getdeviter
> [PATCH v2 26/35] pnfsd: nfsd4_pnfs_dlm_getdevinfo
> [PATCH v2 27/35] pnfsd: nfsd4_pnfs_dlm_layoutget
> [PATCH v2 28/35] pnfsd: add dlm file layout layout-type
> [PATCH v2 29/35] pnfsd: dlm pnfs_export_operations
> [PATCH v2 30/35] pnfsd: gfs2: use generic file layout pnfs operations vector
> [PATCH v2 31/35] posix_acl: resolve compile dependency in posix_acl.h
> [PATCH v2 32/35] nfs: resolve compile dependency in nfs_xdr.h
> [PATCH v2 33/35] pnfsd: layout commit
> [PATCH v2 34/35] pnfsd: layout return
> [PATCH v2 35/35] pnfsd: layoutreturn stateid processing
> 
> diff from v1 + posted fixes:
> 
> git diff --stat -p -M -w origin/pnfsd-files pnfsd-files
>  fs/exportfs/Makefile            |    4 ++--
>  fs/exportfs/nfs4filelayoutxdr.c |    6 ------
>  fs/gfs2/export.c                |    1 +
>  fs/nfsd/nfs4pnfsd.c             |   17 +----------------
>  fs/nfsd/nfs4pnfsdlm.c           |    4 ++--
>  fs/nfsd/nfs4state.c             |   17 +++++++++++++----
>  fs/nfsd/nfsfh.c                 |    6 +-----
>  fs/nfsd/pnfsd.h                 |    4 ----
>  include/linux/nfs4.h            |    2 --
>  include/linux/nfsd/nfsd.h       |    8 --------
>  include/linux/nfsd/nfsd4_pnfs.h |   11 +++++++++++
>  include/linux/nfsd/state.h      |    2 +-
>  include/linux/nfsd/xdr4.h       |    8 --------
>  13 files changed, 32 insertions(+), 58 deletions(-)
> 
> diff --git a/fs/exportfs/Makefile b/fs/exportfs/Makefile
> index f820d80..658207d 100644
> --- a/fs/exportfs/Makefile
> +++ b/fs/exportfs/Makefile
> @@ -3,5 +3,5 @@
>  
>  obj-$(CONFIG_EXPORTFS) += exportfs.o
>  
> -exportfs-objs := expfs.o
> -exportfs-objs += nfs4filelayoutxdr.o
> +exportfs-y				:= expfs.o
> +exportfs-$(CONFIG_EXPORTFS_FILE_LAYOUT)	+= nfs4filelayoutxdr.o
> diff --git a/fs/exportfs/nfs4filelayoutxdr.c b/fs/exportfs/nfs4filelayoutxdr.c
> index f076908..782b673 100644
> --- a/fs/exportfs/nfs4filelayoutxdr.c
> +++ b/fs/exportfs/nfs4filelayoutxdr.c
> @@ -1,6 +1,4 @@
>  /*
> -*  linux/fs/nfsd/nfs4filelayout_xdr.c
> -*
>  *  Copyright (c) 2006 The Regents of the University of Michigan.
>  *  All rights reserved.
>  *
> @@ -33,8 +31,6 @@
>  *
>  *
>  */
> -#if defined(CONFIG_EXPORTFS_FILE_LAYOUT)
> -
>  #include <linux/module.h>
>  #include <linux/sunrpc/svc.h>
>  #include <linux/nfsd/nfsd.h>
> @@ -226,5 +222,3 @@ out:
>  	return error;
>  }
>  EXPORT_SYMBOL(filelayout_encode_layout);
> -
> -#endif /* CONFIG_EXPORTFS_FILE_LAYOUT */
> diff --git a/fs/gfs2/export.c b/fs/gfs2/export.c
> index 9cea712..d15876e 100644
> --- a/fs/gfs2/export.c
> +++ b/fs/gfs2/export.c
> @@ -254,3 +254,4 @@ const struct export_operations gfs2_export_ops = {
>  	.get_name = gfs2_get_name,
>  	.get_parent = gfs2_get_parent,
>  };
> +
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index 4849463..aa7abad 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -21,8 +21,6 @@
>   *
>   *****************************************************************************/
>  
> -#if defined(CONFIG_PNFSD)
> -
>  #include <linux/param.h>
>  #include <linux/slab.h>
>  #include <linux/sunrpc/svc.h>
> @@ -66,18 +64,6 @@ nfsd4_init_pnfs_slabs(void)
>  	return 0;
>  }
>  
> -static struct nfs4_file *
> -find_alloc_file(struct inode *ino, struct svc_fh *current_fh)
> -{
> -	struct nfs4_file *fp;
> -
> -	fp = find_file(ino);
> -	if (fp)
> -		return fp;
> -
> -	return alloc_init_file(ino, current_fh);
> -}
> -
>  static struct nfs4_layout_state *
>  alloc_init_layout_state(struct nfs4_client *clp, struct nfs4_file *fp,
>  			stateid_t *stateid)
> @@ -717,8 +703,8 @@ int nfs4_pnfs_return_layout(struct super_block *sb, struct svc_fh *current_fh,
>  	if (!clp)
>  		goto out;
>  
> -	fp = find_file(ino);
>  	if (lrp->args.lr_return_type == RETURN_FILE) {
> +		fp = find_file(ino);
>  		if (!fp) {
>  			printk(KERN_ERR "%s: RETURN_FILE: no nfs4_file for "
>  				"ino %p:%lu\n",
> @@ -778,4 +764,3 @@ void pnfs_expire_client(struct nfs4_client *clp)
>  	}
>  	spin_unlock(&layout_lock);
>  }
> -#endif /* CONFIG_PNFSD */
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index b3027fe..ed2e940 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -40,7 +40,7 @@ struct dlm_device_entry {
>  	struct list_head	dlm_dev_list;
>  	char			disk_name[DISK_NAME_LEN];
>  	int			num_ds;
> -	char			ds_list[NFSD_PNFS_DS_LIST_MAX];
> +	char			ds_list[NFSD_DLM_DS_LIST_MAX];
>  };
>  
>  static struct dlm_device_entry *
> @@ -108,7 +108,7 @@ nfsd4_set_pnfs_dlm_device(char *pnfs_dlm_device, int len)
>  	/* data server list */
>  	/* FIXME: need to check for comma separated valid ip format */
>  	len = strcspn(bufp, ":");
> -	if (len > NFSD_PNFS_DS_LIST_MAX)
> +	if (len > NFSD_DLM_DS_LIST_MAX)
>  		goto out_free;
>  	memcpy(new->ds_list, bufp, len);
>  
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d99caae..bc359ea 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1726,7 +1726,7 @@ out:
>  }
>  
>  /* OPEN Share state helper functions */
> -inline struct nfs4_file *
> +static inline struct nfs4_file *
>  alloc_init_file(struct inode *ino, struct svc_fh *current_fh)
>  {
>  	struct nfs4_file *fp;
> @@ -1941,6 +1941,18 @@ find_file(struct inode *ino)
>  	return NULL;
>  }
>  
> +struct nfs4_file *
> +find_alloc_file(struct inode *ino, struct svc_fh *current_fh)
> +{
> +	struct nfs4_file *fp;
> +
> +	fp = find_file(ino);
> +	if (fp)
> +		return fp;
> +
> +	return alloc_init_file(ino, current_fh);
> +}
> +
>  static inline int access_valid(u32 x, u32 minorversion)
>  {
>  	if ((x & NFS4_SHARE_ACCESS_MASK) < NFS4_SHARE_ACCESS_READ)
> @@ -2863,10 +2875,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
>  	if (grace_disallows_io(ino))
>  		return nfserr_grace;
>  
> -#if defined(CONFIG_PNFSD)
>  	if (pnfs_fh_is_ds(&current_fh->fh_handle))
>  		return 0;
> -#endif /* CONFIG_PNFSD */
>  
>  	if (nfsd4_has_session(cstate))
>  		flags |= HAS_SESSION;
> @@ -4183,4 +4193,3 @@ nfs4_reset_lease(time_t leasetime)
>  {
>  	user_lease_time = leasetime;
>  }
> -
> diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> index 7d624f4..8300b2f 100644
> --- a/fs/nfsd/nfsfh.c
> +++ b/fs/nfsd/nfsfh.c
> @@ -22,12 +22,8 @@
>  #include <linux/sunrpc/svc.h>
>  #include <linux/sunrpc/svcauth_gss.h>
>  #include <linux/nfsd/nfsd.h>
> -#include "auth.h"
> -
> -#if defined(CONFIG_PNFSD)
> -#include <linux/nfsd/state.h>
>  #include <linux/nfsd/nfsd4_pnfs.h>
> -#endif /* CONFIG_PNFSD */
> +#include "auth.h"
>  
>  #define NFSDDBG_FACILITY		NFSDDBG_FH
>  
> diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
> index 7d255f5..c3354e8 100644
> --- a/fs/nfsd/pnfsd.h
> +++ b/fs/nfsd/pnfsd.h
> @@ -34,8 +34,6 @@
>  #ifndef LINUX_NFSD_PNFSD_H
>  #define LINUX_NFSD_PNFSD_H
>  
> -#if defined(CONFIG_PNFSD)
> -
>  #include <linux/nfsd/state.h>
>  #include <linux/nfsd/nfsd4_pnfs.h>
>  
> @@ -64,6 +62,4 @@ int nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *)
>  int nfs4_pnfs_return_layout(struct super_block *, struct svc_fh *,
>  					struct nfsd4_pnfs_layoutreturn *);
>  
> -#endif /* CONFIG_PNFSD */
> -
>  #endif /* LINUX_NFSD_PNFSD_H */
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index 3c251f4..a899cff 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -548,7 +548,6 @@ enum state_protect_how4 {
>  	SP4_SSV		= 2
>  };
>  
> -#if defined(CONFIG_PNFS) || defined(CONFIG_PNFSD)
>  enum pnfs_layouttype {
>  	LAYOUT_NFSV4_FILES  = 1,
>  	LAYOUT_OSD2_OBJECTS = 2,
> @@ -591,7 +590,6 @@ enum filelayout_hint_care4 {
>  	NFLH4_CARE_STRIPE_UNIT_SIZE	= 0x00000040,
>  	NFLH4_CARE_STRIPE_COUNT		= 0x00000080
>  };
> -#endif /* defined(CONFIG_PNFS) || defined(CONFIG_PNFSD) */
>  
>  #endif
>  #endif
> diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
> index 6eb5c6e..c61e220 100644
> --- a/include/linux/nfsd/nfsd.h
> +++ b/include/linux/nfsd/nfsd.h
> @@ -181,14 +181,6 @@ static inline void nfs4_reset_lease(time_t leasetime) { }
>  static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
>  #endif
>  
> -#ifdef CONFIG_PNFSD
> -/* Length of comma separated pnfs data server IPv4 addresses. Enough room for
> - * 32 addresses.
> - */
> -#define NFSD_PNFS_DS_LIST_MAX   512
> -
> -#endif
> -
>  /*
>   * lockd binding
>   */
> diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
> index e96c2d4..dbed31a 100644
> --- a/include/linux/nfsd/nfsd4_pnfs.h
> +++ b/include/linux/nfsd/nfsd4_pnfs.h
> @@ -169,6 +169,8 @@ struct pnfs_export_operations {
>  	int (*can_merge_layouts) (u32 layout_type);
>  };
>  
> +#if defined(CONFIG_PNFSD)
> +
>  /*
>   * fh_fsid_type is overloaded to indicate whether a filehandle was one supplied
>   * to a DS by LAYOUTGET.  nfs4_preprocess_stateid_op() uses this to decide how
> @@ -196,4 +198,13 @@ static inline int pnfs_fh_fsid_type(struct knfsd_fh *fh)
>  	return fsid_type;
>  }
>  
> +#else  /* CONFIG_PNFSD */
> +
> +static inline int pnfs_fh_is_ds(struct knfsd_fh *fh)
> +{
> +	return 0;
> +}
> +
> +#endif /* CONFIG_PNFSD */
> +
>  #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 8cf7e51..16ee98c 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -415,7 +415,7 @@ extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
>  extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
>  extern void nfsd4_free_slab(struct kmem_cache **);
>  extern struct nfs4_file *find_file(struct inode *);
> -extern struct nfs4_file *alloc_init_file(struct inode *, struct svc_fh *);
> +extern struct nfs4_file *find_alloc_file(struct inode *, struct svc_fh *);
>  extern void put_nfs4_file(struct nfs4_file *);
>  extern void get_nfs4_file(struct nfs4_file *);
>  extern struct nfs4_client *find_confirmed_client(clientid_t *);
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 8e36ac3..831151f 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -515,14 +515,6 @@ struct nfsd4_compoundres {
>  	struct nfsd4_compound_state	cstate;
>  };
>  
> -static inline __be32 *
> -nfsd4_xdr_reserve_space(struct nfsd4_compoundres *resp, size_t nbytes)
> -{
> -	__be32 *p = resp->p;
> -	BUG_ON(p + XDR_QUADLEN(nbytes) > resp->end);
> -	return p;
> -}
> -
>  static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
>  {
>  	struct nfsd4_compoundargs *args = resp->rqstp->rq_argp;
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
