From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 06/85] nfs41: common protocol definitions
Date: Mon, 17 Nov 2008 15:28:25 +0200
Message-ID: <49217179.307@panasas.com>
References: <4918920E.3030301@panasas.com> <1226348331-7201-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:4894 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753838AbYKQN2b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:28:31 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1179006qwe.37
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2008 05:28:29 -0800 (PST)
In-Reply-To: <1226348331-7201-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:18 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> nfs41: define all NFSv4.1 operation and error code constants.
> 
> Note that some of the definitions are used by both the nfs41 client
> and the server code (hence enclosed in
> defined(CONFIG_NFSD_V4_1) || defined(CONFIG_NFS_V4_1)).
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>  include/linux/nfs.h  |   19 ++++++++-
>  include/linux/nfs4.h |  112 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 128 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/nfs.h b/include/linux/nfs.h
> index 54af92c..4dd83f2 100644
> --- a/include/linux/nfs.h
> +++ b/include/linux/nfs.h
> @@ -109,7 +109,24 @@
>  	NFSERR_FILE_OPEN = 10046,      /*       v4 */
>  	NFSERR_ADMIN_REVOKED = 10047,  /*       v4 */
>  	NFSERR_CB_PATH_DOWN = 10048,   /*       v4 */
> -	NFSERR_REPLAY_ME = 10049	/*       v4 */
> +	NFSERR_BADIOMODE = 10049,		/* v4.1 */
> +	NFSERR_BADLAYOUT = 10050,		/* v4.1 */
> +	NFSERR_BAD_SESSION_DIGEST = 10051,	/* v4.1 */
> +	NFSERR_BADSESSION = 10052,		/* v4.1 */
> +	NFSERR_BADSLOT = 10053,			/* v4.1 */
> +	NFSERR_COMPLETE_ALREADY = 10054,	/* v4.1 */
> +	NFSERR_CONN_NOT_BOUND_TO_SESSION = 10055,/* v4.1 */
> +	NFSERR_DELEG_ALREADY_WANTED = 10056,	/* v4.1 */
> +	NFSERR_DIRDELEG_UNAVAIL = 10057,	/* v4.1 */
> +	NFSERR_LAYOUTTRYLATER = 10058,		/* v4.1 */
> +	NFSERR_LAYOUTUNAVAILABLE = 10059,	/* v4.1 */
> +	NFSERR_NOMATCHING_LAYOUT = 10060,	/* v4.1 */
> +	NFSERR_RECALLCONFLICT = 10061,		/* v4.1 */
> +	NFSERR_UNKNOWN_LAYOUTTYPE = 10062,	/* v4.1 */
> +	NFSERR_SEQ_MISORDERED = 10063,		/* v4.1 */
> +	NFSERR_SEQUENCE_POS = 10064,		/* v4.1 */
> +
> +	NFSERR_REPLAY_ME = 11001,	/* linux internal */

review 11-14: Trond wants to get rid of the NFSERR_ consts
and use NFS4ERR (enum nfs_stat) this will also clean up linux/nfs.h
so that nfs4 defs will be in nfs4.h

>  };
>  
>  /* NFSv2 file types - beware, these are not the same in NFSv3 */
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index ea03667..bdcd316 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -21,6 +21,7 @@
>  #define NFS4_FHSIZE		128
>  #define NFS4_MAXPATHLEN		PATH_MAX
>  #define NFS4_MAXNAMLEN		NAME_MAX
> +#define NFS4_MAX_SESSIONID_LEN	16
>  
>  #define NFS4_ACCESS_READ        0x0001
>  #define NFS4_ACCESS_LOOKUP      0x0002
> @@ -38,6 +39,7 @@
>  #define NFS4_OPEN_RESULT_CONFIRM 0x0002
>  #define NFS4_OPEN_RESULT_LOCKTYPE_POSIX 0x0004
>  
> +#define NFS4_SHARE_DENY_MASK	0x000F

review 11-14: NFS4_SHARE_ACCESS_MASK

>  #define NFS4_SHARE_ACCESS_READ	0x0001
>  #define NFS4_SHARE_ACCESS_WRITE	0x0002
>  #define NFS4_SHARE_ACCESS_BOTH	0x0003
> @@ -45,6 +47,20 @@
>  #define NFS4_SHARE_DENY_WRITE	0x0002
>  #define NFS4_SHARE_DENY_BOTH	0x0003
>  
> +#if defined(CONFIG_NFSD_V4_1) || defined(CONFIG_NFS_V4_1)

review 11-14: get rid of #ifdef in the definition

