Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE43AC32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:35:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8845A2081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 16:35:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rhKcUJuF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8845A2081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726700AbeKCBnV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 21:43:21 -0400
Received: from mail-ua1-f65.google.com ([209.85.222.65]:44601 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726098AbeKCBnV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 21:43:21 -0400
Received: by mail-ua1-f65.google.com with SMTP id i30so858474uae.11
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 09:35:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oZp6zLLCTRIhcugxphywpn5okdQWxkII8Atjv9182vc=;
        b=rhKcUJuF63miFLRWa4SkqKvgR37iFUbVxqbVzgn6YbRHdLNwGWnS3qG7IpvmpicPN5
         toplQVFsHs0GZW/wHfi/yFdqHlEy7SViFCTgf1xrNehw1asJ2E7B9/icpdYjnRMJF0r7
         wwYsKb/1EyvcONt7kCYXUMEL4kQR8MY3ISBzXNlfGQkTtJJBbGWcKDU9qI+N/nX7G1Ag
         oFpeWcdtg2d5YI6mJdZu897cywqCCQwiJ4A+EKM1lX16Vzr+ap6MGqH8oIVvbyIV4Xbd
         3HPo6A7WiUlQRk5mt63et4RVxSTgV4SfR9iQ3ZqeyuJlzlXSy+PwCvQpXrcPeVDjIDB7
         6l+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=oZp6zLLCTRIhcugxphywpn5okdQWxkII8Atjv9182vc=;
        b=jP8l9AVVBqoGHQY5MEkVGt932xxdJOskPuAJaRJjCYyQedupnOwMuB3jxW0QloWDE9
         +toZY10w1bxyvjlvgtAp8UW2zNl34Mpu+7T3IwFjpcqaf3o5Uhu8gUmSqpN78eksJFao
         0+3q5bygsrCg/ofktjHI8+zYrceNGABWbqVUNkLlqhLeyRMbFp+0tNoXVgBYCM0ELQt9
         f5/iczVnatt3tHeoA6LBGiLZd5VGQsJq930GLgh3UOVRU+9ckH3gYtBdtWjhtDxlLHPt
         k1ucTV66ROXucfWJbkoqnpNvjQA4PKlgCRt6P0FT4QRTxCU8Bl/KF6nosm2mygrbn0XH
         foag==
X-Gm-Message-State: AGRZ1gLENrlBOYhKd87vGWeFbETFkQxQqb9+iS+9qcuw041aJAUBTY0Q
        3YPfL4vGKmThhvRRNMkUNleSvZk6qw/vJjUbypFTAQ==
X-Google-Smtp-Source: AJdET5evWCjxXNrTwgyktHSl8tQVpKt2YV30S+E5gkkY3dEXKFAP89tgPE2JsMJMNILj1wJUE04Oig04DG6tQM3LTjA=
X-Received: by 2002:ab0:60da:: with SMTP id g26mr162340uam.104.1541176538146;
 Fri, 02 Nov 2018 09:35:38 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-8-olga.kornievskaia@gmail.com> <20181102154623.GA20367@fieldses.org>
In-Reply-To: <20181102154623.GA20367@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 2 Nov 2018 12:35:26 -0400
Message-ID: <CAN-5tyGkz=hHJzQRwBZQgAuGTWq9KLdDreoBoyvWVYQPRLTM0w@mail.gmail.com>
Subject: Re: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 2, 2018 at 11:46 AM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:28:59AM -0400, Olga Kornievskaia wrote:
> > @@ -4273,6 +4337,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
> >       p = xdr_reserve_space(&resp->xdr, 4 + 4);
> >       *p++ = xdr_one; /* cr_consecutive */
> >       *p++ = cpu_to_be32(copy->cp_synchronous);
> > +
> > +     /* allocated in nfsd4_decode_copy */
> > +     kfree(copy->cp_src);
>
> This can result in a leak--for example, if we decode the compound
> succesfully, but processing fails before we could to this op, then we'll
> never call this encoder, so we'll allocate without freeing.
>
> I think simplest would be to replace this:
>
> > diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> > index feeb6d4..b4d1140 100644
> > --- a/fs/nfsd/xdr4.h
> > +++ b/fs/nfsd/xdr4.h
> > @@ -521,6 +521,7 @@ struct nfsd4_copy {
> >       u64             cp_src_pos;
> >       u64             cp_dst_pos;
> >       u64             cp_count;
> > +     struct nl4_server *cp_src;
>
> by just a
>
>         struct nl4_server cp_src;
>
> since it sounds like you really only need one of them, not a whole array
> (at least for now).

So this is problematic as the presence of this memory is what is used
to distinguish "inter" from "intra".

Can things really fail between the xdr and calling of the operation?

What gets freed in the encoder is the "copy" of the what was decoded
in the decoder. But really freeing in the encoder is the wrong place.
Encoder doesn't need to free. I already free the "copy" of the
copy->cp_src in the cleanup_async_copy(). However, what is missing is
freeing the original copy->cp_src which needs to be freed in the
dup_copy_fields().

To clarify:
copy->cp_src gets allocated in the decoder
during the process of the copy:
1. it gets copied to the kthread and the original copy->cp_src needs
to be freed. Or during any error it will be freed.
2. cleanup_async_copy frees the copy of the copy->cp_src.
(need to remove the kfree from the encoder).

>
> --b.
>
> >
> >       /* both */
> >       bool            cp_synchronous;
> > --
> > 1.8.3.1
