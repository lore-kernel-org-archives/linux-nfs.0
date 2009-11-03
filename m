From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 4/5] SQUASHME pnfsd: Move pnfsd code out of nfs4state.c/h
Date: Tue, 03 Nov 2009 08:30:04 +0200
Message-ID: <4AEFCDEC.6070407@panasas.com>
References: <4ADEC1EF.8040107@panasas.com> <1256112954-3462-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andy Adamson <andros@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:25085 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750998AbZKCGaC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2009 01:30:02 -0500
In-Reply-To: <1256112954-3462-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz,  I merged this patch into the pnfs tree.
Only it at this point, until the cleanup, which I like, gets acked.

I actually split it up for pnfsd-files and restricted the use
of CONFIG_PNFSD in the private header file only for functions
that are defined under the same config variable.

Benny

On Oct. 21, 2009, 10:15 +0200, Boaz Harrosh <bharrosh@panasas.com> wrote:
> * Introduce an fs/nfsd/nfsd_priv.h header that collects private
>   nfsd definitions/declarations. Specially all none exported
>   extern will move to that file.
> 
> * Include "nfsd_priv.h" in nfsd source files where needed.
> 
> * pnfs specific declarations are moved out of linux/nfsd/state.h and
>   into linux/nfsd/nfsd4_pnfs.h, though removing inclusion of
>   nfsd4_pnfs.h from state.h and all the #if defined(CONFIG_PNFSD)
> 
> * Finally moving remaining #if defined(CONFIG_PNFSD) code from
>   nfs4state.c into nfs4pnfsd.c
> 
> TODO: I know that lots of other code from include/linux/... nfsd
> headers could/should be moved into "nfsd_priv.h"
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfsd/export.c                |    1 +
>  fs/nfsd/nfs4callback.c          |    3 +
>  fs/nfsd/nfs4pnfsd.c             |   83 ++++++++++++++++++++++++++++++
>  fs/nfsd/nfs4proc.c              |    1 +
>  fs/nfsd/nfs4state.c             |  101 +------------------------------------
>  fs/nfsd/nfsd_priv.h             |  105 +++++++++++++++++++++++++++++++++++++++
>  include/linux/nfsd/nfsd4_pnfs.h |   61 ++++++++++++++++++----
>  include/linux/nfsd/pnfsd.h      |    8 ---
>  include/linux/nfsd/state.h      |   85 +-------------------------------
>  9 files changed, 246 insertions(+), 202 deletions(-)
>  create mode 100644 fs/nfsd/nfsd_priv.h
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 0eea1a6..f51c413 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -32,6 +32,7 @@
>  #include <linux/nfsd/nfsd.h>
>  #include <linux/nfsd/nfsfh.h>
>  #include <linux/nfsd/pnfsd.h>
> +#include "nfsd_priv.h"
>  #if defined(CONFIG_SPNFS)
>  #include <linux/nfsd4_spnfs.h>
>  #if defined(CONFIG_SPNFS_BLOCK)
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index b53194c..3347749 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -311,6 +311,9 @@ encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
>  }
>  
>  #if defined(CONFIG_PNFSD)
> +
> +#include "nfsd_priv.h"
> +
>  static void
>  encode_cb_layout(struct xdr_stream *xdr, struct nfs4_layoutrecall *clr,
>  		 struct nfs4_cb_compound_hdr *hdr)
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index d52a2e5..fdbc447 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -33,6 +33,7 @@
>  #include <linux/nfsd/xdr4.h>
>  #include <linux/exportfs.h>
>  #include <linux/nfsd/pnfsd.h>
> +#include "nfsd_priv.h"
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
>  
> @@ -1440,4 +1441,86 @@ int nfsd_device_notify_cb(struct super_block *sb,
>  		__func__, status, notify_num);
>  	return status;
>  }
> +
> +/* Create a layoutrecall structure for each client based on the
> + * original structure. */
> +int
> +create_layout_recall_list(struct list_head *todolist, unsigned *todo_len,
> +			  struct nfsd4_pnfs_cb_layout *cbl,
> +			  struct nfs4_file *lrfile)
> +{
> +	struct nfs4_client *clp;
> +	unsigned int i, len = 0;
> +	int status = 0;
> +
> +	dprintk("%s: -->\n", __func__);
> +
> +	/* If client given by fs, just do single client */
> +	if (cbl->cbl_seg.clientid) {
> +		clp = find_confirmed_client(
> +				(clientid_t *)&cbl->cbl_seg.clientid);
> +		if (!clp) {
> +			status = -ENOENT;
> +			dprintk("%s: clientid %llx not found\n", __func__,
> +				(unsigned long long)cbl->cbl_seg.clientid);
> +			goto out;
> +		}
> +
> +		status = lo_recall_per_client(clp, cbl, lrfile, todolist);
> +		if (!status)
> +			len++;
> +		goto out;
> +	}
> +
> +	/* Check all clients for layout matches */
> +	for (i = 0; i < CLIENT_HASH_SIZE; i++)
> +		list_for_each_entry(clp, &conf_str_hashtbl[i], cl_strhash) {
> +			status = lo_recall_per_client(clp, cbl, lrfile,
> +						      todolist);
> +			if (!status)
> +				len++;
> +			else if (status != -ENOENT)
> +				goto out;
> +		}
> +out:
> +	*todo_len = len;
> +	/* -ENOENT is a good thing don't return it if some recalls are needed */
> +	if ((status == -ENOENT) && len)
> +		status = 0;
> +	dprintk("%s: <-- list len %u status %d\n", __func__, len, status);
> +	return status;
> +}
> +
> +/* Create a list of clients to send device notifications. */
> +int
> +create_device_notify_list(struct list_head *todolist,
> +			  struct nfsd4_pnfs_cb_dev_list *ndl)
> +{
> +	int status = 0, i;
> +	struct nfs4_client *clp = NULL;
> +	struct nfs4_notify_device *cbnd;
> +
> +	nfs4_lock_state();
> +
> +	/* Create notify client list */
> +	for (i = 0; i < CLIENT_HASH_SIZE; i++)
> +		list_for_each_entry(clp, &conf_str_hashtbl[i], cl_strhash) {
> +			if (atomic_read(&clp->cl_deviceref) <= 0)
> +				continue;
> +			cbnd = kmalloc(sizeof(*cbnd), GFP_KERNEL);
> +			if (!cbnd) {
> +				status = -ENOMEM;
> +				goto out;
> +			}
> +			cbnd->nd_list = ndl;
> +			cbnd->nd_client = clp;
> +			list_add(&cbnd->nd_perclnt, todolist);
> +			atomic_inc(&clp->cl_count);
> +		}
> +
> +out:
> +	nfs4_unlock_state();
> +	return status;
> +}
> +
>  #endif /* CONFIG_PNFSD */
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 83acf8d..dd1da22 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -52,6 +52,7 @@
>  #include <linux/nfsd/pnfsd.h>
>  #include <linux/exportfs.h>
>  #include <linux/nfsd/nfs4layoutxdr.h>
> +#include "nfsd_priv.h"
>  #if defined(CONFIG_SPNFS)
>  #include <linux/nfsd4_spnfs.h>
>  #if defined(CONFIG_SPNFS_BLOCK)
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 7495df8..018292e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -59,6 +59,7 @@
>  #if defined(CONFIG_PNFSD)
>  #include <linux/nfsd/pnfsd.h>
>  #endif /* CONFIG_PNFSD */
> +#include "nfsd_priv.h"
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
>  
> @@ -275,20 +276,6 @@ unhash_delegation(struct nfs4_delegation *dp)
>  	nfs4_put_delegation(dp);
>  }
>  
> -/* 
> - * SETCLIENTID state 
> - */
> -
> -/* Hash tables for nfs4_clientid state */
> -#define CLIENT_HASH_BITS                 4
> -#define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
> -#define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
> -
> -#define clientid_hashval(id) \
> -	((id) & CLIENT_HASH_MASK)
> -#define clientstr_hashval(name) \
> -	(opaque_hashval((name), 8) & CLIENT_HASH_MASK)
> -
>  /*
>   * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
>   * used in reboot/reset lease grace period processing
> @@ -308,7 +295,7 @@ unhash_delegation(struct nfs4_delegation *dp)
>  static struct list_head reclaim_str_hashtbl[CLIENT_HASH_SIZE];
>  static int reclaim_str_hashtbl_size = 0;
>  static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
> -static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
> +struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
>  static struct list_head client_lru;
> @@ -4245,87 +4232,3 @@ nfs4_reset_lease(time_t leasetime)
>  	user_lease_time = leasetime;
>  }
>  
> -#if defined(CONFIG_PNFSD)
> -
> -/* Create a layoutrecall structure for each client based on the
> - * original structure. */
> -int
> -create_layout_recall_list(struct list_head *todolist, unsigned *todo_len,
> -			  struct nfsd4_pnfs_cb_layout *cbl,
> -			  struct nfs4_file *lrfile)
> -{
> -	struct nfs4_client *clp;
> -	unsigned int i, len = 0;
> -	int status = 0;
> -
> -	dprintk("%s: -->\n", __func__);
> -
> -	/* If client given by fs, just do single client */
> -	if (cbl->cbl_seg.clientid) {
> -		clp = find_confirmed_client(
> -				(clientid_t *)&cbl->cbl_seg.clientid);
> -		if (!clp) {
> -			status = -ENOENT;
> -			dprintk("%s: clientid %llx not found\n", __func__,
> -				(unsigned long long)cbl->cbl_seg.clientid);
> -			goto out;
> -		}
> -
> -		status = lo_recall_per_client(clp, cbl, lrfile, todolist);
> -		if (!status)
> -			len++;
> -		goto out;
> -	}
> -
> -	/* Check all clients for layout matches */
> -	for (i = 0; i < CLIENT_HASH_SIZE; i++)
> -		list_for_each_entry(clp, &conf_str_hashtbl[i], cl_strhash) {
> -			status = lo_recall_per_client(clp, cbl, lrfile,
> -						      todolist);
> -			if (!status)
> -				len++;
> -			else if (status != -ENOENT)
> -				goto out;
> -		}
> -out:
> -	*todo_len = len;
> -	/* -ENOENT is a good thing don't return it if some recalls are needed */
> -	if ((status == -ENOENT) && len)
> -		status = 0;
> -	dprintk("%s: <-- list len %u status %d\n", __func__, len, status);
> -	return status;
> -}
> -
> -/* Create a list of clients to send device notifications. */
> -int
> -create_device_notify_list(struct list_head *todolist,
> -			  struct nfsd4_pnfs_cb_dev_list *ndl)
> -{
> -	int status = 0, i;
> -	struct nfs4_client *clp = NULL;
> -	struct nfs4_notify_device *cbnd;
> -
> -	nfs4_lock_state();
> -
> -	/* Create notify client list */
> -	for (i = 0; i < CLIENT_HASH_SIZE; i++)
> -		list_for_each_entry(clp, &conf_str_hashtbl[i], cl_strhash) {
> -			if (atomic_read(&clp->cl_deviceref) <= 0)
> -				continue;
> -			cbnd = kmalloc(sizeof(*cbnd), GFP_KERNEL);
> -			if (!cbnd) {
> -				status = -ENOMEM;
> -				goto out;
> -			}
> -			cbnd->nd_list = ndl;
> -			cbnd->nd_client = clp;
> -			list_add(&cbnd->nd_perclnt, todolist);
> -			atomic_inc(&clp->cl_count);
> -		}
> -
> -out:
> -	nfs4_unlock_state();
> -	return status;
> -}
> -
> -#endif  /* CONFIG_PNFSD */
> diff --git a/fs/nfsd/nfsd_priv.h b/fs/nfsd/nfsd_priv.h
> new file mode 100644
> index 0000000..814fe8f
> --- /dev/null
> +++ b/fs/nfsd/nfsd_priv.h
> @@ -0,0 +1,105 @@
> +/*
> + *  nfsd_priv.h
> + *
> + *  nfsd declarations shared by a few .c files
> + *
> + *  Copyright (c) 2002 The Regents of the University of Michigan.
> + *  All rights reserved.
> + *
> + *  Redistribution and use in source and binary forms, with or without
> + *  modification, are permitted provided that the following conditions
> + *  are met:
> + *
> + *  1. Redistributions of source code must retain the above copyright
> + *     notice, this list of conditions and the following disclaimer.
> + *  2. Redistributions in binary form must reproduce the above copyright
> + *     notice, this list of conditions and the following disclaimer in the
> + *     documentation and/or other materials provided with the distribution.
> + *  3. Neither the name of the University nor the names of its
> + *     contributors may be used to endorse or promote products derived
> + *     from this software without specific prior written permission.
> + *
> + *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> + *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
> + *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> + *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
> + *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> + *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> + *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> + *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> + *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
> + *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> + *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + *
> + */
> +
> +#ifndef _NFSD_PRIV_H_
> +#define _NFSD_PRIV_H_
> +
> +/* 
> + * SETCLIENTID state 
> + */
> +
> +/* Hash tables for nfs4_clientid state */
> +#define CLIENT_HASH_BITS                 4
> +#define CLIENT_HASH_SIZE                (1 << CLIENT_HASH_BITS)
> +#define CLIENT_HASH_MASK                (CLIENT_HASH_SIZE - 1)
> +
> +#define clientid_hashval(id) \
> +	((id) & CLIENT_HASH_MASK)
> +#define clientstr_hashval(name) \
> +	(opaque_hashval((name), 8) & CLIENT_HASH_MASK)
> +
> +extern struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
> +
> +#if defined(CONFIG_PNFSD)
> +
> +#include <linux/nfsd/nfsd4_pnfs.h>
> +
> +#if defined(CONFIG_PNFSD_LOCAL_EXPORT)
> +extern struct sockaddr pnfsd_lexp_addr;
> +extern size_t pnfs_lexp_addr_len;
> +
> +void pnfsd_lexp_init(struct inode *inode);
> +#endif /* CONFIG_PNFSD_LOCAL_EXPORT */
> +
> +extern int nfsd4_init_pnfs_slabs(void);
> +extern void nfsd4_free_pnfs_slabs(void);
> +extern void release_pnfs_ds_dev_list(struct nfs4_stateid *stp);
> +extern void pnfs_expire_client(struct nfs4_client *clp);
> +
> +extern void release_pnfs_ds_dev_list(struct nfs4_stateid *stp);
> +extern void nfs4_pnfs_state_init(void);
> +extern int put_layoutrecall(struct nfs4_layoutrecall *);
> +extern void nomatching_layout(struct nfs4_layoutrecall *);
> +extern void *layoutrecall_done(struct nfs4_layoutrecall *);
> +extern int nfsd4_cb_layout(struct nfs4_layoutrecall *lp);
> +extern void nfsd4_free_slab(struct kmem_cache **slab);
> +extern struct nfs4_file * find_file(struct inode *ino);
> +extern struct nfs4_file * alloc_init_file(struct inode *ino, struct svc_fh *current_fh);
> +extern void put_nfs4_file(struct nfs4_file *fi);
> +extern void get_nfs4_file(struct nfs4_file *fi);
> +extern struct nfs4_client * find_confirmed_client(clientid_t *clid);
> +extern void nfs4_bug_on_unlocked_state(void);
> +extern void nfs4_ds_get_verifier(stateid_t *stateid,
> +		struct super_block *sb, u32 *p);
> +extern int nfs4_preprocess_pnfs_ds_stateid(struct svc_fh *, stateid_t *);
> +extern void nfs4_pnfs_state_shutdown(void);
> +extern int lo_recall_per_client(struct nfs4_client *clp,
> +		struct nfsd4_pnfs_cb_layout *cbl, struct nfs4_file *lrfile,
> +		struct list_head *todolist);
> +extern int create_layout_recall_list(struct list_head *todolist,
> +		unsigned *todo_len, struct nfsd4_pnfs_cb_layout *cbl,
> +		struct nfs4_file *lrfile);
> +extern int nfsd4_cb_notify_device(struct nfs4_notify_device *cbnd);
> +extern void pnfs_clear_device_notify(struct nfs4_client *clp);
> +extern int create_device_notify_list(struct list_head *todolist,
> +		struct nfsd4_pnfs_cb_dev_list *ndl);
> +#else /* CONFIG_PNFSD */
> +static inline void nfsd4_free_pnfs_slabs(void) {}
> +static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
> +static inline void release_pnfs_ds_dev_list(struct nfs4_stateid *stp) {}
> +static inline void pnfs_expire_client(struct nfs4_client *clp) {}
> +#endif /* CONFIG_PNFSD */
> +
> +#endif /* _NFSD_PRIV_H_ */
> diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
> index 410c459..70ca179 100644
> --- a/include/linux/nfsd/nfsd4_pnfs.h
> +++ b/include/linux/nfsd/nfsd4_pnfs.h
> @@ -36,10 +36,9 @@
>  #ifndef _LINUX_NFSD_NFSD4_PNFS_H
>  #define _LINUX_NFSD_NFSD4_PNFS_H
>  
> +#include <linux/nfsd/state.h>
>  #include <linux/nfs_xdr.h>
>  #include <linux/exportfs.h>
> -#include <linux/exp_xdr.h>
> -#include <linux/nfsd/nfsfh.h>
>  
>  typedef struct {
>  	uint64_t	pnfs_fsid;	/* fsid */
> @@ -83,6 +82,55 @@ struct nfsd4_layout_seg {
>  	u64	length;
>  };
>  
> +/* outstanding layout stateid */
> +struct nfs4_layout_state {
> +	struct list_head	ls_perfile;
> +	struct list_head	ls_layouts; /* list of nfs4_layouts */
> +	struct kref		ls_ref;
> +	struct nfs4_client	*ls_client;
> +	struct nfs4_file	*ls_file;
> +	stateid_t		ls_stateid;
> +};
> +
> +/* outstanding layout */
> +struct nfs4_layout {
> +	struct list_head		lo_perfile;	/* hash by f_id */
> +	struct list_head		lo_perclnt;	/* hash by clientid */
> +	struct list_head		lo_perstate;
> +	struct nfs4_file		*lo_file;	/* backpointer */
> +	struct nfs4_client		*lo_client;
> +	struct nfs4_layout_state	*lo_state;
> +	struct nfsd4_layout_seg 	lo_seg;
> +};
> +
> +struct nfsd4_pnfs_cb_layout {
> +	u32			cbl_recall_type;	/* request */
> +	struct nfsd4_layout_seg cbl_seg;		/* request */
> +	u32			cbl_layoutchanged;	/* request */
> +	stateid_t		cbl_sid;		/* request */
> +	struct nfs4_fsid	cbl_fsid;
> +	void			*cbl_cookie;		/* fs private */
> +};
> +
> +/* layoutrecall request (from exported filesystem) */
> +struct nfs4_layoutrecall {
> +	struct kref			clr_ref;
> +	struct nfsd4_pnfs_cb_layout	cb;	/* request */
> +	struct list_head		clr_perclnt; /* on cl_layoutrecalls */
> +	struct nfs4_client	       *clr_client;
> +	struct nfs4_file	       *clr_file;
> +	struct timespec			clr_time;	/* last activity */
> +	struct super_block 		*clr_sb; /* We might not have a file */
> +	struct nfs4_layoutrecall	*parent; /* The initiating recall */
> +};
> +
> +/* notify device request (from exported filesystem) */
> +struct nfs4_notify_device {
> +	struct nfsd4_pnfs_cb_dev_list  *nd_list;
> +	struct nfs4_client	       *nd_client;
> +	struct list_head	        nd_perclnt;
> +};
> +
>  /* Used by layout_get to encode layout (loc_body var in spec)
>   * Args:
>   * minlength - min number of accessible bytes given by layout
> @@ -168,15 +216,6 @@ struct nfsd4_pnfs_open {
>  	int			op_truncate;
>  };
>  
> -struct nfsd4_pnfs_cb_layout {
> -	u32			cbl_recall_type;	/* request */
> -	struct nfsd4_layout_seg cbl_seg;		/* request */
> -	u32			cbl_layoutchanged;	/* request */
> -	stateid_t		cbl_sid;		/* request */
> -	struct nfs4_fsid	cbl_fsid;
> -	void			*cbl_cookie;		/* fs private */
> -};
> -
>  struct nfsd4_pnfs_cb_dev_item {
>  	u32			cbd_notify_type;	/* request */
>  	u32			cbd_layout_type;	/* request */
> diff --git a/include/linux/nfsd/pnfsd.h b/include/linux/nfsd/pnfsd.h
> index d1d7395..6aa3a87 100644
> --- a/include/linux/nfsd/pnfsd.h
> +++ b/include/linux/nfsd/pnfsd.h
> @@ -96,14 +96,6 @@ int nfs4_pnfs_return_layout(struct super_block *, struct svc_fh *,
>  					struct nfsd4_pnfs_layoutreturn *);
>  void pnfs_set_device_notify(clientid_t *clid, unsigned int types);
>  void nfs4_pnfs_state_shutdown(void);
> -
> -#if defined(CONFIG_PNFSD_LOCAL_EXPORT)
> -extern struct sockaddr pnfsd_lexp_addr;
> -extern size_t pnfs_lexp_addr_len;
> -
> -void pnfsd_lexp_init(struct inode *inode);
> -#endif /* CONFIG_PNFSD_LOCAL_EXPORT */
> -
>  #endif /* CONFIG_PNFSD */
>  
>  #endif /* LINUX_NFSD_PNFSD_H */
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index ffd5a41..7367696 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -40,6 +40,7 @@
>  #include <linux/list.h>
>  #include <linux/kref.h>
>  #include <linux/sunrpc/clnt.h>
> +#include <linux/nfsd/nfsfh.h>
>  
>  typedef struct {
>  	u32             cl_boot;
> @@ -245,52 +246,6 @@ struct nfs4_fsid {
>  	u64	minor;
>  };
>  
> -#if defined(CONFIG_PNFSD)
> -
> -#include <linux/nfsd/nfsd4_pnfs.h>
> -
> -/* outstanding layout stateid */
> -struct nfs4_layout_state {
> -	struct list_head	ls_perfile;
> -	struct list_head	ls_layouts; /* list of nfs4_layouts */
> -	struct kref		ls_ref;
> -	struct nfs4_client	*ls_client;
> -	struct nfs4_file	*ls_file;
> -	stateid_t		ls_stateid;
> -};
> -
> -/* outstanding layout */
> -struct nfs4_layout {
> -	struct list_head		lo_perfile;	/* hash by f_id */
> -	struct list_head		lo_perclnt;	/* hash by clientid */
> -	struct list_head		lo_perstate;
> -	struct nfs4_file		*lo_file;	/* backpointer */
> -	struct nfs4_client		*lo_client;
> -	struct nfs4_layout_state	*lo_state;
> -	struct nfsd4_layout_seg 	lo_seg;
> -};
> -
> -/* layoutrecall request (from exported filesystem) */
> -struct nfs4_layoutrecall {
> -	struct kref			clr_ref;
> -	struct nfsd4_pnfs_cb_layout	cb;	/* request */
> -	struct list_head		clr_perclnt; /* on cl_layoutrecalls */
> -	struct nfs4_client	       *clr_client;
> -	struct nfs4_file	       *clr_file;
> -	struct timespec			clr_time;	/* last activity */
> -	struct super_block 		*clr_sb; /* We might not have a file */
> -	struct nfs4_layoutrecall	*parent; /* The initiating recall */
> -};
> -
> -/* notify device request (from exported filesystem) */
> -struct nfs4_notify_device {
> -	struct nfsd4_pnfs_cb_dev_list  *nd_list;
> -	struct nfs4_client	       *nd_client;
> -	struct list_head	        nd_perclnt;
> -};
> -
> -#endif /* CONFIG_PNFSD */
> -
>  /* struct nfs4_client_reset
>   * one per old client. Populates reset_str_hashtbl. Filled from conf_id_hashtbl
>   * upon lease reset, or from upcall to state_daemon (to read in state
> @@ -479,44 +434,6 @@ extern struct nfs4_delegation * find_delegation_stateid(struct inode *ino,
>  		stateid_t *stid);
>  extern __be32 nfs4_check_stateid(stateid_t *stateid);
>  extern void expire_client_lock(struct nfs4_client *clp);
> -#if defined(CONFIG_PNFSD)
> -extern void release_pnfs_ds_dev_list(struct nfs4_stateid *stp);
> -extern void nfs4_pnfs_state_init(void);
> -extern int put_layoutrecall(struct nfs4_layoutrecall *);
> -extern void nomatching_layout(struct nfs4_layoutrecall *);
> -extern void *layoutrecall_done(struct nfs4_layoutrecall *);
> -extern int nfsd4_cb_layout(struct nfs4_layoutrecall *lp);
> -extern void nfsd4_free_pnfs_slabs(void);
> -extern void nfsd4_free_slab(struct kmem_cache **slab);
> -extern int nfsd4_init_pnfs_slabs(void);
> -extern struct nfs4_file * find_file(struct inode *ino);
> -extern struct nfs4_file * alloc_init_file(struct inode *ino, struct svc_fh *current_fh);
> -extern void put_nfs4_file(struct nfs4_file *fi);
> -extern void get_nfs4_file(struct nfs4_file *fi);
> -extern struct nfs4_client * find_confirmed_client(clientid_t *clid);
> -extern void nfs4_bug_on_unlocked_state(void);
> -extern void release_pnfs_ds_dev_list(struct nfs4_stateid *stp);
> -extern void nfs4_ds_get_verifier(stateid_t *stateid,
> -		struct super_block *sb, u32 *p);
> -extern int nfs4_preprocess_pnfs_ds_stateid(struct svc_fh *, stateid_t *);
> -extern void nfs4_pnfs_state_shutdown(void);
> -extern int lo_recall_per_client(struct nfs4_client *clp,
> -		struct nfsd4_pnfs_cb_layout *cbl, struct nfs4_file *lrfile,
> -		struct list_head *todolist);
> -extern int create_layout_recall_list(struct list_head *todolist,
> -		unsigned *todo_len, struct nfsd4_pnfs_cb_layout *cbl,
> -		struct nfs4_file *lrfile);
> -extern int nfsd4_cb_notify_device(struct nfs4_notify_device *cbnd);
> -extern void pnfs_clear_device_notify(struct nfs4_client *clp);
> -extern int create_device_notify_list(struct list_head *todolist,
> -		struct nfsd4_pnfs_cb_dev_list *ndl);
> -extern void pnfs_expire_client(struct nfs4_client *clp);
> -#else /* CONFIG_PNFSD */
> -static inline void nfsd4_free_pnfs_slabs(void) {}
> -static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
> -static inline void release_pnfs_ds_dev_list(struct nfs4_stateid *stp) {}
> -static inline void pnfs_expire_client(struct nfs4_client *clp) {}
> -#endif /* CONFIG_PNFSD */
>  
>  static inline void
>  nfs4_put_stateowner(struct nfs4_stateowner *so)
