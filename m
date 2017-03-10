Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60610 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755050AbdCJRdf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 12:33:35 -0500
Date: Fri, 10 Mar 2017 12:33:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 5 08/17] SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with
 label payload
Message-ID: <20170310173334.GF29791@fieldses.org>
References: <20170224221953.5502-1-andros@netapp.com>
 <20170224221953.5502-9-andros@netapp.com>
 <20170310173107.GE29791@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170310173107.GE29791@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 10, 2017 at 12:31:07PM -0500, J. Bruce Fields wrote:
> On Fri, Feb 24, 2017 at 05:19:44PM -0500, andros@netapp.com wrote:
> > From: Andy Adamson <andros@netapp.com>
> > 
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > ---
> >  net/sunrpc/auth_gss/auth_gss.c | 140 ++++++++++++++++++++++++++++++++++++++++-
> >  1 file changed, 138 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index 6ffb16d..98971cf 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -52,9 +52,12 @@
> >  #include <linux/sunrpc/gss_api.h>
> >  #include <linux/uaccess.h>
> >  #include <linux/hashtable.h>
> > +#include <linux/security.h>
> >  
> >  #include "../netns.h"
> >  
> > +static int gss3_create_label(struct rpc_cred *cred, int gss_vers);
> > +
> >  static const struct rpc_authops authgss_ops;
> >  
> >  static const struct rpc_credops gss_credops;
> > @@ -128,6 +131,20 @@ gss_put_ctx(struct gss_cl_ctx *ctx)
> >  		gss_free_ctx(ctx);
> >  }
> >  
> > +/* gss3_label_enabled:
> > + * Called to determine if Full Mode Mandatory Access Control (MAC)
> > + * over a GSS connection is desired.
> > + *
> > + * Note:
> > + * Currently Full Mode MAC is assuemed if SeLinux is enabled and
> > + * RPCSEC_GSS version 3 is in use.
> 
> Eventually I guess we may want support for GSSv3-enabled copy without
> full MAC, so we'll want some way to configure this.
> 
> Also, do I understand right that currently it's gssd that decides
> whether to enable GSSv3, by passing down the new version number?  How
> will the user choose whether to enable GSSv3 or not?
> 
> Should that be a mount option?
> 
> The mount option could then cause some "use_gss3" flag to be added in
> rpc_pipefs, in an info file or whatever.  I think that'd also provide
> backwards compatibility (if you're not already handling that some other
> way), since gssd could use the presence of that flag to decide whether
> the kernel was new enough to support the new downcall.

By the way, I didn't notice on a quick skim of the rest of the patches:
what happens if the server doesn't support GSSv3?  Does gssd negotiate
down to GSSv2 automatically?

How do you configure this on the server?  (It probably needs to be
possible to turn of mac labeling on the server.)

--b.
