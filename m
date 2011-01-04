Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42002 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994Ab1ADVDp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 16:03:45 -0500
Subject: Re: [PATCH_V7 07/12] NFS implement v4.0 callback_ident
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: andros@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <1294174673.5896.15.camel@heimdal.trondhjem.org>
References: <1294173766-5573-1-git-send-email-andros@netapp.com>
	 <1294173766-5573-2-git-send-email-andros@netapp.com>
	 <1294173766-5573-3-git-send-email-andros@netapp.com>
	 <1294173766-5573-4-git-send-email-andros@netapp.com>
	 <1294173766-5573-5-git-send-email-andros@netapp.com>
	 <1294173766-5573-6-git-send-email-andros@netapp.com>
	 <1294173766-5573-7-git-send-email-andros@netapp.com>
	 <1294173766-5573-8-git-send-email-andros@netapp.com>
	 <1294174673.5896.15.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Jan 2011 16:03:43 -0500
Message-ID: <1294175023.5896.18.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-04 at 15:57 -0500, Trond Myklebust wrote: 
> On Tue, 2011-01-04 at 15:42 -0500, andros@netapp.com wrote: 
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Provide a unique callback identifier per SETCLIENTID call used to identify the
> > v4.0 callback service associated with the clientid.
> > 
> > Do not worry about wrap around. Zero value means unset.
> > 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  fs/nfs/nfs4proc.c         |    5 +++++
> >  fs/nfs/nfs4state.c        |    1 +
> >  include/linux/nfs_fs_sb.h |    1 +
> >  include/linux/nfs_xdr.h   |    1 +
> >  4 files changed, 8 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 78b0899..6652e39 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -3470,6 +3470,8 @@ do_state_recovery:
> >  	return -EAGAIN;
> >  }
> >  
> > +static u32 current_cb_ident = 1;
> > +
> >  int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
> >  		unsigned short port, struct rpc_cred *cred,
> >  		struct nfs4_setclientid_res *res)
> > @@ -3478,6 +3480,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
> >  	struct nfs4_setclientid setclientid = {
> >  		.sc_verifier = &sc_verifier,
> >  		.sc_prog = program,
> > +		.sc_cb_ident = current_cb_ident++,
> 
> How about instead using ida_get_new() in order to get a truly unique id
> in the range 1..0x7fffffff?

....

Actually, we might want to consider using idr_get_new(), since that
allows us to safely locate the struct nfs_client using idr_find()...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

