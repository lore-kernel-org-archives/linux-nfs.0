Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10181 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab2EVPgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 11:36:22 -0400
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
In-Reply-To: <20120522152432.GA11739@pad.fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
	 <1337087550-9821-4-git-send-email-simo@redhat.com>
	 <20120522150356.GE891@fieldses.org>
	 <1337699531.16840.185.camel@willson.li.ssimo.org>
	 <20120522152432.GA11739@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 May 2012 11:36:14 -0400
Message-ID: <1337700974.16840.198.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-05-22 at 11:24 -0400, J. Bruce Fields wrote:
> On Tue, May 22, 2012 at 11:12:11AM -0400, Simo Sorce wrote:
> > On Tue, 2012-05-22 at 11:03 -0400, J. Bruce Fields wrote:
> > > Note also if you rebase to my latest for-3.5 you need something like
> > > the following (untested).
> > > 
> > > --b.
> > > 
> > > commit 2cc8f0912880a177eee73e08c4305ac3692b8ff9
> > > Author: J. Bruce Fields <bfields@redhat.com>
> > > Date:   Tue May 22 08:44:08 2012 -0400
> > > 
> > >     client_name->cred.cr_principal
> > > 
> > > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> > > index 0211265..95104ae 100644
> > > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > > @@ -1182,26 +1182,27 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
> > >  
> > >  		/* get client name */
> > >  		if (ud->client_name.len != 0) {
> > > +			struct svc_cred *cred = &rsci.cred;
> > >  			status = -ENOMEM;
> > >  			/* convert to GSS_NT_HOSTBASED_SERVICE form */
> > > -			rsci.client_name = kstrndup(ud->client_name.data,
> > > +			cred->cr_principal = kstrndup(ud->client_name.data,
> > >  							ud->client_name.len,
> > >  							GFP_KERNEL);
> > > -			if (!rsci.client_name)
> > > +			if (!cred->cr_principal)
> > >  				goto out;
> > >  			/* terminate and remove realm part */
> > > -			c = strchr(rsci.client_name, '@');
> > > +			c = strchr(cred->cr_principal, '@');
> > >  			if (c) {
> > >  				*c = '\0';
> > >  
> > >  				/* change service-hostname delimiter */
> > > -				c = strchr(rsci.client_name, '/');
> > > +				c = strchr(cred->cr_principal, '/');
> > >  				if (c) *c = '@';
> > >  			}
> > >  			if (!c) {
> > >  				/* not a service principal */
> > > -				kfree(rsci.client_name);
> > > -				rsci.client_name = NULL;
> > > +				kfree(cred->cr_principal);
> > > +				cred->cr_principal = NULL;
> > >  			}
> > >  		}
> > >  	}
> > 
> > I have a patch to move this in gss_rpc_upcall.c instead, it's cleaner, I
> > think.
> 
> OK.  Also, could we just ditch the "not a service principal" case?  I
> know svcgssd doesn't currently pass those down, but that's not really
> right--I'd actually prefer to have those principals as well.

I can include the user principal, but I will not have time to test if it
breaks anything.

> And, dumb question (have I asked this before?): is it a problem to throw
> away the realm there?  If there exist both nfs/example.com@FOO and
> nfs/example.com@BAR that shouldn't be treated identically, then does
> that just mean our configuration is screwed up?

Well, I was surprised to see the realm was removed, but the reason
probably is that you are basically just relying on the fact that a
specific client is a member of only a specific REALM, and the fqdn is
used to resolve which realm it is part of. It is technically incorrect
to rely on such assumption, but it is correct in all reasonable actual
deployments because normally applications have no way to obtain a ticket
unless they can map fqdn -> REALM.

This does not hold true for users though, so if you want me to leave the
user principal in there I will not strip the realm from it.

Is it ok to keep the code as is and remove the principal 'exclusion' to
a later patch ? That will make it also easier to spot with a bisect if
this semantic change were to cause issues anywhere.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

