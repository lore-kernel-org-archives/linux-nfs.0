From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 08/85] nfs41: client xdr definitions
Date: Mon, 17 Nov 2008 15:31:13 +0200
Message-ID: <49217221.8030103@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348352-7271-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:11895 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbYKQNgb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:36:31 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1180389qwe.37
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2008 05:36:30 -0800 (PST)
In-Reply-To: <1226348352-7271-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:19 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Define stubs for sequence args and res data structures and embed
> them in all other nfs4 and nfs41 xdr types.  They are needed for
> sending any op in a nfs41 compound rpc.
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/nfs_xdr.h |  118 +++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 118 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index c1c31ac..a8a0953 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -113,6 +113,43 @@ struct nfs4_change_info {
>  };
>  
>  struct nfs_seqid;
> +
> +/* Opaque session ID */
> +struct sessionid4 {
> +	char	data[NFS4_MAX_SESSIONID_LEN];
> +};

review 11-14: this is redundant.

> +
> +struct nfs41_sequence_args {
> +	/* stub */
> +};
> +
> +#define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
> +#define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING	0x00000002
> +#define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED	0x00000004
> +#define SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED	0x00000008
> +#define SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED	0x00000010
> +#define SEQ4_STATUS_ADMIN_STATE_REVOKED		0x00000020
> +#define SEQ4_STATUS_RECALLABLE_STATE_REVOKED	0x00000040
> +#define SEQ4_STATUS_LEASE_MOVED			0x00000080
> +#define SEQ4_STATUS_RESTART_RECLAIM_NEEDED	0x00000100
> +
> +struct nfs41_sequence_res {
> +	/* stub */
> +};
> +
> +#if defined(CONFIG_NFS_V4_1)

review 11-14: no need for #ifdef

