Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E433C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 17:05:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0CBEC2081B
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 17:05:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fIBo/3lQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CBEC2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726828AbeKCCM4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 22:12:56 -0400
Received: from mail-vk1-f196.google.com ([209.85.221.196]:33870 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726700AbeKCCM4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 22:12:56 -0400
Received: by mail-vk1-f196.google.com with SMTP id y14so585293vkd.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 10:05:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tniKusJZ8iX7sEBks2ZQF/bT3G3N+tZd4RjGWYYgYps=;
        b=fIBo/3lQa4d+AhXP8JZLqMGis63nHPmzIbAMtvG/mi+LpA1tsBmlOpuqsHnEHJ7rCP
         fNKCfICEhlGeLxhI3edWrAL76yJGTals4MGtQsQ+9tnm2It6uO6PcyJ/PzXXnwPX2iSo
         j170T4yXTeG2dtpYbKeA23P8tC0MnYnBrrOL0Q/ZP+3DZ7+gWnlObhY6hIE5SSdtbxh0
         R2+tisQ44RAlp5q4pDRhoAOztf2cpjm1mDfVyiVHbzCyLvHcVrUt5bitG2s5vD/HjvG9
         Xdz/Sbsl8fDqsBhSz9z7HavnQBYC9ir/wWrKb7/DzAye63rbrFMnvuu/+qLUlMldBfhc
         zU6w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=tniKusJZ8iX7sEBks2ZQF/bT3G3N+tZd4RjGWYYgYps=;
        b=D37tsoUvx6y46FYL9u+8bfAlNT/7x9b8vKhXrhwQVDLCSKZcGoqEVInJo9XjZk2t/8
         pqy5uESVOWakv3St8mcdJS0PwP/o8RXn5WNmRxoCTQ+PtBEZjkDsM2vxbGHZik3WADMJ
         ceHIknVx91HG0IIay3QaiFfrWQ0vltC7v+DS8fYHnfpVUt/qLBXjojvH5w8YdaaDHUD+
         S4eSthuUzmtENMoKkh9rPp5ovQydusOpDHCaNqhSNN1FBg58h/zXwNZK4po6gtsQoQ79
         XIXo/BYeHLYkRoL+lXBbW0n5pBZy+NB7gjKMtAtMzZPIHrdxeKb9XXYp4DmD29eMHIcc
         5x0Q==
X-Gm-Message-State: AGRZ1gLyYg6F85vcF7aYpO/yxNk24UaVHgGWf3NrXuUTaBnNTl2oGRap
        BvZeeUmMsS3Oy/o5k6KvWMV27FfpRYKj9KE7g34=
X-Google-Smtp-Source: AJdET5c7zS1hFm7vkSjVeDJ0XfqbZVnz9Vm/i/AG0zWVUIxBqglEEOJFNO9GRCX24uS0ejWANlZF3uJsXI9m33Jxhbk=
X-Received: by 2002:a1f:ac4:: with SMTP id 187mr5369446vkk.31.1541178306149;
 Fri, 02 Nov 2018 10:05:06 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-8-olga.kornievskaia@gmail.com> <20181102154623.GA20367@fieldses.org>
 <CAN-5tyGkz=hHJzQRwBZQgAuGTWq9KLdDreoBoyvWVYQPRLTM0w@mail.gmail.com> <20181102164924.GB20367@fieldses.org>
In-Reply-To: <20181102164924.GB20367@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 2 Nov 2018 13:04:54 -0400
Message-ID: <CAN-5tyELP7O-F4CTsQMzia0pL4iQpACGyMBqpEn3K7wFBzE17A@mail.gmail.com>
Subject: Re: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 2, 2018 at 12:49 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Nov 02, 2018 at 12:35:26PM -0400, Olga Kornievskaia wrote:
> > On Fri, Nov 2, 2018 at 11:46 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > On Fri, Oct 19, 2018 at 11:28:59AM -0400, Olga Kornievskaia wrote:
> > > > @@ -4273,6 +4337,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
> > > >       p = xdr_reserve_space(&resp->xdr, 4 + 4);
> > > >       *p++ = xdr_one; /* cr_consecutive */
> > > >       *p++ = cpu_to_be32(copy->cp_synchronous);
> > > > +
> > > > +     /* allocated in nfsd4_decode_copy */
> > > > +     kfree(copy->cp_src);
> > >
> > > This can result in a leak--for example, if we decode the compound
> > > succesfully, but processing fails before we could to this op, then we'll
> > > never call this encoder, so we'll allocate without freeing.
> > >
> > > I think simplest would be to replace this:
> > >
> > > > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > > > index feeb6d4..b4d1140 100644
> > > > --- a/fs/nfsd/xdr4.h
> > > > +++ b/fs/nfsd/xdr4.h
> > > > @@ -521,6 +521,7 @@ struct nfsd4_copy {
> > > >       u64             cp_src_pos;
> > > >       u64             cp_dst_pos;
> > > >       u64             cp_count;
> > > > +     struct nl4_server *cp_src;
> > >
> > > by just a
> > >
> > >         struct nl4_server cp_src;
> > >
> > > since it sounds like you really only need one of them, not a whole array
> > > (at least for now).
> >
> > So this is problematic as the presence of this memory is what is used
> > to distinguish "inter" from "intra".
>
> It would be easy enough to add a new bit for that.
>
> > Can things really fail between the xdr and calling of the operation?
>
> Yes.  Consider a PUTFH+SAVEFH+COPY compound.  We decode the whole thing
> before starting any processing.  Then we call nfsd4_putfh() and
> fh_verify fails (maybe the filehandle is stale or something).  Then
> neither nfsd4_copy() nor nfsd4_encode_copy() will be called.
>
> If you absolutely have to do this, you can look at SAVEMEM.

Using a new bit is good enough for me.

>
> --b.
>
> > What gets freed in the encoder is the "copy" of the what was decoded
> > in the decoder. But really freeing in the encoder is the wrong place.
> > Encoder doesn't need to free. I already free the "copy" of the
> > copy->cp_src in the cleanup_async_copy(). However, what is missing is
> > freeing the original copy->cp_src which needs to be freed in the
> > dup_copy_fields().
> >
> > To clarify:
> > copy->cp_src gets allocated in the decoder
> > during the process of the copy:
> > 1. it gets copied to the kthread and the original copy->cp_src needs
> > to be freed. Or during any error it will be freed.
> > 2. cleanup_async_copy frees the copy of the copy->cp_src.
> > (need to remove the kfree from the encoder).
> >
> > >
> > > --b.
> > >
> > > >
> > > >       /* both */
> > > >       bool            cp_synchronous;
> > > > --
> > > > 1.8.3.1
