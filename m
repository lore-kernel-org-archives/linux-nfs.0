Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.alpinelinux.org ([74.117.189.114]:34407 "EHLO
	mail.alpinelinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754190AbaHFG4O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 02:56:14 -0400
Date: Wed, 6 Aug 2014 08:50:19 +0200
From: Natanael Copa <ncopa@alpinelinux.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/11] exportfs: define _GNU_SOURCE for stat64
Message-ID: <20140806085019.669421dc@ncopa-desktop.alpinelinux.org>
In-Reply-To: <53E0F386.3000206@RedHat.com>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
	<1406719399-1735-5-git-send-email-ncopa@alpinelinux.org>
	<20140731113022.22afdefc@notabene.brown>
	<20140731073441.7e354359@tlielax.poochiereds.net>
	<53E0F386.3000206@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 05 Aug 2014 11:08:54 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 07/31/2014 07:34 AM, Jeff Layton wrote:
> > On Thu, 31 Jul 2014 11:30:22 +1000
> > NeilBrown <neilb@suse.de> wrote:
> > 
> >> On Wed, 30 Jul 2014 13:23:12 +0200 Natanael Copa <natanael.copa@gmail.com>
> >> wrote:
> >>
> >>> Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
> >>> ---
> >>>  utils/exportfs/exportfs.c | 4 ++++
> >>>  1 file changed, 4 insertions(+)
> >>>
> >>> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> >>> index bf07555..7ab93d1 100644
> >>> --- a/utils/exportfs/exportfs.c
> >>> +++ b/utils/exportfs/exportfs.c
> >>> @@ -12,6 +12,10 @@
> >>>  #include <config.h>
> >>>  #endif
> >>>  
> >>> +#ifndef _GNU_SOURCE
> >>> +#define _GNU_SOURCE
> >>> +#endif
> >>> +
> >>>  #include <sys/types.h>
> >>>  #include <sys/stat.h>
> >>>  #include <sys/vfs.h>
> >>
> >> These all look really sensible!
> >>
> >> One small suggestion: it would be really nice to see a comment in the code
> >> explaining why _GNU_SOURCE is needed.  I suspect such comments get out of
> >> date quickly, so maybe it wouldn't end up be all that useful.  But having a
> >> comment is still, in my opinion, more useful than not.
> >>
> >> Thanks,
> >> NeilBrown
> >>
> > 
> > Agreed, they all look pretty sensible. That said, I think the supposed
> > best way to enable _GNU_SOURCE on autoconf projects is to use
> > AC_USE_SYSTEM_EXTENSIONS:
> > 
> >     https://www.gnu.org/software/autoconf/manual/autoconf-2.64/html_node/Posix-Variants.html
> > 
> Its sounds like these requests are mutually exclusive... Meaning
> if we use the AC_USE_SYSTEM_EXTENSIONS we will not get the
> comments as to why _GNU_SOURCE is needed because the these 
> #ifndefs and #define will go away... which I guess is OK...
> 
> Natanael, would you mind incorporate AC_USE_SYSTEM_EXTENSIONS as well
> as fix the typo Jeff pointed out in patch 11? 
> 
> Once that happens... I'm good to go on these... 

I sent a v2 set with the all the commented issues fixed to the list.

With AC_USE_SYSTEM_EXTENSIONS the patch with #include <libgen.h> should
not be needed in theory. But I kept it anyways as it should make things
more portable.

We are now working on another patch to make it actually run on musl...

Thanks for your feedback!


> 
> steved.

