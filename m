Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932718Ab1FWULT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jun 2011 16:11:19 -0400
Date: Thu, 23 Jun 2011 16:11:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: autoload rpcsec_gss_krb5
Message-ID: <20110623201117.GB12357@fieldses.org>
References: <20110622213209.GA3010@fieldses.org>
 <20110623155947.GC8911@fieldses.org>
 <BANLkTikS+Y-V=f3Pm8AF-AUoeYVo==4SzA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <BANLkTikS+Y-V=f3Pm8AF-AUoeYVo==4SzA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jun 23, 2011 at 10:06:14PM +0200, Tigran Mkrtchyan wrote:
> On Thu, Jun 23, 2011 at 5:59 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > By the way:
> >
> > On Wed, Jun 22, 2011 at 05:32:09PM -0400, J. Bruce Fields wrote:
> >> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
> >> index 0a9a2ec..5c33926 100644
> >> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> >> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> >> @@ -743,6 +743,13 @@ static struct pf_desc gss_kerberos_pfs[] = {
> >>       },
> >>  };
> >>
> >> +MODULE_ALIAS("rpc-auth-gss-krb5");
> >> +MODULE_ALIAS("rpc-auth-gss-krb5i");
> >> +MODULE_ALIAS("rpc-auth-gss-krb5p");
> >> +MODULE_ALIAS("rpc-auth-gss-390003");
> >> +MODULE_ALIAS("rpc-auth-gss-390004");
> >> +MODULE_ALIAS("rpc-auth-gss-390005");
> >
> > Is there any reason we don't do this for the auth modules, and the pnfs
> > layout modules?  Seems silly to wait for distro's to add it to
> > modprobe.conf if we don't need to.
> >
> 
> I recall a discussion at connectaton 2010, where Peter Staubach from
> RedHat ( at that time )
> requested a way to disable pNFS without rebuilding the kernel.
> 
> Probably that's why autoload is not implemented.

Well, autoload *is* implemented, you just have to add an alias command
to modprobe.conf before it'll work.

And if we embed the alias in the module instead, it will still be
possible to disable autloading by adding a "backlist <modulename>" to
modproble.conf.

So I don't *think* that's the issue, unless I've missed something.

--b.
