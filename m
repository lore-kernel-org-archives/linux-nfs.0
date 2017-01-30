Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42566 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754380AbdA3Vck (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 16:32:40 -0500
Date: Mon, 30 Jan 2017 16:23:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: upstream nfsd kernel oops in auth_rpcgss
Message-ID: <20170130212321.GF12608@parsley.fieldses.org>
References: <79F89BE0-79A7-46A2-9CB8-E5D25C9E90DB@netapp.com>
 <20170130210237.GE12608@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20170130210237.GE12608@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 30, 2017 at 04:02:37PM -0500, J. Bruce Fields wrote:
> On Mon, Jan 30, 2017 at 03:15:36PM -0500, Olga Kornievskaia wrote:
> > Hi Bruce,
> > 
> > I ran into this oops in the nfsd (below) (4.10-rc3 kernel). To trigger this I had a client (unsuccessfully) try to mount the server with krb5 where the server doesn’t have the rpcsec_gss_krb5 module built. 
> 
> Whoops, thanks for catching that.
> 
> > Below code seems to fix things:
> > 
> > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > index 886e9d38..7faffd8 100644
> > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > @@ -1187,9 +1187,9 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
> >  		status = -EOPNOTSUPP;
> >  		/* get mech handle from OID */
> >  		gm = gss_mech_get_by_OID(&ud->mech_oid);
> > +		rsci.cred.cr_gss_mech = gm;
> >  		if (!gm)
> >  			goto out;
> > -		rsci.cred.cr_gss_mech = gm;
> >  
> >  		status = -EINVAL;
> >  		/* mech-specific data: */
> > 
> > I guess the problem is because rsci.cred gets initialed from something that’s passed in that doesn’t have it’s cr_gss_mech initialized to NULL. So when gss_mech_get_by_OID() fails and it calls rsc_free() and tries to free a bad pointer. 
> 
> Hm, yes, just above there's:
> 
> 	rsci.cred = ud->creds;
> 
> and it does make me a little nervous if ud->creds isn't completely
> initialized.
> 
> The only caller of gss_proxy_save_rsc is svcauth_gss_proxy_init:
> 
> 	status = gss_proxy_save_rsc(sn->rsc_cache, &ud, &handle);
> 
> ud there is on the stack, and initialized by:
> 
> 	memset(&ud, 0, sizeof(ud));
> 
> Hm, in gssp_accept_sec_context_upcall, there's:
> 
> 	data->creds = *(struct svc_cred *)value->data;
> 
> That looks really weird.  I'm not sure what it should be.

Does this do it?

--b.

diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index dc6fb79a361f..25d9a9cf7b66 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -260,7 +260,7 @@ static int gssx_dec_option_array(struct xdr_stream *xdr,
 	if (!oa->data)
 		return -ENOMEM;
 
-	creds = kmalloc(sizeof(struct svc_cred), GFP_KERNEL);
+	creds = kzalloc(sizeof(struct svc_cred), GFP_KERNEL);
 	if (!creds) {
 		kfree(oa->data);
 		return -ENOMEM;
