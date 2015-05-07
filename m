Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49087 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750841AbbEGIvC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 04:51:02 -0400
Date: Thu, 7 May 2015 10:51:00 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
Message-ID: <20150507085100.GA17102@suse.de>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
 <20150507074046.GA13973@suse.de>
 <20150507082344.GD30924@vapier>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20150507082344.GD30924@vapier>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 07, Mike Frysinger wrote:

> On 07 May 2015 09:40, Thorsten Kukuk wrote:
> > On Thu, May 07, Mike Frysinger wrote:
> > > Starting with commit d5259e751111cb108c784b044296185f543fc0be (Add header
> > > definitions for rpc_gss_*() APIs), the gss headers were pulled in all the
> > > time leading to build failures like so:
> > >   CC       libtirpc_la-bindresvport.lo
> > > In file included from ../tirpc/rpc/svc_auth.h:44:0,
> > >                  from ../tirpc/rpc/rpc.h:68,
> > >                  from bindresvport.c:46:
> > > ../tirpc/rpc/rpcsec_gss.h:38:27: fatal error: gssapi/gssapi.h: No such file or directory
> > 
> > This will not work since this headers will be installed in
> > /usr/include and other appliations compiled against libtirpc
> > will never define HAVE_RPCSEC_GSS, thus never see this interfaces.
> > 
> > We need something like the glibc features.h file, which will always
> > be included and defines, how tirpc was configured.
> 
> this is what tirpc/rpc/rpc.h is already doing ...

Ok, I haven't seen that this is already broken :(
Means we need a solution how to provide this defines asap.

  Thorsten

-- 
Thorsten Kukuk, Senior Architect SLES & Common Code Base
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendörffer, Jane Smithard, Jennifer Guild, Dilip Upmanyu, Graham Norton, HRB 21284 (AG Nürnberg)
