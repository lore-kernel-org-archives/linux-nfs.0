Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46318 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbcFFS5A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jun 2016 14:57:00 -0400
Date: Mon, 6 Jun 2016 14:56:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfds: Fix NFSD_MDS_PR_KEY on 32-bit by adding ULL postfix
Message-ID: <20160606185654.GC26189@fieldses.org>
References: <1465118633-2659-1-git-send-email-geert@linux-m68k.org>
 <1465122103.5944.0.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1465122103.5944.0.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 05, 2016 at 06:21:43AM -0400, Jeff Layton wrote:
> On Sun, 2016-06-05 at 11:23 +0200, Geert Uytterhoeven wrote:
> > On 32-bit:
> > 
> >     fs/nfsd/blocklayout.c: In function ‘nfsd4_block_get_device_info_scsi’:
> >     fs/nfsd/blocklayout.c:337: warning: integer constant is too large for ‘long’ type
> >     fs/nfsd/blocklayout.c:344: warning: integer constant is too large for ‘long’ type
> >     fs/nfsd/blocklayout.c: In function ‘nfsd4_scsi_fence_client’:
> >     fs/nfsd/blocklayout.c:385: warning: integer constant is too large for ‘long’ type
> > 
> > Add the missing "ULL" postfix to 64-bit constant NFSD_MDS_PR_KEY to fix
> > this.
> > 
> > Fixes: f99d4fbdae6765d0 ("nfsd: add SCSI layout support")
> > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> > ---
> > v2:
> >   - Add Reviewed-by.
> > 
> > Despite Bruce's "Thanks, applying for 4.6.--b." on 2016-03-29, this
> > still hasn't made it into next-20160603.

Apologies, I did apply that to my local 4.6 branch, but I never
collected any more 4.6 patches, and forgot to send a pull request.  I
think I've bugfixes for the current kernel slip by before this way, so I
need a better system....  Thanks for the reminder, feel free to bug me
again if this hasn't gone upstream by next week.

--b.

> > ---
> >  fs/nfsd/blocklayout.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
> > index e55b5242614da7a9..31f3df193bdbb47b 100644
> > --- a/fs/nfsd/blocklayout.c
> > +++ b/fs/nfsd/blocklayout.c
> > @@ -290,7 +290,7 @@ out_free_buf:
> >  	return error;
> >  }
> >  
> > -#define NFSD_MDS_PR_KEY		0x0100000000000000
> > +#define NFSD_MDS_PR_KEY		0x0100000000000000ULL
> >  
> >  /*
> >   * We use the client ID as a unique key for the reservations.
> 
> Thanks!
> 
> Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
