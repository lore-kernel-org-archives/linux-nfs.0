Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:45075 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaGaLen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2014 07:34:43 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so3569824qgd.9
        for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2014 04:34:43 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 31 Jul 2014 07:34:41 -0400
To: NeilBrown <neilb@suse.de>
Cc: Natanael Copa <natanael.copa@gmail.com>, linux-nfs@vger.kernel.org,
        Natanael Copa <ncopa@alpinelinux.org>
Subject: Re: [PATCH 04/11] exportfs: define _GNU_SOURCE for stat64
Message-ID: <20140731073441.7e354359@tlielax.poochiereds.net>
In-Reply-To: <20140731113022.22afdefc@notabene.brown>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
	<1406719399-1735-5-git-send-email-ncopa@alpinelinux.org>
	<20140731113022.22afdefc@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 31 Jul 2014 11:30:22 +1000
NeilBrown <neilb@suse.de> wrote:

> On Wed, 30 Jul 2014 13:23:12 +0200 Natanael Copa <natanael.copa@gmail.com>
> wrote:
> 
> > Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
> > ---
> >  utils/exportfs/exportfs.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> > 
> > diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> > index bf07555..7ab93d1 100644
> > --- a/utils/exportfs/exportfs.c
> > +++ b/utils/exportfs/exportfs.c
> > @@ -12,6 +12,10 @@
> >  #include <config.h>
> >  #endif
> >  
> > +#ifndef _GNU_SOURCE
> > +#define _GNU_SOURCE
> > +#endif
> > +
> >  #include <sys/types.h>
> >  #include <sys/stat.h>
> >  #include <sys/vfs.h>
> 
> These all look really sensible!
> 
> One small suggestion: it would be really nice to see a comment in the code
> explaining why _GNU_SOURCE is needed.  I suspect such comments get out of
> date quickly, so maybe it wouldn't end up be all that useful.  But having a
> comment is still, in my opinion, more useful than not.
> 
> Thanks,
> NeilBrown
> 

Agreed, they all look pretty sensible. That said, I think the supposed
best way to enable _GNU_SOURCE on autoconf projects is to use
AC_USE_SYSTEM_EXTENSIONS:

    https://www.gnu.org/software/autoconf/manual/autoconf-2.64/html_node/Posix-Variants.html

-- 
Jeff Layton <jlayton@primarydata.com>
