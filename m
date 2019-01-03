Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7F42C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 20:53:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8382C217F5
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 20:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="J/1pEAYo"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726388AbfACUxV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 15:53:21 -0500
Received: from mail-lf1-f68.google.com ([209.85.167.68]:46297 "EHLO
        mail-lf1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726073AbfACUxV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 15:53:21 -0500
Received: by mail-lf1-f68.google.com with SMTP id y14so5115762lfg.13
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jan 2019 12:53:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mDNrvkxxd60+K6Wwm2FMQyhVxIavAJa512uq74mBQUA=;
        b=J/1pEAYoYy9n0QcxVBradL1P4NBR4Jn93gvg2ZoKIsLfcKzQNhdGEdt+zIdkExkT4U
         RZVoplZvjmjAGPwWdavkBNqpu/uKd8V/OAiQ9xuw9KgQGFT6MLJsAYFo7iFkup6ZZK8n
         fa5kPQ/5SRAGEbEPGmtu7hxgWJdXxLNh+ffis=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=mDNrvkxxd60+K6Wwm2FMQyhVxIavAJa512uq74mBQUA=;
        b=YOqQdIE08Rh6mzR0fFsToNdbq7BSnhS6/9R89We1JXk6Qp/AWZJAKxEOkmsx9HjHBD
         H3msmG6fw7aoGhWL28EJeKyUe9kVcN5P9NTnaF9h7R+7J9/RjfiejYuNa1vcDFVh7Xcs
         Qs7796BsyN2SFCjVhetEbTf8NMxAvfeutZlW60J4nXCkdxI3L/CPBUCe936xBW6wZMIW
         5DHin0jpOH+nnXbTKTheZemBGf+Tp9ohm1BVlN7Lk5s9eSMloXdLf6Vd6ZqgMjDb9efi
         TG4UB8drFfaMZ3gi3+K7Us4iLm7c/ssBbNR9uEn3tAZekYilIsJqA9sIAx+svt0OXso7
         VF8g==
X-Gm-Message-State: AA+aEWZaNyG4QXpoYUQYC0c7ufuZqk+NYGkekWVmgAUr7VABhtOCH8cb
        NGlur0BDi69ebKxZJuGDeQhNrZKRyO4=
X-Google-Smtp-Source: AFSGD/UZFe0qWdXKUD1n9SjLLhCvYomWbYlRBUl2m4tOf7JA+rwoErtwJCKUX4YRc2R70c93Aaa++g==
X-Received: by 2002:a19:5e5d:: with SMTP id z29mr23603949lfi.105.1546548797922;
        Thu, 03 Jan 2019 12:53:17 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id z15-v6sm13256023ljb.9.2019.01.03.12.53.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 12:53:17 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id c19-v6so30819909lja.5
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jan 2019 12:53:16 -0800 (PST)
X-Received: by 2002:a2e:9c7:: with SMTP id 190-v6mr20707080ljj.120.1546548796500;
 Thu, 03 Jan 2019 12:53:16 -0800 (PST)
MIME-Version: 1.0
References: <02d3ecd37f9390e7b8a7be8ec0e1cafb7fdbed26.camel@netapp.com>
 <CAHk-=whZkaZn1UQLad6v9vmfx8+BB3m8cvT0wcKdtg=k=FDbGw@mail.gmail.com>
 <87bm4yl4th.fsf@notabene.neil.brown.name> <55e9d0eb47662f2d6c308eba8b9a84fbba978ac8.camel@hammerspace.com>
In-Reply-To: <55e9d0eb47662f2d6c308eba8b9a84fbba978ac8.camel@hammerspace.com>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu, 3 Jan 2019 12:53:00 -0800
X-Gmail-Original-Message-ID: <CAHk-=whVxZ54i9uhXkWoaP+K1y4wu0J5z7d_mZ=-Zcpi5UhZww@mail.gmail.com>
Message-ID: <CAHk-=whVxZ54i9uhXkWoaP+K1y4wu0J5z7d_mZ=-Zcpi5UhZww@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client updates for 4.21
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "neilb@suse.com" <neilb@suse.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 2, 2019 at 10:10 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> The values being compared are in cred_fscmp() are all of type kuid_t or
> kgid_t so that means they have already been mapped from the user
> namespace into the kernel uid/gid space.

Ok, "everything happens in init_ns" is I guess a very valid argument.

It might be good to perhaps show that in the name (and maybe even a
comment), but as long as it's only really used for nfs I guess it
isn't a big deal.

Thanks,

             Linus