> +#define NFS4_SHARE_WANT_MASK		0xFF00
> +#define NFS4_SHARE_WANT_NO_PREFERENCE	0x0000
> +#define NFS4_SHARE_WANT_READ_DELEG	0x0100
> +#define NFS4_SHARE_WANT_WRITE_DELEG	0x0200
> +#define NFS4_SHARE_WANT_ANY_DELEG	0x0300
> +#define NFS4_SHARE_WANT_NO_DELEG	0x0400
> +#define NFS4_SHARE_WANT_CANCEL		0x0500
> +
> +#define NFS4_SHARE_WHEN_MASK		0xF0000
> +#define NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL	0x10000
> +#define NFS4_SHARE_PUSH_DELEG_WHEN_UNCONTENDED		0x20000
> +#endif /* CONFIG_NFSD_V4_1 || CONFIG_NFS_V4_1 */
> +
>  #define NFS4_SET_TO_SERVER_TIME	0
>  #define NFS4_SET_TO_CLIENT_TIME	1
>  
> @@ -88,6 +104,15 @@
>  #define NFS4_ACE_GENERIC_EXECUTE              0x001200A0
>  #define NFS4_ACE_MASK_ALL                     0x001F01FF
>  
> +#define EXCHGID4_FLAG_SUPP_MOVED_REFER	0x00000001
> +#define EXCHGID4_FLAG_SUPP_MOVED_MIGR	0x00000002
> +#define EXCHGID4_FLAG_USE_NON_PNFS	0x00010000
> +#define EXCHGID4_FLAG_USE_PNFS_MDS	0x00020000
> +#define EXCHGID4_FLAG_USE_PNFS_DS	0x00040000
> +#define EXCHGID4_INVAL_FLAG_MASK	0x77707774
> +
> +#define NFS4_LENGTH_EOF	(~(u64)0)

