Return-Path: <SRS0=jFnA=NP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA78FC32789
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Nov 2018 16:22:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6F4862082A
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Nov 2018 16:22:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="FIbzEfqb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F4862082A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731793AbeKEBhZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 4 Nov 2018 20:37:25 -0500
Received: from mail-lf1-f68.google.com ([209.85.167.68]:34135 "EHLO
        mail-lf1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731776AbeKEBhZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Nov 2018 20:37:25 -0500
Received: by mail-lf1-f68.google.com with SMTP id n26-v6so4432130lfl.1
        for <linux-nfs@vger.kernel.org>; Sun, 04 Nov 2018 08:21:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=TjJo6boeBa728v+iSfi+lNuHrxjPuo1AxeIaYriCncQ=;
        b=FIbzEfqbrNA9nScDmPZhue2VY+s2LUeCNsZ/ndxy4TI1DJHSDN4ZnquqCWRZhLjfOz
         JaPJ1aMXR29m+XGwgdHQ37NDgPW77pQdT/1XSQGrYwVCOUJCzE11oyl/P+2wusRLOgw5
         z2/I7gJFfYKGF7VWqRZHsarkYv+40wchrIAaU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=TjJo6boeBa728v+iSfi+lNuHrxjPuo1AxeIaYriCncQ=;
        b=KeR8tpKC7zYtwQ0il5yx5exQxovr2WQElZNgSzNxi6+biiES177B93HZZWTtB7vY4n
         vL+g4PiYLMH2PObu8TUQhUKqJyu6iiEy2M5ZQpybGrt8HBKEYPTpVwgQosbtTDmnilbz
         vRvDkqnq0kS/z26uePG45djAaMEtFWN0vPVLKDHwATVanc/1Vgt2PSBkm/1NjGYmpEW4
         FFGg2babAM2MehTUhRSEl5vXZ6prMtC9pC6vbVO95z3fYr1DuYxrhWSzsxg9N7r/cmmY
         QZ2FQqve/yFxVAurzd/FLugl4kRE45MWNCKWNwkBqMALTIxceC7qOmOFT7mg4LK+cRrW
         bGWQ==
X-Gm-Message-State: AGRZ1gKOJC/WAdlLOPhjtNOa9QR6pHobXJScd6Ezuvrci3g7IHKsonxS
        ZJNB83GEUOwfKdZN7xArWzSIJBKFJDI=
X-Google-Smtp-Source: AJdET5fC2Bka69VHYOv9TNJuCH4Govs49xImAceN/hmzVmcjruZuRHl9HEIosbGcK1/1QIGkDmGIwQ==
X-Received: by 2002:a19:1f46:: with SMTP id f67mr10266266lff.1.1541348513398;
        Sun, 04 Nov 2018 08:21:53 -0800 (PST)
Received: from mail-lj1-f180.google.com (mail-lj1-f180.google.com. [209.85.208.180])
        by smtp.gmail.com with ESMTPSA id x16sm3561576lff.26.2018.11.04.08.21.52
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 08:21:52 -0800 (PST)
Received: by mail-lj1-f180.google.com with SMTP id t22-v6so5810061lji.7
        for <linux-nfs@vger.kernel.org>; Sun, 04 Nov 2018 08:21:52 -0800 (PST)
X-Received: by 2002:a2e:95c6:: with SMTP id y6-v6mr1745136ljh.59.1541348511645;
 Sun, 04 Nov 2018 08:21:51 -0800 (PST)
MIME-Version: 1.0
References: <9d585276a55d788b98ba425910cd4a05a9e5cf99.camel@hammerspace.com>
In-Reply-To: <9d585276a55d788b98ba425910cd4a05a9e5cf99.camel@hammerspace.com>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sun, 4 Nov 2018 08:21:35 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiZk7D66JYh9-2XAypcTJuKs-qOJ_xGQpkvNoaLWoy+Zg@mail.gmail.com>
Message-ID: <CAHk-=wiZk7D66JYh9-2XAypcTJuKs-qOJ_xGQpkvNoaLWoy+Zg@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfix for 4.20
To:     trondmy@hammerspace.com
Cc:     Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, Nov 4, 2018 at 5:56 AM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> NFS client bugfixes for Linux 4.20

Pulled,

                          Linus
