Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CBF2C6786F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 19:05:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E7F12081F
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 19:05:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aIwdHTic"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E7F12081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726550AbeKCENl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 00:13:41 -0400
Received: from mail-vs1-f65.google.com ([209.85.217.65]:45227 "EHLO
        mail-vs1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725728AbeKCENl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Nov 2018 00:13:41 -0400
Received: by mail-vs1-f65.google.com with SMTP id 124so1640983vsp.12;
        Fri, 02 Nov 2018 12:05:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:reply-to:from:date:message-id
         :subject:to:cc:content-transfer-encoding;
        bh=fYuc9J1mOgr8qcO/jB9bzEyIPj80WOt3QRdzgDlj1Cc=;
        b=aIwdHTicGczkeFmu7La5nq9+wvszHabv5OC8tEwQG0QrXQVizKMffb5mMci0I0+Ybe
         55i1SphkvN+M324n6YgpVKJXa4yAaAfMA4C9HE0dr8vk6xYQKvVE1cOrNIn0B1uOlUB6
         PYlmQZ0H8fHZJ6nD8ebuJjcQqTS6lHSoWUbiDyWltDtCW2W9YdMQJPyLa++tjz8JqHqq
         i5V7JF8ugSOsVuCU+S6QsywtAo9tAOAqyqgmD6JVRXWpL0uW/aQ3GzU7g7ydHnWesYaK
         dKXjk0SI/CdipyIsq3jsHhkYJ1xocaeCCYO/rfAWgSQhbg6K+2MR5GxfrhvUl0urr+zs
         O8Tw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:reply-to
         :from:date:message-id:subject:to:cc:content-transfer-encoding;
        bh=fYuc9J1mOgr8qcO/jB9bzEyIPj80WOt3QRdzgDlj1Cc=;
        b=e88uZDHByO9QoPKbef5y3fLCDv+R8hUeewWdhuoH+FyL25KszZM3hJi8POHaaP0DhO
         iDAhx+TbAKkJ30Q5YkSxyUc6vrxoslvEcLHCiyKTSnxYzeosY/2PVX2Br4YXiO9+h492
         ORUXLtg9fbuA/bFTFONvVfBig2lbMXfxBZc6sOcqkjKhljs+s9ZNA2D96Tmlu9wHAynS
         v7Z0m2j5dRkH5YluFmVrCkoi/u7dgoazy+Y8bK6iVWGvdFQMpwBmo0Ys643c2CC++gud
         0PrT19z0FxVzKVvBc8hq81jT5nHW8ewsyBnkbzj2/Vc/3pHOICs06fLoiTLnUdgKj9QR
         /ktQ==
X-Gm-Message-State: AGRZ1gLDizT+OwrjK3/MP0xID98Xsl5LkE968G5E5gX03Dhax2xJ1h+x
        biTZtWR6CqQsXWSbiJ/fRjrTe5jduBex+ax8WwQ=
X-Google-Smtp-Source: AJdET5cmDin0noFLzumLkJ+Dqpm69berRQuFl/a2tbvybGc7Z4DBzItHnRUJgGdt3Hqmd9d/Ab1rcdBL+/i1sX26/IQ=
X-Received: by 2002:a67:8a88:: with SMTP id m130mr5570530vsd.206.1541185520354;
 Fri, 02 Nov 2018 12:05:20 -0700 (PDT)
MIME-Version: 1.0
References: <153923113649.5546.9840926895953408273.stgit@magnolia>
 <153923117420.5546.13317703807467393934.stgit@magnolia> <CAL3q7H7mLvCGpyitJhQ=To-aDvG9k9rxSVi2jSpcALQVj3myzg@mail.gmail.com>
 <20181015003139.GZ6311@dastard> <CAL3q7H5ofBmjh0DmbPH6Rmm523JV9byuBiYj=Jxpc44Kbh+Haw@mail.gmail.com>
 <20181102174229.GA4127@magnolia> <CAL3q7H4MaphXQYnn3rRvc3YQZtiBBq1z61c91-LdNZZVzzLWJg@mail.gmail.com>
In-Reply-To: <CAL3q7H4MaphXQYnn3rRvc3YQZtiBBq1z61c91-LdNZZVzzLWJg@mail.gmail.com>
Reply-To: fdmanana@gmail.com
From:   Filipe Manana <fdmanana@gmail.com>
Date:   Fri, 2 Nov 2018 19:05:09 +0000
Message-ID: <CAL3q7H4mMUqpVr=N5a=ChPBDGNy95VRzfSPX-oB5rzm0yshofQ@mail.gmail.com>
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

On Fri, Nov 2, 2018 at 6:18 PM Filipe Manana <fdmanana@gmail.com> wrote:
>
> On Fri, Nov 2, 2018 at 5:42 PM Darrick J. Wong <darrick.wong@oracle.com> =
wrote:
> >
> > On Fri, Nov 02, 2018 at 12:04:39PM +0000, Filipe Manana wrote:
> > > On Mon, Oct 15, 2018 at 1:31 AM Dave Chinner <david@fromorbit.com> wr=
ote:
> > > >
> > > > On Fri, Oct 12, 2018 at 09:22:18PM +0100, Filipe Manana wrote:
> > > > > On Thu, Oct 11, 2018 at 5:13 AM Darrick J. Wong <darrick.wong@ora=
cle.com> wrote:
> > > > > >
> > > > > > From: Darrick J. Wong <darrick.wong@oracle.com>
> > > > > >
> > > > > > A deduplication data corruption is exposed by fstests generic/5=
05 on
> > > > > > XFS.
> > > > >
> > > > > (and btrfs)
> > > > >
> > > > > Btw, the generic test I wrote was indeed numbered 505, however it=
 was
> > > > > never committed and there's now a generic/505 which has nothing t=
o do
> > > > > with deduplication.
> > > > > So you should update the changelog to avoid confusion.
> > > >
> > > > What test is it now? And if it hasn't been committed, are you going
> > > > to update it and repost as it clearly had value....
> > >
> > > Sorry, I lost track of this.
> > >
> > > So what was the conclusion of the thread where discussion about this
> > > problem started?
> > > It wasn't clear to me if a consensus was reached and got lost on that
> > > long user space dedupe tools discussion between you and Zygo.
> > >
> > > The test assumed a fix of rounding down the range and deduping less
> > > bytes then requested (which ended up included in 4.19 for btrfs).
> > >
> > > From this vfs patch it seems it was decided to return errno -EDADE in=
stead.
> > > Is this the final decision?
> >
> > No, I reworked the whole mess to match btrfs-4.19 behavior of deduping
> > fewer bytes than requested.
>
> What about cloning?
> For cloning the issue is still not fixed in btrfs either.
>
> So was that done in a later version of this patchset or somewhere else?

Never mind, found it, it returns -EINVAL.

>
> thanks
>
> >
> > --D
> >
> > > >
> > > > Cheers,
> > > >
> > > > Dave.
> > > > --
> > > > Dave Chinner
> > > > david@fromorbit.com
> > >
> > >
> > >
> > > --
> > > Filipe David Manana,
> > >
> > > =E2=80=9CWhether you think you can, or you think you can't =E2=80=94 =
you're right.=E2=80=9D
>
>
>
> --
> Filipe David Manana,
>
> =E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you'=
re right.=E2=80=9D



--=20
Filipe David Manana,

=E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you're=
 right.=E2=80=9D
