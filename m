Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEE63C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 06:44:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7400C206DF
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 06:44:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VhU0jXOk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726389AbfDEGo5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 02:44:57 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:43427 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725955AbfDEGo5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2019 02:44:57 -0400
Received: by mail-qt1-f195.google.com with SMTP id v32so6170670qtc.10
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2019 23:44:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=zciZwYfAgSZEVPlsy6n1Cic82vuEj/wVByg8I25YxDI=;
        b=VhU0jXOknUQnbH6+nkYvQC1O0HZe3+HowMRKBP9xA2LzmmXdCQ/P4nkhHX7zZEEvCY
         doF42XscYnuQ8v8dDuSG7uH+0ERKlyuBqSnqtfTSCNFxyWCYHtqhBIO2RRmRKXP8U1FK
         fu6TA+lBEWN6N7k4jVJuwwp76rbN0+VeV+dslURftUN1Y6s0+8kkS35HXlpFhG8Mqegj
         gpmBgxfWOclNyIc9IEuvcCUXxyXTK9WdOjMG8e+pBMC2Ome4LHNwW1BoAsTq/+FL2Vrw
         kS4RmFYIi+O7Ce24ANfFC3fbNyg+SI0soZPIvBrTiz66jIpCgsR/bFGeD8qDCujIBNH7
         RyVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to;
        bh=zciZwYfAgSZEVPlsy6n1Cic82vuEj/wVByg8I25YxDI=;
        b=VcT/XNCPA/ce4JZlQ3fedmsU+5m58E6wFF3SvsdmnbP/D4LYmkQ9TR5wFYANCmW5pC
         hX3Z88PLkLFRGOkcRosQKIy6JrKJbJ2VzHYbQs9X5qoo2VAgCAq9T/FOz7bEGpE3VXxD
         fmTEhdvTEp1/s/pBXoEJXjJEoo0gmfPFVu8HHPp1tAU5jVYgPu7PwKnrzF33BUqSa80r
         rvSvfm+9DxseL6A1OAddF+egP7tk5z7fgTu2td5cGo5MdcfVC+h3+g/1iaxPdTDB0lQD
         9Q9DT1S2bSf6W0Q4ljdOk/WUin4B2d5nCLMZemaXGzDnlYFOWLyuiC41iflrIJgHEAcX
         ANHQ==
X-Gm-Message-State: APjAAAXY6ImozMjxPW7fisiIXjaXOvc7jSSAQ6vFnJR3YRSPLpoR453g
        NtgPCHwXdAs3e+owfS1KuySRsf4uIQ1xzMMODsIXgg==
X-Google-Smtp-Source: APXvYqwKbFWw54ZGPDvwLSjbm2dwoslLV9YWrmAK6R+lFPuON8WXRlU3G9Iw696JhaKBAn62nOPQ7iYWABTmhTOJpsY=
X-Received: by 2002:ac8:21bc:: with SMTP id 57mr8891572qty.51.1554446696115;
 Thu, 04 Apr 2019 23:44:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190404065711.19763-1-jencce.kernel@gmail.com>
 <87mul5z8tk.fsf@notabene.neil.brown.name> <CADJHv_t_Cqav7Wr8dHo0kBBX3-ws0qVDcYi4HZt26Dq8jO+DGQ@mail.gmail.com>
 <CADJHv_u-F+D-p-uhJzxKTwQijZHe8wHfcyC97tjAgOO_ToJYHw@mail.gmail.com>
In-Reply-To: <CADJHv_u-F+D-p-uhJzxKTwQijZHe8wHfcyC97tjAgOO_ToJYHw@mail.gmail.com>
From:   Murphy Zhou <jencce.kernel@gmail.com>
Date:   Fri, 5 Apr 2019 14:44:44 +0800
Message-ID: <CADJHv_vFK-XxZVngFzBqJZ_7NPKi5Qtnzyg7K27XfRS-kBLBqA@mail.gmail.com>
Subject: Re: [PATCH v2] nfsd/nfsd3_proc_readdir: fix buffer count and page pointers
To:     Murphy Zhou <jencce.kernel@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

missed nfs list. resend.

