Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:42694 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaFRQDK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2014 12:03:10 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so864643qab.20
        for <linux-nfs@vger.kernel.org>; Wed, 18 Jun 2014 09:03:09 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 18 Jun 2014 12:03:07 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix return of nfs4_acl_write_who
Message-ID: <20140618120307.38715dce@tlielax.poochiereds.net>
In-Reply-To: <20140618154204.GF17790@fieldses.org>
References: <1403000048-31245-1-git-send-email-jlayton@primarydata.com>
	<20140618154204.GF17790@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Jun 2014 11:42:04 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jun 17, 2014 at 06:14:08AM -0400, Jeff Layton wrote:
> > AFAICT, the only way to hit this error is to pass this function a bogus
> > "who" value. In that case, we probably don't want to return -1 as that
> > could get sent back to the client. Turn this into nfserr_serverfault,
> > which is a more appropriate error for a server bug like this.
> 
> I don't really care since there shouldn't be any way to hit this, but
> OK, applying for 3.17.
> 
> --b.
> 

Thanks. Yeah, it's pretty unlikely...

I saw a sparse warning from that and silencing it was the main impetus
for the patch. I guess we can also call it "future proofing". In the
event that some other bug ends causing this function to get passed a
bogus "who" arg, then I think we'll stand a better chance of noticing
it with this change.

> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/nfsd/nfs4acl.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfs4acl.c b/fs/nfsd/nfs4acl.c
> > index d714156a19fd..b0cf00d3ee7d 100644
> > --- a/fs/nfsd/nfs4acl.c
> > +++ b/fs/nfsd/nfs4acl.c
> > @@ -935,5 +935,5 @@ __be32 nfs4_acl_write_who(struct xdr_stream *xdr, int who)
> >  		return 0;
> >  	}
> >  	WARN_ON_ONCE(1);
> > -	return -1;
> > +	return nfserr_serverfault;
> >  }
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
