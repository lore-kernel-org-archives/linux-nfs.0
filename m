From: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Subject: Re: AES support for RPCSEC_GSS?
Date: Wed, 13 Feb 2008 18:01:56 +0100
Message-ID: <20080213170155.GA12551@goelette.ens.fr>
References: <20080212012007.GA6993@goelette.ens.fr> <20080212043715.GD4561@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nef2.ens.fr ([129.199.96.40]:1680 "EHLO nef2.ens.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755877AbYBMRCJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2008 12:02:09 -0500
In-Reply-To: <20080212043715.GD4561@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 11:37:15PM -0500, J. Bruce Fields wrote:
> > in all the faqs it is said that there is no working support for
> > anything else than DES which is a bit outdated and not secure
> > nowadays.
> > 
> > It seemed to me that there was some code in the nfs-utils which
> > would do some security negociation (somewhere around utils/gssd/krb5_util.c),
> > but the kernel had nothing to support that.
> > 
> > I suppose this will be the last thing to be done once the security features
> > are working with the three versions of NFS.
> > 
> > What are the missing features in this field, and would it be difficult to
> > add support for other encryption schemes?
> 
> Kevin Coffman is working on support for AES (and other algorithms).
> It's mostly working at this point, so I think we'll be posting patches
> soon.

I'll be glad to try it once it is available

>        Is there something in particular you need or want to work on?

No, not really. I find the current implementation sufficient for my needs.
Maybe the server not being IPv6 compatible is not pleasing to the mind.
Unfortunately my coding experience is low and probably the nfsd code is not
the easy way to start.
