Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60180 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755818AbcGHUZo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2016 16:25:44 -0400
Date: Fri, 8 Jul 2016 16:25:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Oleg Drokin <green@linuxhacker.ru>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: Correct a comment for NFSD_MAY_ defines location
Message-ID: <20160708202543.GA11269@fieldses.org>
References: <1467942578-3081513-1-git-send-email-green@linuxhacker.ru>
 <1467974731.24149.7.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1467974731.24149.7.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applied.--b.

On Fri, Jul 08, 2016 at 06:45:31AM -0400, Jeff Layton wrote:
> On Thu, 2016-07-07 at 21:49 -0400, Oleg Drokin wrote:
> > Those are now defined in fs/nfsd/vfs.h
> > 
> > Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> > ---
> >  fs/nfsd/nfsfh.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
> > index a891944..7e49dcb 100644
> > --- a/fs/nfsd/nfsfh.c
> > +++ b/fs/nfsd/nfsfh.c
> > @@ -298,7 +298,7 @@ out:
> >   * that it expects something not of the given type.
> >   *
> >   * @access is formed from the NFSD_MAY_* constants defined in
> > - * include/linux/nfsd/nfsd.h.
> > + * fs/nfsd/vfs.h.
> >   */
> >  __be32
> >  fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
> > int access)
> 
> Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
