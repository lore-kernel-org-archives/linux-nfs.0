From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: below top level mounting NFS3 authentication patch
Date: Thu, 14 Aug 2008 16:54:14 -0400
Message-ID: <20080814205414.GL23859@fieldses.org>
References: <48A41A1B.7070501@few.vu.nl> <20080814192225.GF23859@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
To: EG Keizer <keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:36297 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379AbYHNUyQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 16:54:16 -0400
In-Reply-To: <20080814192225.GF23859@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 14, 2008 at 03:22:25PM -0400, bfields wrote:
> On Thu, Aug 14, 2008 at 01:42:19PM +0200, EG Keizer wrote:
> > At our faculty we use Linux (Debian) clients and Solaris 9/10 file servers.
> > We use the automounter on the Linux clients to access home directories with krb5.
> > The servers  export the home directories on the level above the user home
> > directories.
> > Kernel 2.6.18 allows this behavior, kernels later then 2.6.23 do not.
> > The underlying cause for the problem is the interpretation of the wording in
> > RFC 2623, sec  2.3.2. This allows fsinfo with UNIX authentication on the
> > root of the  export. But the automounter mounts below the root of the export/share
> > and the Solaris  server (justly) requires full, i.e. krb5, authentication.
> > Thus the mount fails, which makes the automounter useless in our environment.
> > The client should try both authentications and use the first one that
> > succeeds.
> > The nfs_proc_get_root subroutine in nfs3proc already does
> > this, but...
> > the call to the sget routine earlier in the routine nfs_get_sb causes a
> > fsinfo call that always uses UNIX authentication. Which causes the mount
> > to fail.
> >
> > The solution i came up with is simple. Transplant the way get_root
> > handles this to fsinfo. This is implemented in the patch to 2.6.24-rc4
> > in the attachment.
> >
> > The are probably better solutions. For example by collapsing the two
> > calls to get_root and fsinfo. But all i needed was something that made
> > things work for me and did not ruin something for anybody.
> >
> > It would be nice if this patch found its way into the distribution...
> 
> Seems fine to me.  Doesn't v2 need the same treatment as v3 here,
> though?

Oh, also, if you could read part 12 of Documentation/SubmittingPatches
and add a Signed-off-by: line, that'd help us.

> 
> --b.
> 
> >
> >
> > Ed Keizer
> > IT group                                        tel: +31 20 5987804
> > Faculty of Sciences		                fax: +31 20 5987653
> > Vrije Universiteit                              e-mail: keie-vHs5IaWfoDhmR6Xm/wNWPw@public.gmane.org
> > De Boelelaan 1081A, 1081 HV  Amsterdam, The Netherlands
> >
> >
> >
> 
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> > index 4cdc236..1215d42 100644
> > --- a/fs/nfs/nfs3proc.c
> > +++ b/fs/nfs/nfs3proc.c
> > @@ -687,7 +687,7 @@ nfs3_proc_statfs(struct nfs_server *server, struct nfs_fh *fhandle,
> >  }
> >  
> >  static int
> > -nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
> > +do_proc_fsinfo(struct rpc_clnt *client, struct nfs_fh *fhandle,
> >  		 struct nfs_fsinfo *info)
> >  {
> >  	struct rpc_message msg = {
> > @@ -699,11 +699,26 @@ nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
> >  
> >  	dprintk("NFS call  fsinfo\n");
> >  	nfs_fattr_init(info->fattr);
> > -	status = rpc_call_sync(server->nfs_client->cl_rpcclient, &msg, 0);
> > +	status = rpc_call_sync(client, &msg, 0);
> >  	dprintk("NFS reply fsinfo: %d\n", status);
> >  	return status;
> >  }
> >  
> > +/*
> > + * Bare-bones access to fsinfo: this is for nfs_get_root/nfs_get_sb via nfs_create_server
> > + */
> > +static int
> > +nfs3_proc_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle,
> > +		   struct nfs_fsinfo *info)
> > +{
> > +	int	status;
> > +
> > +	status = do_proc_fsinfo(server->client, fhandle, info);
> > +	if (status && server->nfs_client->cl_rpcclient != server->client)
> > +		status = do_proc_fsinfo(server->nfs_client->cl_rpcclient, fhandle, info);
> > +	return status;
> > +}
> > +
> >  static int
> >  nfs3_proc_pathconf(struct nfs_server *server, struct nfs_fh *fhandle,
> >  		   struct nfs_pathconf *info)
> > 
> 