> +
> +struct nfs4_get_lease_time_args {
> +	struct nfs41_sequence_args	la_seq_args;
> +};
> +
> +struct nfs4_get_lease_time_res {
> +	struct nfs_fsinfo	       *lr_fsinfo;
> +	struct nfs41_sequence_res	lr_seq_res;
> +};
> +
> +#endif	/* CONFIG_NFS_V4_1 */
> +
>  /*
>   * Arguments to the open call.
>   */
> @@ -132,6 +169,7 @@ struct nfs_openargs {
>  	const struct nfs_server *server;	 /* Needed for ID mapping */
>  	const u32 *		bitmask;
>  	__u32			claim;
> +	struct nfs41_sequence_args	seq_args;

review 11-14: discussed embedding seq_args/res vs. having a wrapper
structure a-la

struct nfs_rpc_args {
	void *op_args;
	struct nfs41_sequence_args	seq_args;
};

struct nfs_rpc_res {
	void *op_res;
	struct nfs41_sequence_res	seq_res;
};

Trond prefers the former (keep current).

>  };
>  
>  struct nfs_openres {
> @@ -148,6 +186,7 @@ struct nfs_openres {
>  	__u32			do_recall;
>  	__u64			maxsize;
>  	__u32			attrset[NFS4_BITMAP_SIZE];
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  /*
> @@ -173,6 +212,7 @@ struct nfs_closeargs {
>  	struct nfs_seqid *	seqid;
>  	int			open_flags;
>  	const u32 *		bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs_closeres {
> @@ -180,6 +220,7 @@ struct nfs_closeres {
>  	struct nfs_fattr *	fattr;
>  	struct nfs_seqid *	seqid;
>  	const struct nfs_server *server;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  /*
>   *  * Arguments to the lock,lockt, and locku call.
> @@ -200,12 +241,14 @@ struct nfs_lock_args {
>  	unsigned char		block : 1;
>  	unsigned char		reclaim : 1;
>  	unsigned char		new_lock_owner : 1;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs_lock_res {
>  	nfs4_stateid		stateid;
>  	struct nfs_seqid *	lock_seqid;
>  	struct nfs_seqid *	open_seqid;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs_locku_args {
> @@ -213,32 +256,38 @@ struct nfs_locku_args {
>  	struct file_lock *	fl;
>  	struct nfs_seqid *	seqid;
>  	nfs4_stateid *		stateid;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs_locku_res {
>  	nfs4_stateid		stateid;
>  	struct nfs_seqid *	seqid;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs_lockt_args {
>  	struct nfs_fh *		fh;
>  	struct file_lock *	fl;
>  	struct nfs_lowner	lock_owner;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs_lockt_res {
>  	struct file_lock *	denied; /* LOCK, LOCKT failed */
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_delegreturnargs {
>  	const struct nfs_fh *fhandle;
>  	const nfs4_stateid *stateid;
>  	const u32 * bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_delegreturnres {
>  	struct nfs_fattr * fattr;
>  	const struct nfs_server *server;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  /*
> @@ -251,12 +300,14 @@ struct nfs_readargs {
>  	__u32			count;
>  	unsigned int		pgbase;
>  	struct page **		pages;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs_readres {
>  	struct nfs_fattr *	fattr;
>  	__u32			count;
>  	int                     eof;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  /*
> @@ -271,6 +322,7 @@ struct nfs_writeargs {
>  	unsigned int		pgbase;
>  	struct page **		pages;
>  	const u32 *		bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs_writeverf {
> @@ -283,6 +335,7 @@ struct nfs_writeres {
>  	struct nfs_writeverf *	verf;
>  	__u32			count;
>  	const struct nfs_server *server;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  /*
> @@ -292,12 +345,14 @@ struct nfs_removeargs {
>  	const struct nfs_fh	*fh;
>  	struct qstr		name;
>  	const u32 *		bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs_removeres {
>  	const struct nfs_server *server;
>  	struct nfs4_change_info	cinfo;
>  	struct nfs_fattr	dir_attr;
> +	struct nfs41_sequence_res 	seq_res;
>  };
>  
>  /*
> @@ -350,6 +405,7 @@ struct nfs_setattrargs {
>  	struct iattr *                  iap;
>  	const struct nfs_server *	server; /* Needed for name mapping */
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args 	seq_args;
>  };
>  
>  struct nfs_setaclargs {
> @@ -357,6 +413,11 @@ struct nfs_setaclargs {
>  	size_t				acl_len;
>  	unsigned int			acl_pgbase;
>  	struct page **			acl_pages;
> +	struct nfs41_sequence_args	seq_args;
> +};
> +
> +struct nfs_setaclres {
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs_getaclargs {
> @@ -364,11 +425,18 @@ struct nfs_getaclargs {
>  	size_t				acl_len;
>  	unsigned int			acl_pgbase;
>  	struct page **			acl_pages;
> +	struct nfs41_sequence_args 	seq_args;
> +};
> +
> +struct nfs_getaclres {
> +	size_t				*acl_len;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs_setattrres {
>  	struct nfs_fattr *              fattr;
>  	const struct nfs_server *	server;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs_linkargs {
> @@ -548,6 +616,7 @@ struct nfs4_accessargs {
>  	const struct nfs_fh *		fh;
>  	const u32 *			bitmask;
>  	u32				access;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_accessres {
> @@ -555,6 +624,7 @@ struct nfs4_accessres {
>  	struct nfs_fattr *		fattr;
>  	u32				supported;
>  	u32				access;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_create_arg {
> @@ -574,6 +644,7 @@ struct nfs4_create_arg {
>  	const struct iattr *		attrs;
>  	const struct nfs_fh *		dir_fh;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args 	seq_args;
>  };
>  
>  struct nfs4_create_res {
> @@ -582,21 +653,30 @@ struct nfs4_create_res {
>  	struct nfs_fattr *		fattr;
>  	struct nfs4_change_info		dir_cinfo;
>  	struct nfs_fattr *		dir_fattr;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_fsinfo_arg {
>  	const struct nfs_fh *		fh;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
> +};
> +
> +struct nfs4_fsinfo_res {
> +	struct nfs_fsinfo	       *fsinfo;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_getattr_arg {
>  	const struct nfs_fh *		fh;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_getattr_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_link_arg {
> @@ -604,6 +684,7 @@ struct nfs4_link_arg {
>  	const struct nfs_fh *		dir_fh;
>  	const struct qstr *		name;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args 	seq_args;
>  };
>  
>  struct nfs4_link_res {
> @@ -611,6 +692,7 @@ struct nfs4_link_res {
>  	struct nfs_fattr *		fattr;
>  	struct nfs4_change_info		cinfo;
>  	struct nfs_fattr *		dir_attr;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  
> @@ -618,21 +700,30 @@ struct nfs4_lookup_arg {
>  	const struct nfs_fh *		dir_fh;
>  	const struct qstr *		name;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_lookup_res {
>  	const struct nfs_server *	server;
>  	struct nfs_fattr *		fattr;
>  	struct nfs_fh *			fh;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_lookup_root_arg {
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_pathconf_arg {
>  	const struct nfs_fh *		fh;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
> +};
> +
> +struct nfs4_pathconf_res {
> +	struct nfs_pathconf	       *pathconf;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_readdir_arg {
> @@ -643,11 +734,13 @@ struct nfs4_readdir_arg {
>  	struct page **			pages;	/* zero-copy data */
>  	unsigned int			pgbase;	/* zero-copy data */
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_readdir_res {
>  	nfs4_verifier			verifier;
>  	unsigned int			pgbase;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_readlink {
> @@ -655,6 +748,11 @@ struct nfs4_readlink {
>  	unsigned int			pgbase;
>  	unsigned int			pglen;   /* zero-copy data */
>  	struct page **			pages;   /* zero-copy data */
> +	struct nfs41_sequence_args	seq_args;
> +};
> +
> +struct nfs4_readlink_res {
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_rename_arg {
> @@ -663,6 +761,7 @@ struct nfs4_rename_arg {
>  	const struct qstr *		old_name;
>  	const struct qstr *		new_name;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_rename_res {
> @@ -671,6 +770,7 @@ struct nfs4_rename_res {
>  	struct nfs_fattr *		old_fattr;
>  	struct nfs4_change_info		new_cinfo;
>  	struct nfs_fattr *		new_fattr;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  #define NFS4_SETCLIENTID_NAMELEN	(127)
> @@ -689,6 +789,17 @@ struct nfs4_setclientid {
>  struct nfs4_statfs_arg {
>  	const struct nfs_fh *		fh;
>  	const u32 *			bitmask;
> +	struct nfs41_sequence_args	seq_args;
> +};
> +
> +struct nfs4_statfs_res {
> +	struct nfs_fsstat	       *fsstat;
> +	struct nfs41_sequence_res	seq_res;
> +};
> +
> +struct nfs4_server_caps_arg {
> +	struct nfs_fh		       *fhandle;
> +	struct nfs41_sequence_args	seq_args;
>  };
>  
>  struct nfs4_server_caps_res {
> @@ -696,6 +807,7 @@ struct nfs4_server_caps_res {
>  	u32				acl_bitmask;
>  	u32				has_links;
>  	u32				has_symlinks;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  struct nfs4_string {
> @@ -730,6 +842,12 @@ struct nfs4_fs_locations_arg {
>  	const struct qstr *name;
>  	struct page *page;
>  	const u32 *bitmask;
> +	struct nfs41_sequence_args	seq_args;
> +};
> +
> +struct nfs4_fs_locations_res {
> +	struct nfs4_fs_locations       *fs_locations;
> +	struct nfs41_sequence_res	seq_res;
>  };
>  
>  #endif /* CONFIG_NFS_V4 */