review 11-14: s/NFS4_LENGTH_EOF/NFS4_MAX_UINT64/
> +
>  enum nfs4_acl_whotype {
>  	NFS4_ACL_WHO_NAMED = 0,
>  	NFS4_ACL_WHO_OWNER,
> @@ -152,6 +177,27 @@ enum nfs_opnum4 {
>  	OP_VERIFY = 37,
>  	OP_WRITE = 38,
>  	OP_RELEASE_LOCKOWNER = 39,
> +#if defined(CONFIG_NFSD_V4_1) || defined(CONFIG_NFS_V4_1)

review 11-14: get rid of #ifdef

> +	OP_BACKCHANNEL_CTL = 40,
> +	OP_BIND_CONN_TO_SESSION = 41,
> +	OP_EXCHANGE_ID = 42,
> +	OP_CREATE_SESSION = 43,
> +	OP_DESTROY_SESSION = 44,
> +	OP_FREE_STATEID = 45,
> +	OP_GET_DIR_DELEGATION = 46,
> +	OP_GETDEVICEINFO = 47,
> +	OP_GETDEVICELIST = 48,
> +	OP_LAYOUTCOMMIT = 49,
> +	OP_LAYOUTGET = 50,
> +	OP_LAYOUTRETURN = 51,
> +	OP_SECINFO_NO_NAME = 52,
> +	OP_SEQUENCE = 53,
> +	OP_SET_SSV = 54,
> +	OP_TEST_STATEID = 55,
> +	OP_WANT_DELEGATION = 56,
> +	OP_DESTROY_CLIENTID = 57,
> +	OP_RECLAIM_COMPLETE = 58,
> +#endif /* defined(CONFIG_NFSD_V4_1) || defined(CONFIG_NFS_V4_1) */
>  	OP_ILLEGAL = 10044,
>  };
>  
> @@ -228,7 +274,47 @@ enum nfsstat4 {
>  	NFS4ERR_DEADLOCK = 10045,
>  	NFS4ERR_FILE_OPEN = 10046,
>  	NFS4ERR_ADMIN_REVOKED = 10047,
> -	NFS4ERR_CB_PATH_DOWN = 10048
> +	NFS4ERR_CB_PATH_DOWN = 10048,
> +#if defined(CONFIG_NFS_V4_1)

review 11-14: ditto

> +	NFS4ERR_BADIOMODE	= 10049,
> +	NFS4ERR_BADLAYOUT	= 10050,
> +	NFS4ERR_BAD_SESSION_DIGEST = 10051,
> +	NFS4ERR_BADSESSION	= 10052,
> +	NFS4ERR_BADSLOT		= 10053,
> +	NFS4ERR_COMPLETE_ALREADY = 10054,
> +	NFS4ERR_CONN_NOT_BOUND_TO_SESSION = 10055,
> +	NFS4ERR_DELEG_ALREADY_WANTED = 10056,
> +	NFS4ERR_BACK_CHAN_BUSY	= 10057,	/* backchan reqs outstanding */
> +	NFS4ERR_LAYOUTTRYLATER	= 10058,
> +	NFS4ERR_LAYOUTUNAVAILABLE = 10059,
> +	NFS4ERR_NOMATCHING_LAYOUT = 10060,
> +	NFS4ERR_RECALLCONFLICT	= 10061,
> +	NFS4ERR_UNKNOWN_LAYOUTTYPE = 10062,
> +	NFS4ERR_SEQ_MISORDERED = 10063, 	/* unexpected seq.id in req */
> +	NFS4ERR_SEQUENCE_POS	= 10064,	/* [CB_]SEQ. op not 1st op */
> +	NFS4ERR_REQ_TOO_BIG	= 10065,	/* request too big */
> +	NFS4ERR_REP_TOO_BIG	= 10066,	/* reply too big */
> +	NFS4ERR_REP_TOO_BIG_TO_CACHE = 10067,	/* rep. not all cached */
> +	NFS4ERR_RETRY_UNCACHED_REP = 10068,	/* retry & rep. uncached */
> +	NFS4ERR_UNSAFE_COMPOUND = 10069,	/* retry/recovery too hard */
> +	NFS4ERR_TOO_MANY_OPS	= 10070,	/* too many ops in [CB_]COMP */
> +	NFS4ERR_OP_NOT_IN_SESSION = 10071,	/* op needs [CB_]SEQ. op */
> +	NFS4ERR_HASH_ALG_UNSUPP = 10072,	/* hash alg. not supp. */
> +	NFS4ERR_CONN_BINDING_NOT_ENFORCED = 10073, /* SET_SSV not allowed */
> +	NFS4ERR_CLIENTID_BUSY	= 10074,	/* clientid has state */
> +	NFS4ERR_PNFS_IO_HOLE	= 10075,	/* IO to _SPARSE file hole */
> +	NFS4ERR_SEQ_FALSE_RETRY	= 10076,	/* retry not origional */
> +	NFS4ERR_BAD_HIGH_SLOT	= 10077,	/* sequence arg bad */
> +	NFS4ERR_DEADSESSION	= 10078,	/* persistent session dead */
> +	NFS4ERR_ENCR_ALG_UNSUPP = 10079,	/* SSV alg mismatch */
> +	NFS4ERR_PNFS_NO_LAYOUT	= 10080,	/* direct I/O with no layout */
> +	NFS4ERR_NOT_ONLY_OP	= 10081,	/* bad compound */
> +	NFS4ERR_WRONG_CRED	= 10082,	/* permissions:state change */
> +	NFS4ERR_WRONG_TYPE	= 10083,	/* current operation mismatch */
> +	NFS4ERR_DIRDELEG_UNAVAIL = 10084,	/* no directory delegation */
> +	NFS4ERR_REJECT_DELEG	= 10085,	/* on callback */
> +	NFS4ERR_RETURNCONFLICT	= 10086,	/* outstanding layoutreturn */
> +#endif /* CONFIG_NFS_V4_1 */
>  };
>  
>  /*
> @@ -348,7 +434,7 @@ enum lock_type4 {
>  
>  #define NFSPROC4_NULL 0
>  #define NFSPROC4_COMPOUND 1
> -#define NFS4_MINOR_VERSION 0
> +#define NFS4_MINOR_VERSION 1

review 11-14: get rid of this, it's unused.

>  #define NFS4_DEBUG 1
>  
>  /* Index of predefined Linux client operations */
> @@ -389,7 +475,29 @@ enum {
>  	NFSPROC4_CLNT_GETACL,
>  	NFSPROC4_CLNT_SETACL,
>  	NFSPROC4_CLNT_FS_LOCATIONS,
> +#if defined(CONFIG_NFS_V4_1)

review 11-14: get rid of #ifdef

> +	NFSPROC4_CLNT_EXCHANGE_ID,
> +	NFSPROC4_CLNT_CREATE_SESSION,
> +	NFSPROC4_CLNT_DESTROY_SESSION,
> +	NFSPROC4_CLNT_SEQUENCE,
> +	NFSPROC4_CLNT_GET_LEASE_TIME,
> +#endif /* CONFIG_NFSD_V4_1 */
> +};
> +
> +#if defined(CONFIG_NFSD_V4_1) || defined(CONFIG_NFS_V4_1)

get rid of the #ifdef

> +typedef unsigned char nfs41_sessionid[16];

review 11-14: change to struct nfs4_sessionid { unsigned char data[16]; };
no typedef.
change server name to nfsd4_private_sessionid

> +
> +/* Create Session Flags */
> +#define SESSION4_PERSIST	 0x001
> +#define SESSION4_BACK_CHAN 	 0x002
> +#define SESSION4_RDMA		 0x004
> +
> +enum state_protect_how4 {
> +	SP4_NONE	= 0,
> +	SP4_MACH_CRED	= 1,
> +	SP4_SSV		= 2
>  };
> +#endif /* defined(CONFIG_NFSD_V4_1) || defined(CONFIG_NFS_V4_1) */
>  
>  #endif
>  #endif
