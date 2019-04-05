Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96BD1C282CE
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 23:56:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6C5DC2186A
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 23:56:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726222AbfDEX4K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 19:56:10 -0400
Received: from fieldses.org ([173.255.197.46]:32770 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725973AbfDEX4K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Apr 2019 19:56:10 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 05D581D39; Fri,  5 Apr 2019 19:56:10 -0400 (EDT)
Date:   Fri, 5 Apr 2019 19:56:10 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Murphy Zhou <jencce.kernel@gmail.com>
Cc:     NeilBrown <neilb@suse.com>, jlayton@kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsd/nfsd3_proc_readdir: fix buffer count and page
 pointers
Message-ID: <20190405235609.GF8397@fieldses.org>
References: <20190404065711.19763-1-jencce.kernel@gmail.com>
 <87mul5z8tk.fsf@notabene.neil.brown.name>
 <CADJHv_t_Cqav7Wr8dHo0kBBX3-ws0qVDcYi4HZt26Dq8jO+DGQ@mail.gmail.com>
 <CADJHv_u-F+D-p-uhJzxKTwQijZHe8wHfcyC97tjAgOO_ToJYHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADJHv_u-F+D-p-uhJzxKTwQijZHe8wHfcyC97tjAgOO_ToJYHw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 05, 2019 at 02:10:13PM +0800, Murphy Zhou wrote:
> On Fri, Apr 5, 2019 at 14:08 Murphy Zhou <jencce.kernel@gmail.com> wrote:
> 
> >
> >
> > On Fri, Apr 5, 2019 at 06:47 NeilBrown <neilb@suse.com> wrote:
> >
> >> On Thu, Apr 04 2019, Murphy Zhou wrote:
> >>
> >> > After this commit
> >> >   f875a79 nfsd: allow nfsv3 readdir request to be larger.
> >> > nfsv3 readdir request size can be larger than PAGE_SIZE. So if the
> >> > directory been read is large enough, we can use multiple pages
> >> > in rq_respages. Update buffer count and page pointers like we do
> >> > in readdirplus to make this happen.
> >> >
> >> > Now listing a directory within 3000 files will panic because we
> >> > are counting in a wrong way and would write on random page.
> >> >
> >> > Fixes: f875a79 "nfsd: allow nfsv3 readdir request to be larger"
> >> > Signed-off-by: Murphy Zhou <jencce.kernel@gmail.com>
> >> > ---
> >> >
> >> > v2:
> >> >   fix nfs3svc_decode_readdirargs to set page pointers like
> >> decode_readdirplusargs
> >> >   do not test pointers in encode_entry as we've fixed them when decoding
> >> >
> >> >  fs/nfsd/nfs3proc.c | 17 +++++++++++++++--
> >> >  fs/nfsd/nfs3xdr.c  | 11 +++++++++--
> >> >  2 files changed, 24 insertions(+), 4 deletions(-)
> >> >
> >> > diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> >> > index 8f933e8..9bc32af 100644
> >> > --- a/fs/nfsd/nfs3proc.c
> >> > +++ b/fs/nfsd/nfs3proc.c
> >> > @@ -442,7 +442,9 @@
> >> >       struct nfsd3_readdirargs *argp = rqstp->rq_argp;
> >> >       struct nfsd3_readdirres  *resp = rqstp->rq_resp;
> >> >       __be32          nfserr;
> >> > -     int             count;
> >> > +     int             count = 0;
> >> > +     struct page     **p;
> >> > +     caddr_t         page_addr = NULL;
> >> >
> >> >       dprintk("nfsd: READDIR(3)  %s %d bytes at %d\n",
> >> >                               SVCFH_fmt(&argp->fh),
> >> > @@ -462,7 +464,18 @@
> >> >       nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie,
> >> >                                       &resp->common,
> >> nfs3svc_encode_entry);
> >> >       memcpy(resp->verf, argp->verf, 8);
> >> > -     resp->count = resp->buffer - argp->buffer;
> >> > +     count = 0;
> >>
> >> Thanks - looks good.
> >> Setting 'count' to zero a second time looks a bit clumsy, but that is a
> >> minor detail.
> >
> >
> Save some space in the stack :)

We're not *that* desperate for stack space.  But, I can live with it.
Queuing up for 5.1.

--b.

> 
> Thanks for your review!
> 
> M
> 
> >
> >>
> >>  Reviewed-by: NeilBrown <neilb@suse.com>
> >>
> >> Thanks,
> >> NeilBrown
> >>
> >>
> >> > +     for (p = rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
> >> > +             page_addr = page_address(*p);
> >> > +
> >> > +             if (((caddr_t)resp->buffer >= page_addr) &&
> >> > +                 ((caddr_t)resp->buffer < page_addr + PAGE_SIZE)) {
> >> > +                     count += (caddr_t)resp->buffer - page_addr;
> >> > +                     break;
> >> > +             }
> >> > +             count += PAGE_SIZE;
> >> > +     }
> >> > +     resp->count = count >> 2;
> >> >       if (resp->offset) {
> >> >               loff_t offset = argp->cookie;
> >> >
> >> > diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> >> > index 93fea24..8d78912 100644
> >> > --- a/fs/nfsd/nfs3xdr.c
> >> > +++ b/fs/nfsd/nfs3xdr.c
> >> > @@ -573,6 +573,7 @@ void fill_post_wcc(struct svc_fh *fhp)
> >> >  nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
> >> >  {
> >> >       struct nfsd3_readdirargs *args = rqstp->rq_argp;
> >> > +     int len;
> >> >       u32 max_blocksize = svc_max_payload(rqstp);
> >> >
> >> >       p = decode_fh(p, &args->fh);
> >> > @@ -582,8 +583,14 @@ void fill_post_wcc(struct svc_fh *fhp)
> >> >       args->verf   = p; p += 2;
> >> >       args->dircount = ~0;
> >> >       args->count  = ntohl(*p++);
> >> > -     args->count  = min_t(u32, args->count, max_blocksize);
> >> > -     args->buffer = page_address(*(rqstp->rq_next_page++));
> >> > +     len = args->count  = min_t(u32, args->count, max_blocksize);
> >> > +
> >> > +     while (len > 0) {
> >> > +             struct page *p = *(rqstp->rq_next_page++);
> >> > +             if (!args->buffer)
> >> > +                     args->buffer = page_address(p);
> >> > +             len -= PAGE_SIZE;
> >> > +     }
> >> >
> >> >       return xdr_argsize_check(rqstp, p);
> >> >  }
> >> > --
> >> > 1.8.3.1
> >>
> >
