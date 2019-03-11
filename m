Return-Path: <SRS0=Z4n1=RO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE696C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 11:21:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8A90F2075C
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Mar 2019 11:21:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AED/31XL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727384AbfCKLVW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Mar 2019 07:21:22 -0400
Received: from mail-lf1-f65.google.com ([209.85.167.65]:45540 "EHLO
        mail-lf1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727290AbfCKLVV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Mar 2019 07:21:21 -0400
Received: by mail-lf1-f65.google.com with SMTP id f16so3081531lfk.12
        for <linux-nfs@vger.kernel.org>; Mon, 11 Mar 2019 04:21:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+DJwYSpsAY911QTQiyeqjQHHnX7NOgtGhVF/Vy93cLE=;
        b=AED/31XL3QyhU7CppLPhkyqtjW3PCyI5bhwd/C5oDOjh755+EIQNe+tXO5a1teKzxp
         q2nAsbE7cZLsUcUpDNsmxg2Vn1+F57tbE4PtNau8rRUtxHYJUkWZzksysG8jOHxiB8Lb
         E5EW0ytMDsFbmRklOXXVsWdTrcLI0TztAtMRkb5gqajSPvt5OD/Vz9M6TMx1AieC1CN6
         UBkCIiN1NeU6Xhf92BElNg3AD15pCEGIZr0PVOrJAC2rMHp+BD6Bcf915XwWbHQrLWRF
         Pfx1u1CAs9S7x7+Z9SSEWtoi/a1tnqY6E/+O17YZjkcm1OpOO1dINV55JSJmn3kjjwOa
         feRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=+DJwYSpsAY911QTQiyeqjQHHnX7NOgtGhVF/Vy93cLE=;
        b=g68Hx2XHBOu2HhH+9UctChccLj8fjyNcikzJSfPbeBIATgjFcnEEnagpJQlot2fW0r
         yvfYo7sPFk0A9EZHr5iGyoRtm9n9YctQZvY5xSlne5dseKhhb183NWPhn4vF3ELf5wWU
         inKBl+TTt7Owh+uPA1/axLYBN61+5ehcvXB4PnIUX0SFk4GnCkCrCpjm7QiVGFWAlsv4
         cmi17d21b2AWxPbx7FWdM4ezNuETJEHjN2Tpes8TGr3CoqC+QeSn8lD+SCDLgiEP8RED
         0o04UOaqaQ+1GHM9G+MiQThaZ/UtSqWo3mBr0x9sbKvR05Np3U6FLwnrKxBuJ755jTJV
         9p9A==
X-Gm-Message-State: APjAAAUMdW3QwHEPZncIPYU7IJDyt7tBfC64stjGt481FMJMNRul/aMQ
        K/GchRN+bv8DdQ/s2TpcK8EpHWVM9RyXiK+FV0U=
X-Google-Smtp-Source: APXvYqwwa+htezKmjCjsTnF5bvYj64e7g9M1TfMvKSOE8zBs03dvLnyxQgHXqUxjPriM6tHtFH9eVVlH+Zkx3IKlqQA=
X-Received: by 2002:a19:cfd1:: with SMTP id f200mr1116456lfg.81.1552303279539;
 Mon, 11 Mar 2019 04:21:19 -0700 (PDT)
MIME-Version: 1.0
References: <CAP8UQm+od+oU63049_hgitTcBepCeG0vFBPHG90=WruVXGU_mw@mail.gmail.com>
 <CAP8UQm+gQZW5_FD5YMuh_fev0H7SAanwz92CpoA1Yyr7ooj7Hg@mail.gmail.com>
 <A469AE7A-B542-4BE7-BF1E-5EFD309DB0BB@redhat.com> <CAP8UQm+j4Rog_AK8yiOwTY_3pBbV3OwKU7KvoU2B064hmC9gWA@mail.gmail.com>
 <C235C237-B75C-4EED-B2F1-1F5E084B21CD@redhat.com> <CAP8UQm+tBWfiG4yVe=YihyOswGy00ZbXLMTcdQs-YG_M7FFRMg@mail.gmail.com>
 <2C15197B-6011-4AA9-9C38-3B2410799D8B@redhat.com>
In-Reply-To: <2C15197B-6011-4AA9-9C38-3B2410799D8B@redhat.com>
From:   Kanika <jr.kanika@gmail.com>
Date:   Mon, 11 Mar 2019 16:51:09 +0530
Message-ID: <CAP8UQm+4h9sNtbURraLC=52tDGGOBL3oEJkuSfrCpttJ2bb7-Q@mail.gmail.com>
Subject: Re: pnfs setup on Linux 4.15
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Ben,
I was just about to reply saying I found the problem. It is exactly
what you point out - I was using IET iscsi targets that does not
support PRs. The kernel log showed PR command failing with "illegal
request". Switching to LIO target fixed the problem.
Appreciate your help on the problem and thanks for answering my questions.

Thanks,
jrk

On Mon, 11 Mar 2019 at 16:21, Benjamin Coddington <bcodding@redhat.com> wrote:
>
> On 8 Mar 2019, at 2:05, Kanika wrote:
>
> > On Thu, 7 Mar 2019 at 16:42, Benjamin Coddington <bcodding@redhat.com>
> > wrote:
> >>
> >> On 7 Mar 2019, at 2:51, Kanika wrote:
> >>
> >>> Hi Benjamin,
> >>> Thanks for your reply. I suspected so but wanted to confirm. I tried
> >>> block/scsi layout as well but that isn't working either.
> >>>
> >>> Based on an old thread on this list on "how to setup pnfs for block
> >>> layout", I set up an iscsi target on the DS and the initiators on
> >>> the MDS
> >>> and client. All machines are running 4.15 kernel. Client as an iscsi
> >>> initiator but does not mount the device. MDS also an initiator with
> >>> an xfs
> >>> filesystem mounted on the device. This mount point is exported as an
> >>> nfs
> >>> share from the MDS. The client mounts the exported MDS share.
> >>> By default LAYOUT_SCSI is used but the GETDEVICEINFO call keeps
> >>> failing
> >>> with NFS4ERR_INVAL. As a result all reads/writes from the client are
> >>> routed
> >>> to the MDS instead of the DS. Anything wrong with my setup?
> >>
> >> The SCSI layout needs to work with whole SCSI devices, not
> >> partitions.
> >>
> >> Try putting your XFS on /dev/sda instead of /dev/sda1.
> >>
> >> Ben
> > Hi Ben,
> > Thanks for the pointer. I tried this but still no luck, see the same
> > error for GETDEVICEINFO. Anything else I am missing?
>
> It seems like you're hitting:
>
> nfsd4_scsi_proc_getdeviceinfo(..)
> ...
>      if (sb->s_bdev != sb->s_bdev->bd_contains)
>           return nfserr_inval;
>
> But if you're getting past that, then the MDS should be using pr_err to
> show
> something informative in the kernel log.  It's possible your SCSI
> devices
> doesn't support persistent reservations.
>
> If there's nothing informative in the log, can you show the output of
>
> sg_inq --vpd -p 0x83 /dev/sda
>
> On both the client and the MDS?
>
> Ben
