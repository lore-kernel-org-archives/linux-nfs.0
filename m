Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88920C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 02:55:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4501C2133D
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 02:55:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rghdgTOM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726218AbfDDCz6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Apr 2019 22:55:58 -0400
Received: from mail-qk1-f196.google.com ([209.85.222.196]:38814 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726193AbfDDCz6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Apr 2019 22:55:58 -0400
Received: by mail-qk1-f196.google.com with SMTP id g1so762016qki.5
        for <linux-nfs@vger.kernel.org>; Wed, 03 Apr 2019 19:55:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=adrZqJSAz+POTJxnAbfxmm9CzIl28+aUZ8CXERFm1No=;
        b=rghdgTOMoxiY7jzQ9PxsOp74j1Q7VOr0YMtY1s8i/Ci6NHk138+jVq83B6ZEDvUnPC
         A0j2dbZOQMHAKymhHr/4W4b/XOaVBXgfVPWQvIqAfWpwI4vlBpb+dfkcK9++gsWf4Jgs
         R3sVxll+bavgjaoyWiIZWLgxpS8WV4SjrkSnpQ2Kxffx9G/Wb2WU2n9XWiNIVm8lCL8H
         +L/r57f7LHUrawKOXx3/IEA4+cjBGGr8MnxHcHb8Ut0Gmxt3Vd6UXapr9DaoKR5rSjlN
         SkBzan7kzQJ5nNVINmeZGZ/PYIVesaasp8ahvXN1crNGalPFcp4SRl82H+Y/uPwLEGc3
         T0Xw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=adrZqJSAz+POTJxnAbfxmm9CzIl28+aUZ8CXERFm1No=;
        b=ELva/DaoFSVzYV5kJtmgIG8135c21/qSD1oNUG7raV2UiLMALx2Nq1YknPMWQr7HmN
         x6JDvPEQqFH8Thg5iDU2HMZa/wGEpFlYZjxpc6xhTT1MG/Q8s6wu5EWY4FTddkZ0hEo8
         gHDUFvcigKQdDxrcXEtPzjLH5uW7STHACUWb9iqcnRwCHSdLdM+teQXKL8iXR3eBcQr/
         8h1/yBwnpA0Aa+7MIwl+k0+eTK+r/p/dtdBXzMI50RVHA/fzy2oDWwHh7zZRKXDpArHe
         xou+sOp4P5hsGdGAzwW5Y01URoctSUvETpeRsL2PX9omvMaaceQtj6XXfLfDn3G2iFWy
         amZA==
X-Gm-Message-State: APjAAAWz48OpWTS16TIpG8K8wRTL3iZbT8RQCFKgnc9Ho2zpS3EUu1i2
        kMbSL8aF/TymF547gCfnJzx52C7Rf54QL9ml+Qo=
X-Google-Smtp-Source: APXvYqy95zIuahC5l4C/Nxiu5ZPNGXdGNLLnf/xX8mw3MI/nJ6zKAG8sP5BfiM8rIxZ4z8GKnuKG6NXVcS96zfggGgU=
X-Received: by 2002:a37:9a54:: with SMTP id c81mr3068842qke.113.1554346557226;
 Wed, 03 Apr 2019 19:55:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190329142332.12010-1-jencce.kernel@gmail.com> <875zry34ir.fsf@notabene.neil.brown.name>
In-Reply-To: <875zry34ir.fsf@notabene.neil.brown.name>
From:   Murphy Zhou <jencce.kernel@gmail.com>
Date:   Thu, 4 Apr 2019 10:55:45 +0800
Message-ID: <CADJHv_tXK95rQyu7+S8hRDFXRM2+pP7VV586PWSy4V6T-FqoGg@mail.gmail.com>
Subject: Re: [PATCH] nfsd/nfsd3_proc_readdir: check before encoding on
 temporary page
To:     NeilBrown <neilb@suse.com>
Cc:     linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

Thanks for the review!

On Mon, Apr 1, 2019 at 9:20 AM NeilBrown <neilb@suse.com> wrote:
>
> On Fri, Mar 29 2019, Murphy Zhou wrote:
>
> > After this commit
> >   f875a79 nfsd: allow nfsv3 readdir request to be larger.
> > nfsv3 readdir request size can be larger than PAGE_SIZE. So if the
> > request and the directory are large enough, we can run out of pages
> > in rq_respages. Then the temporary page we are encoding on is a
> > random page, Oops happen.
> >
> > Listing a directory with 30000 files in it can trigger the panic.
> >
> > Fixing this by ensuring the temporary page resides in rq_respages.
> > And when counting how many bytes left currently from buffer to the
> > end of the page which buffer is pointing to, aka len1, do not
> > assume that curr_page_addr is at the beginning of the same page.
> > Also, update resp->count by going through all pages. Because the
> > pages may not be sequential, the old way is not safe.
> >
> > Fixes: f875a79 "nfsd: allow nfsv3 readdir request to be larger"
> > Signed-off-by: Murphy Zhou <jencce.kernel@gmail.com>
>
> Hi,
>  thanks for finding these problems and submitting a patch.  Clearly I
>  should have tested better :-(
>
> > ---
> >  fs/nfsd/nfs3proc.c | 17 +++++++++++++++--
> >  fs/nfsd/nfs3xdr.c  |  8 +++++---
> >  2 files changed, 20 insertions(+), 5 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
> > index 8f933e84cec1..9bc32af4e2da 100644
> > --- a/fs/nfsd/nfs3proc.c
> > +++ b/fs/nfsd/nfs3proc.c
> > @@ -442,7 +442,9 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
> >       struct nfsd3_readdirargs *argp = rqstp->rq_argp;
> >       struct nfsd3_readdirres  *resp = rqstp->rq_resp;
> >       __be32          nfserr;
> > -     int             count;
> > +     int             count = 0;
> > +     struct page     **p;
> > +     caddr_t         page_addr = NULL;
> >
> >       dprintk("nfsd: READDIR(3)  %s %d bytes at %d\n",
> >                               SVCFH_fmt(&argp->fh),
> > @@ -462,7 +464,18 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
> >       nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie,
> >                                       &resp->common, nfs3svc_encode_entry);
> >       memcpy(resp->verf, argp->verf, 8);
> > -     resp->count = resp->buffer - argp->buffer;
> > +     count = 0;
> > +     for (p = rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
> > +             page_addr = page_address(*p);
> > +
> > +             if (((caddr_t)resp->buffer >= page_addr) &&
> > +                 ((caddr_t)resp->buffer < page_addr + PAGE_SIZE)) {
> > +                     count += (caddr_t)resp->buffer - page_addr;
> > +                     break;
> > +             }
> > +             count += PAGE_SIZE;
> > +     }
> > +     resp->count = count >> 2;
> >       if (resp->offset) {
> >               loff_t offset = argp->cookie;
>
> This section makes perfect sense.  You have copied code from
> nfsd3_proc_readdirplus() int nfsd3_proc_readdir().  This is needed
> because readdir doesn't limit replies to PAGE_SIZE any more.
>
> >
> > diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> > index 93fea246f676..1fabf1952bdb 100644
> > --- a/fs/nfsd/nfs3xdr.c
> > +++ b/fs/nfsd/nfs3xdr.c
> > @@ -953,6 +953,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
> >                       break;
> >       }
> >
> > +
>
> Adding blank lines is best avoided.
>
> >       if ((caddr_t)(cd->buffer + elen) < (curr_page_addr + PAGE_SIZE)) {
> >               /* encode entry in current page */
> >
> > @@ -961,11 +962,12 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
> >               if (plus)
> >                       p = encode_entryplus_baggage(cd, p, name, namlen, ino);
> >               num_entry_words = p - cd->buffer;
> > -     } else if (*(page+1) != NULL) {
> > +     } else if (*(page+1) != NULL && (page+1) < cd->rqstp->rq_next_page) {
>
> Adding the test against rq_next_page looks correct.
> nfs3svc_decode_readdirplusargs increments ->rq_next_page over enough
> pages to cover the request count.
> However nfs4svc_decode_readdirargs doesn't!  So it will not advance
> rq_next_page properly.  We need to fix that to make it like
> nfs3svc_decode_readdirplusargs().
>
> But I don't think this test should be needed.  svc_alloc_arg() NULL-
> terminates the ->rq_pages array which ->rq_next_page points in to.
>
> So I think this test is correct as it stands, but
> nfs4svc_decode_readdirargs() needs to be fixed.

Agreed. If we set the page pointers right. These checks wont be necessary.

>
> >               /* temporarily encode entry into next page, then move back to
> >                * current and next page in rq_respages[] */
> >               __be32 *p1, *tmp;
> >               int len1, len2;
> > +             caddr_t tmp_page_addr = NULL;
> >
> >               /* grab next page for temporary storage of entry */
> >               p1 = tmp = page_address(*(page+1));
> > @@ -977,7 +979,8 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
> >
> >               /* determine entry word length and lengths to go in pages */
> >               num_entry_words = p1 - tmp;
> > -             len1 = curr_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;
> > +             tmp_page_addr = (caddr_t)((unsigned long)cd->buffer & PAGE_MASK);
> > +             len1 = tmp_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;
>
> I think tmp_page_addr will always be the same as curr_page_addr.
> At least, it will when nfs4svc_decode_readdirargs() is fixed.
>
> Could you please revert the changed you've made to nfs3xdr.c (keeping
> the change to nfsd3_proc_readdir()), and fix nfs4svc_decode_readdirargs
> to be more like nfs4svc_decode_readdirplusargs, and see if that fixed
> the problem?

Sure. A quick test on 3000 files passed. I'll post v2 if test on
30,000 files pass.

Thanks very much for reviewing!
M

>
> Thanks a lot,
> NeilBrown
>
>
> >               if ((num_entry_words << 2) < len1) {
> >                       /* the actual number of words in the entry is less
> >                        * than elen and can still fit in the current page
> > @@ -1026,7 +1029,6 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
> >       cd->buffer = p;
> >       cd->common.err = nfs_ok;
> >       return 0;
> > -
> >  }
> >
> >  int
> > --
> > 2.21.0
