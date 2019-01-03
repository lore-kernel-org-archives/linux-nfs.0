Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CE20C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 00:48:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4A1ED20815
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 00:48:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="RhuHIHml"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730157AbfACAs3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 19:48:29 -0500
Received: from mail-lj1-f194.google.com ([209.85.208.194]:39383 "EHLO
        mail-lj1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727043AbfACAs3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 19:48:29 -0500
Received: by mail-lj1-f194.google.com with SMTP id t9-v6so28454360ljh.6
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 16:48:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ra5YS9BBuydZHCde6XCsp4BxxA9x6dQ48RjQZDIKisE=;
        b=RhuHIHml4HC7WfxDeNYG8QPZam4Bq6QXLEb+LZRJPp2GaJZLrzne3HqkitcdJKhXSQ
         1pH0m6Y2rSqq22yn9IiRQtWCWBPVKHGbiEnKqp2opqLtl2A8yFDcS0IVGtUIrZ4XGAV8
         bH2imQwUjOchHCW68k0GKkSouv/yKo6i/JGwU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ra5YS9BBuydZHCde6XCsp4BxxA9x6dQ48RjQZDIKisE=;
        b=sv94mssNzP08oVVWajvf3SB7uky2lttHah2oBpTIT48PaMpGrGtRjuIOHL/PgNuPwJ
         lcBIfsUGca6jU8B8olIc3WOZPBzbYWAsfCiPDbXrPPRj+b7y4qOSiP54G7GP1l6k0W38
         SEeoo3BIj0FjJscElRvuHYFa0m6BKJMf0CMFBmlQKvtUQ/Hn5CzIlh1c/Kk+kyjufEmM
         j2a7ZKMbeuEt43V1jrDU6yzOKAdqGSSmJID+7wnV0Nz0QigWftINj/L83FhGjaBkPNyG
         61h+Isnf8l3a4OOcsxTrPAWEEo0F+8aDpV6BcsGbJMMMRQUb7pacrQmgLGiKHxyiDXqu
         LD2g==
X-Gm-Message-State: AJcUukc0/As+ZSMY7F4hFUItGX6Qbpwdq+ckJGUmXySAM6UiGev9zKM5
        0pcETY4jTPft1DPAkQrg7f0o7cbJILg=
X-Google-Smtp-Source: ALg8bN7JFOgaYcW7t//V5f0lG+P81MS0T+ZG5ldRySELxurvPnAnT6b2gowNJxA7anHLPsEDtNFLLQ==
X-Received: by 2002:a2e:6c04:: with SMTP id h4-v6mr24670471ljc.92.1546476506520;
        Wed, 02 Jan 2019 16:48:26 -0800 (PST)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id v19sm10452936lfe.69.2019.01.02.16.48.25
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 16:48:25 -0800 (PST)
Received: by mail-lf1-f47.google.com with SMTP id p6so22207412lfc.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 16:48:25 -0800 (PST)
X-Received: by 2002:a19:c014:: with SMTP id q20mr20833190lff.16.1546476505069;
 Wed, 02 Jan 2019 16:48:25 -0800 (PST)
MIME-Version: 1.0
References: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
In-Reply-To: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed, 2 Jan 2019 16:48:08 -0800
X-Gmail-Original-Message-ID: <CAHk-=whZkaZn1UQLad6v9vmfx8+BB3m8cvT0wcKdtg=k=FDbGw@mail.gmail.com>
Message-ID: <CAHk-=whZkaZn1UQLad6v9vmfx8+BB3m8cvT0wcKdtg=k=FDbGw@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client updates for 4.21
To:     "Schumaker, Anna" <Anna.Schumaker@netapp.com>
Cc:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 2, 2019 at 2:42 PM Schumaker, Anna
<Anna.Schumaker@netapp.com> wrote:
>
> We also were unable to track down a maintainer for Neil Brown's changes to
> the generic cred code that are prerequisites to his RPC cred cleanup patches.
> We've been asking around for several months without any response, so
> hopefully it's okay to include those patches in this pull request.

Looks ok to me, although I wonder what the semantics of cred_fscmp()
are across namespaces?

IOW, it seems potentially a bit suspicious to do cred_fscmp() if the
two creds have different namnespaces? Hmm?

Is there some reason that can't happen, or some reason it doesn't matter?

                  Linus
