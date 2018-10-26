Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 684E7C6786E
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 16:02:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1BB912085B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 16:02:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="UTN6b7hC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BB912085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=umich.edu
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726373AbeJ0Ajo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 20:39:44 -0400
Received: from mail-vs1-f50.google.com ([209.85.217.50]:44390 "EHLO
        mail-vs1-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726159AbeJ0Ajo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 20:39:44 -0400
Received: by mail-vs1-f50.google.com with SMTP id w194so1103491vsc.11
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 09:02:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=d9k3l9L2e6c+aDAViL2DDqF1tGgpTJA1u7Ii5jiQfSc=;
        b=UTN6b7hC8BlLpxj3P2/9M7xfh+D7rU/TXobqCWuk7YmsqFpxUiiTgTmwAhH+08rwIj
         XGbWBYFGI5hkWx1Wio7gS/aZj6Z9uSt1SNu4xGvRfZ0Dk8Nl4X3LWiVnataKP2hMYKrG
         RW3rvD8bMhGEr7RsRDvCpCSVJ+H1e42DG4D7wSsICH/C4k20c4JIOWluJekKZXMTahV+
         dAL2A0jU5H/PjAG+91kgCAxp+tMO7cQqLdbMQc40bJt0ZTf4Qei0ZAPCDnX3HKWOAqTp
         TWP0SLixJtT3EKlhVJ70FxHT4isdVkIkEKJ16tKfErSx86ozr4pbtjP+ijxwXIQD0YoS
         pnBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=d9k3l9L2e6c+aDAViL2DDqF1tGgpTJA1u7Ii5jiQfSc=;
        b=fh5LdBolRUPCMRN2Y9Buz3UEpb6E0AO1xJpWgMxupdcQyyfxEmbrPKqrTugPO/3cga
         g3hzh94sJl9wxXS+0ApmyQCgD2aP+qO+Y2215oUpfvff1IVQ8gbm+E0lPOPyLgo7GQNX
         wwo3qV9V7FBb8UEG8nvIRChND/oBVFrtBC/y4iOYdB08YZqlLjB4NhNVkX96JDmF3VUL
         CPkM98+SwukTw7GHK3wiqChvrZdHT6/zBGP8N7OcXarKAzhEY2oByzKRhJYLFVvy/kW5
         3w/QrICv6MkHD4ebbr5xDZ1uITwY2f+bJKVQZIP0qrMQlV10GOUSup+fpRz6Lm1iH/GS
         4anA==
X-Gm-Message-State: AGRZ1gIOGyDlZqUH9DP9IuUhDRPYbZRwAtSo0TQ5dLnpwOVCip+rn0AH
        lqhnmQt+F3esV052wTW68avh4dz9B6FW03Mf8eE=
X-Google-Smtp-Source: AJdET5fkrmIZK6TFcNk30h5zSfeewoUXWhzzSY5wEX4foaFRHCYlfrgTjyJuJymDeKjJFJd9dp8la7dTjde29YA8bcs=
X-Received: by 2002:a67:ca9d:: with SMTP id a29mr1781382vsl.194.1540569727055;
 Fri, 26 Oct 2018 09:02:07 -0700 (PDT)
MIME-Version: 1.0
References: <CAN-5tyEn+mM8ucuPXawN9L57XyGHUQHNL6Ddic5TFdXYTY2bSg@mail.gmail.com>
 <6CA0FBE4-6B7C-4D05-BE1E-AB3BEDD90171@oracle.com> <CAN-5tyE25JYUbnhvRD32_ZxyALdXd+emy2qK315DeXb+DgLn1Q@mail.gmail.com>
 <E2EE0769-0ED0-407B-B3EE-F22F58AD458F@oracle.com>
In-Reply-To: <E2EE0769-0ED0-407B-B3EE-F22F58AD458F@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 26 Oct 2018 12:01:55 -0400
Message-ID: <CAN-5tyGq2S9EvUFWGJDC+YZhd-WXN7_gpA71fce49MaF8no0bw@mail.gmail.com>
Subject: Re: copy offload support and absent file system
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 11:44 AM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Oct 26, 2018, at 11:39 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > On Fri, Oct 26, 2018 at 11:04 AM Chuck Lever <chuck.lever@oracle.com> wrote:
> >>
> >>
> >>
> >>> On Oct 26, 2018, at 8:54 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >>>
> >>> Hi Chuck,
> >>>
> >>> In the context of doing a copy between different "types" of
> >>> filesystems, it was pointed out to me that NFS has many types:
> >>> nfs4_fs_type, nfs4_remote_fs_type, nfs4_remote_referral_fs_type,
> >>> nfs4_referral_fs_type. So doing a simple check that fs type of "in"
> >>> and "out" might not be sufficient. Do you see any issues allowing a
> >>> copy offload between different types? Basically checking that "in" and
> >>> "out" descriptions come from any of the these types?
> >>
> >> I'm no expert... so what follows is an uninformed opinion.
> >
> > I was wondering if there was anything different about the
> > migrated/replicated filesystem that maybe say they are typically
> > read-only and thus doing a copy there wouldn't be appropriate. But it
> > sounds like you don't see anything special about doing a copy from
> > nfs4_fs_type to say nfs_remote_fs_type?
>
> If I recall correctly the distinction between these "types" is
> the way they are attached to the client's filesystem namespace.
> I don't believe that would have any impact on whether copy
> offload is supported or not.
>
>
> >> All of these are NFSv4 file systems. But I don't think that's an
> >> adequate check (it's necessary, but not sufficient).
> >
> >
> >> The minor version of the mount point has to be 2 or higher, and
> >> the client must confirm that the mounted server supports copy
> >> offload (because all NFSv4.2 features are OPTIONAL).
> >
> > I agree that we should check for 4.2 versioning but the latter I don't
> > think is necessary, as the COPY call will just gets not supported
> > error (we already have the capability check for CAP_COPY inside of
> > nfs42_proc_copy , just in case we already sent one copy and then
> > negated the capabilities).
>
> The COPY call could also return EROFS if the destination filesystem
> is a read-only replica.

In such case, I would hope that the OPEN of the destination file for
writing would fail and we won't even get to the COPY.

>
> --
> Chuck Lever
>
>
>
