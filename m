Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58D89EB64D7
	for <linux-nfs@archiver.kernel.org>; Fri, 23 Jun 2023 22:06:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231881AbjFWWGK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 23 Jun 2023 18:06:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45276 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231622AbjFWWGK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2023 18:06:10 -0400
Received: from mail-qv1-xf2f.google.com (mail-qv1-xf2f.google.com [IPv6:2607:f8b0:4864:20::f2f])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id ED7072705;
        Fri, 23 Jun 2023 15:06:01 -0700 (PDT)
Received: by mail-qv1-xf2f.google.com with SMTP id 6a1803df08f44-6300510605bso9567476d6.0;
        Fri, 23 Jun 2023 15:06:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tavianator.com; s=google; t=1687557961; x=1690149961;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=laQGVXq6Eq5vx8huIZhgQpbdSACn2501LJRQT7hKbn4=;
        b=nWK/FT/Zwtll8ccFigrw8j6mxM/K2tAd3Ut+FCmFGIDMLrdFCi3F9p+noxHJVxJOoJ
         CKCXkb28R+v6xLHcjO/SGcE4TqnhSH83uz9GvmUSGY2yk+5FLQBqpBKCm7rC1GhdnOmB
         Km9jw57UwFSdwh4zRSoXSEjd0egNTcU5nLCs8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1687557961; x=1690149961;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=laQGVXq6Eq5vx8huIZhgQpbdSACn2501LJRQT7hKbn4=;
        b=eRoOMYuzxJ2RmhffG452tPrnE4cNxGL6lU15J43icQOXRHFntwKVAZJDoGtI+ftIA7
         zG6Efhho2PbE8e6HAOzh0iBMmCWgUYgzztoF18sqF0pHEz8OpWTXwPtviCOxXEoz0Nik
         6rJQOWQLzC1Fjcq6m+eVipb5cqbaimK4k80C6VXs3/Gw0RE2YcrDapKRN+19MYCJ7R1x
         21oo3ZnHYYwGY2bC5Q4+CGeove0e58v0p+SfqFEgal4tmdlgPCk2vQI+8oV6Tmqf3m/l
         VvbYD5pbkf1XzXoqdjAcIhBC+c6fkxtjynKUYH3YxMaD4RAKpDXYgrXZxQ/CPeYJpt4F
         eXzQ==
X-Gm-Message-State: AC+VfDw2BInEbpX/3HH+gS9xxw32y5bROGkNfDxxzVqcr3yhe5nEZug1
        4Srv+V8uautx1ghnQUkwv13UlVrb535sj9EKP0XCdr/pXH0=
X-Google-Smtp-Source: ACHHUZ4PiJ6AyhA8VaHNNIRK+KvOta/7CJyrtjL956v341EAkza3azElAiqbsziCHVErBxbuQgSIIyzddSbSbw5TtfA=
X-Received: by 2002:a05:6214:2348:b0:626:3a5a:f8dc with SMTP id
 hu8-20020a056214234800b006263a5af8dcmr30029214qvb.57.1687557960967; Fri, 23
 Jun 2023 15:06:00 -0700 (PDT)
MIME-Version: 1.0
References: <4154eb6503988c2096f5d30af26d06863fb5d973.1687554467.git.tavianator@tavianator.com>
 <ZJYTI5ws3jNhDS25@manet.1015granger.net>
In-Reply-To: <ZJYTI5ws3jNhDS25@manet.1015granger.net>
From:   Tavian Barnes <tavianator@tavianator.com>
Date:   Fri, 23 Jun 2023 18:05:50 -0400
Message-ID: <CABg4E-=-1Ppri=TpWuTCUDmn0ye3g4cQrxvC9m0DRUrnx0Hh4Q@mail.gmail.com>
Subject: Re: [PATCH] fs/nfsd: Fix creation time serialization order
To:     Chuck Lever <cel@kernel.org>
Cc:     linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Ondrej Valousek <ondrej.valousek.xm@renesas.com>,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jun 23, 2023 at 5:48=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
> On Fri, Jun 23, 2023 at 05:09:06PM -0400, tavianator@tavianator.com wrote=
:
> > From: Tavian Barnes <tavianator@tavianator.com>
> >
> > In nfsd4_encode_fattr(), TIME_CREATE was being written out after all
> > other times.  However, they should be written out in an order that
> > matches the bit flags in bmval1, which in this case are
> >
> >     #define FATTR4_WORD1_TIME_ACCESS        (1UL << 15)
> >     #define FATTR4_WORD1_TIME_CREATE        (1UL << 18)
> >     #define FATTR4_WORD1_TIME_DELTA         (1UL << 19)
> >     #define FATTR4_WORD1_TIME_METADATA      (1UL << 20)
> >     #define FATTR4_WORD1_TIME_MODIFY        (1UL << 21)
> >
> > so TIME_CREATE should come second.
> >
> > I noticed this on a FreeBSD NFSv4.2 client, which supports creation
> > times.  On this client, file times were weirdly permuted.  With this
> > patch applied on the server, times looked normal on the client.
> >
> > Fixes: e377a3e698fb ("nfsd: Add support for the birth time attribute")
> > Link: https://unix.stackexchange.com/q/749605/56202
> > Signed-off-by: Tavian Barnes <tavianator@tavianator.com>
>
> I'm not especially familiar with this area of the protocol, but this
> looks correct at first glance. I've applied this to nfsd-fixes for
> v6.5.

Great, thanks!

> Out of interest, what type of filesystem does your server export?

It's a btrfs filesystem.

--=20
Tavian Barnes
