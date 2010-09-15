Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753343Ab0IOPfB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 11:35:01 -0400
Date: Wed, 15 Sep 2010 11:34:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/8] nfs: eliminate nfs4_rename_arg
Message-ID: <20100915113430.1e59d8b8@corrin.poochiereds.net>
In-Reply-To: <8432F4C7-B2C0-4CB1-B3AA-63444ED6BF8E@oracle.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
	<1284557041-4375-4-git-send-email-jlayton@redhat.com>
	<8432F4C7-B2C0-4CB1-B3AA-63444ED6BF8E@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 15 Sep 2010 11:26:49 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Sep 15, 2010, at 9:23 AM, Jeff Layton wrote:
> 
> > Add the missing fields to nfs_renameargs and drop nfs4_rename_arg
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/nfs4proc.c       |    2 +-
> > fs/nfs/nfs4xdr.c        |    2 +-
> > include/linux/nfs_xdr.h |   19 ++++++-------------
> > 3 files changed, 8 insertions(+), 15 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 089da5b..eb36784 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2675,7 +2675,7 @@ static int _nfs4_proc_rename(struct inode *old_dir, struct qstr *old_name,
> > 		struct inode *new_dir, struct qstr *new_name)
> > {
> > 	struct nfs_server *server = NFS_SERVER(old_dir);
> > -	struct nfs4_rename_arg arg = {
> > +	struct nfs_renameargs arg = {
> > 		.old_dir = NFS_FH(old_dir),
> > 		.new_dir = NFS_FH(new_dir),
> > 		.old_name = old_name,
> > diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> > index 08ef912..7a098ae 100644
> > --- a/fs/nfs/nfs4xdr.c
> > +++ b/fs/nfs/nfs4xdr.c
> > @@ -1823,7 +1823,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
> > /*
> >  * Encode RENAME request
> >  */
> > -static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs4_rename_arg *args)
> > +static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs_renameargs *args)
> > {
> > 	struct xdr_stream xdr;
> > 	struct compound_hdr hdr = {
> > diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> > index 5436680..60fa509 100644
> > --- a/include/linux/nfs_xdr.h
> > +++ b/include/linux/nfs_xdr.h
> > @@ -403,10 +403,12 @@ struct nfs_removeres {
> >  * Common arguments to the rename call
> >  */
> > struct nfs_renameargs {
> > -	const struct nfs_fh *	old_dir;
> > -	const struct nfs_fh *	new_dir;
> > -	const struct qstr *	old_name;
> > -	const struct qstr *	new_name;
> > +	const struct nfs_fh *		old_dir;
> > +	const struct nfs_fh *		new_dir;
> > +	const struct qstr *		old_name;
> > +	const struct qstr *		new_name;
> > +	const u32 *			bitmask;
> > +	struct nfs4_sequence_args	seq_args;
> 
> Should these new fields be gated by CONFIG_NFS_V4 ?
> 

I suppose they could be. nfs_removeargs has the same fields though and
is not gated like that.

> > };
> > 
> > /*
> > @@ -793,15 +795,6 @@ struct nfs4_readlink_res {
> > 	struct nfs4_sequence_res	seq_res;
> > };
> > 
> > -struct nfs4_rename_arg {
> > -	const struct nfs_fh *		old_dir;
> > -	const struct nfs_fh *		new_dir;
> > -	const struct qstr *		old_name;
> > -	const struct qstr *		new_name;
> > -	const u32 *			bitmask;
> > -	struct nfs4_sequence_args	seq_args;
> > -};
> > -
> > struct nfs4_rename_res {
> > 	const struct nfs_server *	server;
> > 	struct nfs4_change_info		old_cinfo;
> > -- 
> > 1.7.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
