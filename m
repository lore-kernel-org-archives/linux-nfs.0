Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:35916 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752532AbcIHSTb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2016 14:19:31 -0400
Received: by mail-qt0-f182.google.com with SMTP id l91so10822101qte.3
        for <linux-nfs@vger.kernel.org>; Thu, 08 Sep 2016 11:19:30 -0700 (PDT)
Message-ID: <1473358766.23262.5.camel@redhat.com>
Subject: Re: [PATCH 1/9] nfs: the length argument to read_buf should be
 unsigned
From: Jeff Layton <jlayton@redhat.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Sep 2016 14:19:26 -0400
In-Reply-To: <ed805f06-e8e4-4e96-6d4d-0d374437ed7f@Netapp.com>
References: <1473174760-29859-1-git-send-email-jlayton@redhat.com>
         <1473174760-29859-2-git-send-email-jlayton@redhat.com>
         <ed805f06-e8e4-4e96-6d4d-0d374437ed7f@Netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-08 at 13:39 -0400, Anna Schumaker wrote:
> Hi Jeff,
> 
> On 09/06/2016 11:12 AM, Jeff Layton wrote:
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/callback_xdr.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> > index 656f68f7fe53..d6a40c06ec26 100644
> > --- a/fs/nfs/callback_xdr.c
> > +++ b/fs/nfs/callback_xdr.c
> > @@ -72,7 +72,7 @@ static int nfs4_encode_void(struct svc_rqst
> > *rqstp, __be32 *p, void *dummy)
> >  	return xdr_ressize_check(rqstp, p);
> >  }
> >  
> > -static __be32 *read_buf(struct xdr_stream *xdr, int nbytes)
> > +static __be32 *read_buf(struct xdr_stream *xdr, unsigned int
> > nbytes)
> 
> Looks like the nbytes argument is only used by xdr_inline_decode(),
> which expects a size_t instead of an unsigned int.  If we're changing
> argument types, then maybe we should change it to a size_t instead.
> 
> Thoughts?
> Anna
> 

Sure, that works too. I'd have a hard time imagining when we'd ever use
those upper bits when size_t is 64 bits, but I doubt it'd hurt
anything. I'll go ahead and change that in my tree.

-- 
Jeff Layton <jlayton@redhat.com>
