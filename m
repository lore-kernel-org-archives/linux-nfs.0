Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 746EFC32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 18:19:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 41F4B2081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 18:19:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Qznq7+1C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41F4B2081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727465AbeKCD1E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 23:27:04 -0400
Received: from mail-vk1-f195.google.com ([209.85.221.195]:37410 "EHLO
        mail-vk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725816AbeKCD1E (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 23:27:04 -0400
Received: by mail-vk1-f195.google.com with SMTP id 197so631417vkf.4;
        Fri, 02 Nov 2018 11:18:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:reply-to:from:date:message-id
         :subject:to:cc:content-transfer-encoding;
        bh=/7rE/ECgl43iYTRdC9hyCk945p5pZ4IfWe2Zj/V96qc=;
        b=Qznq7+1CQ1I/YjruDpm7cvEMFZv0H3pfjUsTToinIyvmPPVGoBMghSdJz1WNUDNsos
         3YpXDkLFaI7w2epfDYTBG9pLYKl24Js1ER5iP5Pw8qjFLSUqoQtvCh68t9St4WvRCw5j
         Vz5EDEsutA9Uu+ny0SIMPRpv7APXq2KOTWMjfmEL7z7dJhSL+3HB8bOHERnT7F5NDxKw
         uNYlvG+P64XVQJ9VXuLTs2W4wr4t7J1d+oGEO6mnLBLcg+RcJLNampmFKCKL6tfWmS17
         4qDNUWw1cjAA0Ys+HJpjfgbXhgaDQKShkb7aAMMyigRMcpxagNZLgES/Pgq9067FPrdx
         2J1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:reply-to
         :from:date:message-id:subject:to:cc:content-transfer-encoding;
        bh=/7rE/ECgl43iYTRdC9hyCk945p5pZ4IfWe2Zj/V96qc=;
        b=LXB2rm3jcLCoyRicAAK5TCsuy5p5Cm+F1PoGhwo9S85xzpg39/pket/K7Axt7Dz/Mb
         vQeZOu1AfnQ7OSGUgNr14bBd27fPu2Q97JCtJVrmKoj8Kl8z6ek2msumFm4DSvk9x6nR
         oA4wiiQN0oVrbKdH50AHINiBPol8kEO3UVLDtTtZxkGTM+Xe16TciiWK0nzznaF7ARgT
         VSTUxpKbauvfQ3H4plsjMYgtsmeSqMtiQDb9YqbOAIWi/CFC3wMg7s1WPSqFvfvqJTCD
         lSX2eTA7RcjKZ6jxxQxqS1obfNIhcOFFkgJQ/RJ6YCDAVtvk/RAiqdZhuOuB4j/ec1kl
         SUqg==
X-Gm-Message-State: AGRZ1gKULCke39CXBUN84C1upMvqCYWaVR/MZFh8iVAu/6fiVg+r0+36
        p6GrjvKCB1Sh3D/k4ICJoB17Iy1x3DCUUXD0Ug/8kw==
X-Google-Smtp-Source: AJdET5dKPnuy8Z+PXLHGLAFzrp/6mJLCzcyR5hJbZ4l9XDjFmTks7oTXhJYoQERREnrIt1ZRILvONMSCcWa/wcLvsHA=
X-Received: by 2002:a1f:a543:: with SMTP id o64mr5381613vke.23.1541182737427;
 Fri, 02 Nov 2018 11:18:57 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia> <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
 <20181015003139.GZ6311@dastard> <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
 <20181102174229.GA4127@magnolia>
In-Reply-To: <20181102174229.GA4127@magnolia>
Reply-To: fdmanana@gmail.com
From:   Filipe Manana <fdmanana@gmail.com>
Date:   Fri, 2 Nov 2018 18:18:45 +0000
Message-ID: <CAL3q7H4MaphXQYnn3rRvc3YQZtiBBq1z61c91-LdNZZVzzLWJg@mail.gmail.com>
Subject: Re: [PATCH 05/25] vfs: avoid problematic remapping requests into
 partial EOF block
To:     "Darrick J. Wong" <darrick.wong@oracle.com>
Cc:     Dave Chinner <david@fromorbit.com>,
        Eric Sandeen <sandeen@redhat.com>, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        ocfs2-devel@oss.oracle.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 2, 2018 at 5:42 PM Darrick J. Wong <darrick.wong@oracle.com> wr=
ote:
>
> On Fri, Nov 02, 2018 at 12:04:39PM +0000, Filipe Manana wrote:
> > On Mon, Oct 15, 2018 at 1:31 AM Dave Chinner <david@fromorbit.com> wrot=
e:
> > >
> > > On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> > > > On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@oracl=
e.com> wrote:
> > > > >
> > > > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > > > >
> > > > > A deduplication data corruption is exposed by fstests generic/505=
 on
> > > > > XFS.
> > > >
> > > > (and btrfs)
> > > >
> > > > Btw, the generic test I wrote was indeed numbered 505, however it w=
as
> > > > never committed and there's now a generic/505 which has nothing to =
do
> > > > with deduplication.
> > > > So you should update the changelog to avoid confusion.
> > >
> > > What test is it now? And if it hasn't been committed, are you going
> > > to update it and repost as it clearly had value....
> >
> > Sorry, I lost track of this.
> >
> > So what was the conclusion of the thread where discussion about this
> > problem started?
> > It wasn't clear to me if a consensus was reached and got lost on that
> > long user space dedupe tools discussion between you and Zygo.
> >
> > The test assumed a fix of rounding down the range and deduping less
> > bytes then requested (which ended up included in 4.19 for btrfs).
> >
> > From this vfs patch it seems it was decided to return errno -EDADE inst=
ead.
> > Is this the final decision?
>
> No, I reworked the whole mess to match btrfs-4.19 behavior of deduping
> fewer bytes than requested.

What about cloning?
For cloning the issue is still not fixed in btrfs either.

So was that done in a later version of this patchset or somewhere else?

thanks

>
> --D
>
> > >
> > > Cheers,
> > >
> > > Dave.
> > > --
> > > Dave Chinner
> > > david@fromorbit.com
> >
> >
> >
> > --
> > Filipe David Manana,
> >
> > =E2=80=9CWhether you think you can, or you think you can't =E2=80=94 yo=
u're right.=E2=80=9D



--=20
Filipe David Manana,

=E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you're=
 right.=E2=80=9D
