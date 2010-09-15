Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61247 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752833Ab0IOQpy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Sep 2010 12:45:54 -0400
Subject: Re: [PATCH 3/8] nfs: eliminate nfs4_rename_arg
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <8432F4C7-B2C0-4CB1-B3AA-63444ED6BF8E@oracle.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
	 <1284557041-4375-4-git-send-email-jlayton@redhat.com>
	 <8432F4C7-B2C0-4CB1-B3AA-63444ED6BF8E@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 15 Sep 2010 12:45:25 -0400
Message-ID: <1284569125.2816.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-09-15 at 11:26 -0400, Chuck Lever wrote:
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

No. Please don't add any more #ifdef CONFIG_NFS_V4 sections: that just
adds to the testing duties. The job now is to get rid of
CONFIG_NFS_V..., not to add more to it.

Trond
