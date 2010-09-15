Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752813Ab0IOPif (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 11:38:35 -0400
Date: Wed, 15 Sep 2010 11:38:30 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/8] nfs: standardize the rename response container
Message-ID: <20100915113830.63fccdf5@corrin.poochiereds.net>
In-Reply-To: <4F074BCC-0BFD-4AD1-8CB9-02DE2DEA440E@oracle.com>
References: <1284557041-4375-1-git-send-email-jlayton@redhat.com>
	<1284557041-4375-5-git-send-email-jlayton@redhat.com>
	<4F074BCC-0BFD-4AD1-8CB9-02DE2DEA440E@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 15 Sep 2010 11:29:38 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> > index 60fa509..6265fa8 100644
> > --- a/include/linux/nfs_xdr.h
> > +++ b/include/linux/nfs_xdr.h
> > @@ -411,6 +411,15 @@ struct nfs_renameargs {
> > 	struct nfs4_sequence_args	seq_args;
> > };
> > 
> > +struct nfs_renameres {
> > +	const struct nfs_server *	server;
> > +	struct nfs4_change_info		old_cinfo;
> > +	struct nfs_fattr *		old_fattr;
> > +	struct nfs4_change_info		new_cinfo;
> > +	struct nfs_fattr *		new_fattr;
> > +	struct nfs4_sequence_res	seq_res;
> > +};
> 
> Likewise.  Is #ifdef CONFIG_NFS_V4 needed here?  I guess the question is, have you tried building with CONFIG_NFS_V4 disabled?
> 

Yes, I have built this with v4 disabled and it worked just fine. The
#ifdef isn't really needed. I suppose we could add that in to save
a bit of memory but it's probably not worth it. Note that nfs_removeres
has the same sort of fields and they aren't wrapped in #ifdef's.

-- 
Jeff Layton <jlayton@redhat.com>