On Fri, Apr 5, 2019 at 2:10 PM Murphy Zhou <jencce.kernel@gmail.com> wrote:
>
>
>
> On Fri, Apr 5, 2019 at 14:08 Murphy Zhou <jencce.kernel@gmail.com> wrote:
>>
>>
>>
>> On Fri, Apr 5, 2019 at 06:47 NeilBrown <neilb@suse.com> wrote:
>>>
>>> On Thu, Apr 04 2019, Murphy Zhou wrote:
>>>
>>> > After this commit
>>> >   f875a79 nfsd: allow nfsv3 readdir request to be larger.
>>> > nfsv3 readdir request size can be larger than PAGE_SIZE. So if the
>>> > directory been read is large enough, we can use multiple pages
>>> > in rq_respages. Update buffer count and page pointers like we do
>>> > in readdirplus to make this happen.
>>> >
>>> > Now listing a directory within 3000 files will panic because we
>>> > are counting in a wrong way and would write on random page.
>>> >
>>> > Fixes: f875a79 "nfsd: allow nfsv3 readdir request to be larger"
>>> > Signed-off-by: Murphy Zhou <jencce.kernel@gmail.com>
>>> > ---
>>> >
>>> > v2:
>>> >   fix nfs3svc_decode_readdirargs to set page pointers like decode_readdirplusargs
>>> >   do not test pointers in encode_entry as we've fixed them when decoding
>>> >
>>> >  fs/nfsd/nfs3proc.c | 17 +++++++++++++++--
>>> >  fs/nfsd/nfs3xdr.c  | 11 +++++++++--
>>> >  2 files changed, 24 insertions(+), 4 deletions(-)
>>> >
>>> > diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>>> > index 8f933e8..9bc32af 100644
>>> > --- a/fs/nfsd/nfs3proc.c
>>> > +++ b/fs/nfsd/nfs3proc.c
>>> > @@ -442,7 +442,9 @@
>>> >       struct nfsd3_readdirargs *argp = rqstp->rq_argp;
>>> >       struct nfsd3_readdirres  *resp = rqstp->rq_resp;
>>> >       __be32          nfserr;
>>> > -     int             count;
>>> > +     int             count = 0;
>>> > +     struct page     **p;
>>> > +     caddr_t         page_addr = NULL;
>>> >
>>> >       dprintk("nfsd: READDIR(3)  %s %d bytes at %d\n",
>>> >                               SVCFH_fmt(&argp->fh),
>>> > @@ -462,7 +464,18 @@
>>> >       nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie,
>>> >                                       &resp->common, nfs3svc_encode_entry);
>>> >       memcpy(resp->verf, argp->verf, 8);
>>> > -     resp->count = resp->buffer - argp->buffer;
>>> > +     count = 0;
>>>
>>> Thanks - looks good.
>>> Setting 'count' to zero a second time looks a bit clumsy, but that is a
>>> minor detail.
>
>
> Save some space in the stack :)
>
> Thanks for your review!
>
> M
>>>
>>>
>>>
>>>  Reviewed-by: NeilBrown <neilb@suse.com>
>>>
>>> Thanks,
>>> NeilBrown
>>>
>>>
>>> > +     for (p = rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
>>> > +             page_addr = page_address(*p);
>>> > +
>>> > +             if (((caddr_t)resp->buffer >= page_addr) &&
>>> > +                 ((caddr_t)resp->buffer < page_addr + PAGE_SIZE)) {
>>> > +                     count += (caddr_t)resp->buffer - page_addr;
>>> > +                     break;
>>> > +             }
>>> > +             count += PAGE_SIZE;
>>> > +     }
>>> > +     resp->count = count >> 2;
>>> >       if (resp->offset) {
>>> >               loff_t offset = argp->cookie;
>>> >
>>> > diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
>>> > index 93fea24..8d78912 100644
>>> > --- a/fs/nfsd/nfs3xdr.c
>>> > +++ b/fs/nfsd/nfs3xdr.c
>>> > @@ -573,6 +573,7 @@ void fill_post_wcc(struct svc_fh *fhp)
>>> >  nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
>>> >  {
>>> >       struct nfsd3_readdirargs *args = rqstp->rq_argp;
>>> > +     int len;
>>> >       u32 max_blocksize = svc_max_payload(rqstp);
>>> >
>>> >       p = decode_fh(p, &args->fh);
>>> > @@ -582,8 +583,14 @@ void fill_post_wcc(struct svc_fh *fhp)
>>> >       args->verf   = p; p += 2;
>>> >       args->dircount = ~0;
>>> >       args->count  = ntohl(*p++);
>>> > -     args->count  = min_t(u32, args->count, max_blocksize);
>>> > -     args->buffer = page_address(*(rqstp->rq_next_page++));
>>> > +     len = args->count  = min_t(u32, args->count, max_blocksize);
>>> > +
>>> > +     while (len > 0) {
>>> > +             struct page *p = *(rqstp->rq_next_page++);
>>> > +             if (!args->buffer)
>>> > +                     args->buffer = page_address(p);
>>> > +             len -= PAGE_SIZE;
>>> > +     }
>>> >
>>> >       return xdr_argsize_check(rqstp, p);
>>> >  }
>>> > --
>>> > 1.8.3.1
