Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from msux-gh1-uea02.nsa.gov ([63.239.65.40]:62863 "EHLO
	msux-gh1-uea02.nsa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756888Ab0GGQaI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jul 2010 12:30:08 -0400
Subject: Re: [PATCH 07/10] NFSv4: Introduce new label structure
From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
        sds@tycho.nsa.gov, matthew.dodd@sparta.com, trond.myklebust@fys.uio.no,
        bfields@fieldses.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-security-module@vger.kernel.org,
        selinux@tycho.nsa.gov, linux-nfs@vger.kernel.org
In-Reply-To: <4C34A4F1.3060708@oracle.com>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
	 <1278513086-23964-8-git-send-email-dpquigl@tycho.nsa.gov>
	 <4C34A4F1.3060708@oracle.com>
Content-Type: text/plain
Date: Wed, 07 Jul 2010 12:22:07 -0400
Message-Id: <1278519727.2494.92.camel@moss-terrapins.epoch.ncsc.mil>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Chuck,
   Thank you for the comments. I'll go through and address them inline
(Sorry for the top post).

On Wed, 2010-07-07 at 12:01 -0400, Chuck Lever wrote:
> My comments below apply to the other NFS client patches as well.  This 
> seemed like the right one to use for code examples.
> 
> On 07/ 7/10 10:31 AM, David P. Quigley wrote:
> > In order to mimic the way that NFSv4 ACLs are implemented we have created a
> > structure to be used to pass label data up and down the call chain. This patch
> > adds the new structure and new members to the required NFSv4 call structures.
> >
> > Signed-off-by: Matthew N. Dodd<Matthew.Dodd@sparta.com>
> > Signed-off-by: David P. Quigley<dpquigl@tycho.nsa.gov>
> > ---
> >   fs/nfs/nfs4proc.c       |   26 ++++++++++++++++++++++++++
> >   fs/nfsd/xdr4.h          |    3 +++
> >   include/linux/nfs4.h    |    7 +++++++
> >   include/linux/nfs_fs.h  |    7 +++++++
> >   include/linux/nfs_xdr.h |   22 ++++++++++++++++++++++
> >   5 files changed, 65 insertions(+), 0 deletions(-)
> >
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 071fced..71bb8da 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -148,6 +148,32 @@ const u32 nfs4_fs_locations_bitmap[2] = {
> >   	| FATTR4_WORD1_MOUNTED_ON_FILEID
> >   };
> >
> > +#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> > +
> > +struct nfs4_label * nfs4_label_alloc (gfp_t flags)
> 
> Style: have you run these patches through scripts/checkpatch.pl?  Kernel 
> coding style likes "struct foo *function(args)", without the spaces.

I haven't run them through checkpatch in a while. I will make sure that
I do that soon and apply all of the style complaints from that.

> 
> > +{
> > +	struct nfs4_label *label = NULL;
> > +
> > +	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
> > +	if (label == NULL)
> > +		return NULL;
> 
> Instead of NULL, you could return an ERR_PTR.  NULL could then be used 
> to signal that labels aren't supported.  See below.

Is it possible for kzalloc to fail with something other than NULL
though?

> 
> > +
> > +	label->label = (void *)(label + 1);
> > +	label->len = NFS4_MAXLABELLEN;
> > +	/* 0 is the null format meaning that the data is not to be translated */
> > + 	label->lfs = 0;
> > +	return label;
> > +}
> > +
> > +void nfs4_label_free (struct nfs4_label *label)
> > +{
> > +	if (label)
> > +		kfree(label);
> 
> Style: kfree() already checks for a NULL pointer, so you shouldn't.  At 
> one point recently, all such checks were removed from the kernel in 
> favor of using the one already in kfree().

Thats a good point. I'll go through and clean these up.

> 
> Also, you check the server capabilities before calling this function, 
> nearly every time.  Is that really needed?  If there's a label data 
> structure, it should be freed whether the server supports it or not.

We should free the structure regardless of server support. We moved to
this code a long time ago so I don't quite remember if we will ever see
an allocated label data structure when the server does not support
labeling.

> 
> That capabilities check is probably going to be more complex if you want 
> to have NFSv3 label support as well.  Would it make sense to provide a 
> function that can check for NFSv3 (eventually) or NFSv4 label support?

I'm not sure about what James intends to do about NFSv3 security label
support but if it is what I think it might be then it is a different
beast than what I am doing for NFSv4. If anything James will probably
use the normal xattr method for security labels on NFSv3 because that is
the mechanism he is proposing. On NFSv3 this wont be a capability check
on the server for whether it supports security labels but instead would
be a capability check for if it supports xattrs (even then I don't think
it is since the xattr protocol is a sideband protocol). 

> 
> Or, fold such checks into your allocator?  Hiding the capabilities check 
> here would allow easy expansion in the future to include other NFS 
> versions, and cause less clutter in all callers.
> 
> > +	return;
> > +}
> > +
> > +#endif
> 
> Style: Generally speaking, we like to keep "#ifdef CONFIG_BAR" noise 
> down to a dull roar.  So, this is the right place to keep it, and the 
> generic functions (like nfs_lookup() and nfs_readdir()) is generally not.
> 
> Usually we accomplish this by having functions like nfs4_label_free() 
> always be available, but if CONFIG_NFS_V4_SECURITY_LABEL isn't set, the 
> function call is a no-op.

Hmm I could have sworn I got this comment before and fixed it. I'll go
back and make sure that this is the case in the patches. Looking at
patch 7 alone it doesn't seem like we do this but I will go about
checking and fixing it just to be sure.

> 
> > +
> >   static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dentry,
> >   		struct nfs4_readdir_arg *readdir)
> >   {
> > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > index efa3377..c217277 100644
> > --- a/fs/nfsd/xdr4.h
> > +++ b/fs/nfsd/xdr4.h
> > @@ -108,6 +108,7 @@ struct nfsd4_create {
> >   	struct iattr	cr_iattr;           /* request */
> >   	struct nfsd4_change_info  cr_cinfo; /* response */
> >   	struct nfs4_acl *cr_acl;
> > +	struct nfs4_label *cr_label;
> >   };
> >   #define cr_linklen	u.link.namelen
> >   #define cr_linkname	u.link.name
> > @@ -235,6 +236,7 @@ struct nfsd4_open {
> >   	int		op_truncate;        /* used during processing */
> >   	struct nfs4_stateowner *op_stateowner; /* used during processing */
> >   	struct nfs4_acl *op_acl;
> > +	struct nfs4_label *op_label;
> >   };
> >   #define op_iattr	iattr
> >   #define op_verf		verf
> > @@ -316,6 +318,7 @@ struct nfsd4_setattr {
> >   	u32		sa_bmval[3];        /* request */
> >   	struct iattr	sa_iattr;           /* request */
> >   	struct nfs4_acl *sa_acl;
> > +	struct nfs4_label *sa_label;
> >   };
> >
> >   struct nfsd4_setclientid {
> > diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> > index a2abd1a..c512a0c 100644
> > --- a/include/linux/nfs4.h
> > +++ b/include/linux/nfs4.h
> > @@ -167,6 +167,13 @@ struct nfs4_acl {
> >   	struct nfs4_ace	aces[0];
> >   };
> >
> > +struct nfs4_label {
> > +	void		*label;
> > +	u32		len;
> > +	uint32_t	lfs;
> > +};
> 
> If we have support for NFS labels in NFSv3, would we also use struct 
> nfs4_label?

I don't believe this is the case. NFSv3 label support won't come in the
form of file attribute. Instead it will use James' out of band xattr
protocol. At that point the changes for getting the label into the inode
are very different. The reason we have to do all of this is because we
are getting the security label in NFSv4 from the fattr structure. This
structure contains what I'd call first class inode attributes. In Linux
security labels are handled through the xattr interface instead. Initial
I tried modifying the iattr structure which would have made it easier to
apply the fattr attributes to the inode including the security label.
This got pushback from Christoph since xattrs are the interface for
security labels. Also this wasn't a good solution because I needed a
dentry for the setxattr and getxattr calls and that wasn't available at
that point.

> 
> It seems to me you want something more generic, just like nfs_fh or 
> nfs_fattr, to represent these.  Over time, I'm guessing label support 
> won't be tied to a specific NFS version.  And, you are passing these 
> around in the generic NFS functions (for post-op updates and inode 
> revalidation, and what not).
> 
> Can I recommend "struct nfs_seclabel" instead?  Then have 
> nfs_seclabel_alloc() and nfs_seclabel_free().

I can definitely rename them to be more generic. I don't see anything
else besides NFSv4 using them but its fine with me to rename them. The
reason we call them nfs4_label is because we modeled it after the NFSv4
acl support code. I spoke with Christoph a long time ago and he
suggested that it should be handled the same way that the NFSv4 ACLs are
handled as opposed to the iattr thing we were trying. 

> 
> Does it make sense to deduplicate these in the client's memory?  It 
> seems to me that you could have hundreds or thousands that all contain 
> the same label information.

I don't think it is worth the effort. We are only using these structures
until the security label is crammed into the inode. Once that happens
they get freed. You shouldn't have them sitting around for very long.
They will be pulled again when the inode attributes expire and need to
be revalidated. For things like SELinux you could argue that the LSM
might benefit from this (and it might already do it but I'm not sure)
but I think that is something to be handled by the LSM itself or the
credentials code (since it already supports COW credentials it should be
possible). 

> 
> > +
> > +
> >   typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
> >   typedef struct { char data[NFS4_STATEID_SIZE]; } nfs4_stateid;
> >
> > diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> > index 07ce460..2813b71 100644
> > --- a/include/linux/nfs_fs.h
> > +++ b/include/linux/nfs_fs.h
> > @@ -454,6 +454,13 @@ extern int nfs_mountpoint_expiry_timeout;
> >   extern void nfs_release_automount_timer(void);
> >
> >   /*
> > + * linux/fs/nfs/nfs4proc.c
> > + */
> > +
> > +struct nfs4_label *	nfs4_label_alloc (gfp_t flags);
> > +void			nfs4_label_free (struct nfs4_label *);
> > +
> > +/*
> >    * linux/fs/nfs/unlink.c
> >    */
> >   extern int  nfs_async_unlink(struct inode *dir, struct dentry *dentry);
> > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> > index 28cde54..dc505e4 100644
> > --- a/include/linux/nfs_xdr.h
> > +++ b/include/linux/nfs_xdr.h
> > @@ -207,6 +207,7 @@ struct nfs_openargs {
> >   	const struct nfs_server *server;	 /* Needed for ID mapping */
> >   	const u32 *		bitmask;
> >   	__u32			claim;
> > +	const struct nfs4_label *label;
> >   	struct nfs4_sequence_args	seq_args;
> >   };
> >
> > @@ -216,7 +217,9 @@ struct nfs_openres {
> >   	struct nfs4_change_info	cinfo;
> >   	__u32                   rflags;
> >   	struct nfs_fattr *      f_attr;
> > +	struct nfs4_label *	f_label;
> >   	struct nfs_fattr *      dir_attr;
> > +	struct nfs4_label *	dir_label;
> >   	struct nfs_seqid *	seqid;
> >   	const struct nfs_server *server;
> >   	fmode_t			delegation_type;
> > @@ -256,6 +259,7 @@ struct nfs_closeargs {
> >   struct nfs_closeres {
> >   	nfs4_stateid            stateid;
> >   	struct nfs_fattr *	fattr;
> > +	struct nfs4_label *	label;
> >   	struct nfs_seqid *	seqid;
> >   	const struct nfs_server *server;
> >   	struct nfs4_sequence_res	seq_res;
> > @@ -324,6 +328,7 @@ struct nfs4_delegreturnargs {
> >
> >   struct nfs4_delegreturnres {
> >   	struct nfs_fattr * fattr;
> > +	struct nfs4_label * label;
> >   	const struct nfs_server *server;
> >   	struct nfs4_sequence_res	seq_res;
> >   };
> > @@ -343,6 +348,7 @@ struct nfs_readargs {
> >
> >   struct nfs_readres {
> >   	struct nfs_fattr *	fattr;
> > +	struct nfs4_label *	label;
> >   	__u32			count;
> >   	int                     eof;
> >   	struct nfs4_sequence_res	seq_res;
> > @@ -390,6 +396,7 @@ struct nfs_removeres {
> >   	const struct nfs_server *server;
> >   	struct nfs4_change_info	cinfo;
> >   	struct nfs_fattr	dir_attr;
> > +	struct nfs4_label	*dir_label;
> >   	struct nfs4_sequence_res 	seq_res;
> >   };
> >
> > @@ -405,6 +412,7 @@ struct nfs_entry {
> >   	int			eof;
> >   	struct nfs_fh *		fh;
> >   	struct nfs_fattr *	fattr;
> > +	struct nfs4_label *	label;
> >   };
> >
> >   /*
> > @@ -443,6 +451,7 @@ struct nfs_setattrargs {
> >   	struct iattr *                  iap;
> >   	const struct nfs_server *	server; /* Needed for name mapping */
> >   	const u32 *			bitmask;
> > +	const struct nfs4_label *	label;
> >   	struct nfs4_sequence_args 	seq_args;
> >   };
> >
> > @@ -473,6 +482,7 @@ struct nfs_getaclres {
> >
> >   struct nfs_setattrres {
> >   	struct nfs_fattr *              fattr;
> > +	struct nfs4_label *		label;
> >   	const struct nfs_server *	server;
> >   	struct nfs4_sequence_res	seq_res;
> >   };
> > @@ -662,6 +672,7 @@ struct nfs4_accessargs {
> >   struct nfs4_accessres {
> >   	const struct nfs_server *	server;
> >   	struct nfs_fattr *		fattr;
> > +	struct nfs4_label *		label;
> >   	u32				supported;
> >   	u32				access;
> >   	struct nfs4_sequence_res	seq_res;
> > @@ -684,6 +695,7 @@ struct nfs4_create_arg {
> >   	const struct iattr *		attrs;
> >   	const struct nfs_fh *		dir_fh;
> >   	const u32 *			bitmask;
> > +	const struct nfs4_label *	label;
> >   	struct nfs4_sequence_args 	seq_args;
> >   };
> >
> > @@ -691,8 +703,10 @@ struct nfs4_create_res {
> >   	const struct nfs_server *	server;
> >   	struct nfs_fh *			fh;
> >   	struct nfs_fattr *		fattr;
> > +	struct nfs4_label *		label;
> >   	struct nfs4_change_info		dir_cinfo;
> >   	struct nfs_fattr *		dir_fattr;
> > +	struct nfs4_label *		dir_label;
> >   	struct nfs4_sequence_res	seq_res;
> >   };
> >
> > @@ -717,6 +731,7 @@ struct nfs4_getattr_res {
> >   	const struct nfs_server *	server;
> >   	struct nfs_fattr *		fattr;
> >   	struct nfs4_sequence_res	seq_res;
> > +	struct nfs4_label *		label;
> >   };
> >
> >   struct nfs4_link_arg {
> > @@ -730,8 +745,10 @@ struct nfs4_link_arg {
> >   struct nfs4_link_res {
> >   	const struct nfs_server *	server;
> >   	struct nfs_fattr *		fattr;
> > +	struct nfs4_label *		label;
> >   	struct nfs4_change_info		cinfo;
> >   	struct nfs_fattr *		dir_attr;
> > +	struct nfs4_label *		dir_label;
> >   	struct nfs4_sequence_res	seq_res;
> >   };
> >
> > @@ -747,6 +764,7 @@ struct nfs4_lookup_res {
> >   	const struct nfs_server *	server;
> >   	struct nfs_fattr *		fattr;
> >   	struct nfs_fh *			fh;
> > +	struct nfs4_label *		label;
> >   	struct nfs4_sequence_res	seq_res;
> >   };
> >
> > @@ -800,6 +818,8 @@ struct nfs4_rename_arg {
> >   	const struct nfs_fh *		new_dir;
> >   	const struct qstr *		old_name;
> >   	const struct qstr *		new_name;
> > +	const struct nfs4_label *	old_label;
> > +	const struct nfs4_label *	new_label;
> >   	const u32 *			bitmask;
> >   	struct nfs4_sequence_args	seq_args;
> >   };
> > @@ -808,8 +828,10 @@ struct nfs4_rename_res {
> >   	const struct nfs_server *	server;
> >   	struct nfs4_change_info		old_cinfo;
> >   	struct nfs_fattr *		old_fattr;
> > +	struct nfs4_label *		old_label;
> >   	struct nfs4_change_info		new_cinfo;
> >   	struct nfs_fattr *		new_fattr;
> > +	struct nfs4_label *		new_label;
> >   	struct nfs4_sequence_res	seq_res;
> >   };
> >

