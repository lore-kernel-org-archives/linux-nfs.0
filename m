Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5.smtp.messagingengine.com ([66.111.4.29]:47228 "EHLO
	out5.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754873Ab1GHUBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2011 16:01:16 -0400
Date: Fri, 8 Jul 2011 13:00:02 -0700
From: Greg KH <greg@kroah.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>, neilb@suse.de,
        linux-nfs@vger.kernel.org, stable@kernel.org
Subject: Re: [stable] compile error with 2.6.39.3-rc1 kernel
Message-ID: <20110708200002.GB14592@kroah.com>
References: <201107081921.38800.toralf.foerster@gmx.de>
 <20110708191039.GB13886@fieldses.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20110708191039.GB13886@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 08, 2011 at 03:10:39PM -0400, J. Bruce Fields wrote:
> On Fri, Jul 08, 2011 at 07:21:38PM +0200, Toralf Förster wrote:
> > I get with the attached config under an almost stable Gentoo :
> > 
> >   CHK     include/generated/compile.h
> >   CC [M]  fs/nfsd/nfsctl.o
> > fs/nfsd/nfsctl.c:16:44: error: linux/sunrpc/gss_krb5_enctypes.h: No such file 
> > or directory
> 
> That file was added to upstream by
> b084f598df36b62dfae83c10ed17f0b66b50f442 "nfsd: fix dependency of nfsd
> on auth_rpcgss".  Did that get left out of the stable version of the
> patch somehow?

Yes it did, that is why I released the 2.6.39.3-rc2 kernel a few hours
afterward.

Toralf, can you try that one and let me know if this is resolved or not?

thanks,

greg k-h
