Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2173C6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 19:55:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B6F842081B
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 19:55:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="WXXluZ4c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6F842081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725743AbeJaEuY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 00:50:24 -0400
Received: from mail-lj1-f196.google.com ([209.85.208.196]:43174 "EHLO
        mail-lj1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725940AbeJaEuY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 00:50:24 -0400
Received: by mail-lj1-f196.google.com with SMTP id g26-v6so11332445lja.10
        for <linux-nfs@vger.kernel.org>; Tue, 30 Oct 2018 12:55:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EOkwOqssMjyafSoai3HcfYwmvF4VbvbnRJ6G5ZW4Cas=;
        b=WXXluZ4cqUIPvnFpEBcgME3yU2q3gJb3h/zbjbL7hECewLvYZSiJO9eQ5Xdg2xYU9f
         6k5JdWPzB58gz2qQVFQ+MFqymmY4E+bHFOysi6vF+/OvS5bmr+bi3DtSvy0/MZJjq1Yi
         ZiN7pEv49JmLBxWdBMNDoRKrEgNVGKkboP4e8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=EOkwOqssMjyafSoai3HcfYwmvF4VbvbnRJ6G5ZW4Cas=;
        b=aWaQAnjlebOjOx7p9BAlqZRWbR8MAMqNsotT45E77z5KzPghPKOqhzfY/Q1dxWOLb9
         1oF+wibmRw66cKHi5FDMrtWqkV3hiI6gWigzBCJThYVsD19b/HIPfBtvvmn8N7Ti/RNL
         J+IEA3wAapE9khdpGjspUNMVSypJGVuy2H+9AXxt2Ehim7VoAJIKPLWF0yz92mzOsFQA
         xmtoO3E6hbRRG/kVfbUHI1M6g1xkMvhC/SfMdGb6wo1snDFzxLa6xojYN0lvaNKrjed2
         vEryf14saTmLtmGmIc3smH2Tq4xLyH33GjsD0+IPNqVxWXL02qldSyQIPNMndnw3TMx7
         yDqg==
X-Gm-Message-State: AGRZ1gLRT3+nYTl8IfHybzddka8rvF/WeWtUT3sP4zdrwZIMDmieV1gM
        FPh3i/siz/LeEd5v2tbWaybYdOgBKKm/6A==
X-Google-Smtp-Source: AJdET5fFbzLHv+MHgcbSPls7hP3NVloOSJbxmozDvmbouMoBXrwzQEPKUXzv1gWPv+Jw097aw+CHjQ==
X-Received: by 2002:a2e:730b:: with SMTP id o11-v6mr60735ljc.67.1540929329506;
        Tue, 30 Oct 2018 12:55:29 -0700 (PDT)
Received: from mail-lf1-f46.google.com (mail-lf1-f46.google.com. [209.85.167.46])
        by smtp.gmail.com with ESMTPSA id s68-v6sm406859lfi.81.2018.10.30.12.55.28
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 12:55:28 -0700 (PDT)
Received: by mail-lf1-f46.google.com with SMTP id q6-v6so9857031lfh.9
        for <linux-nfs@vger.kernel.org>; Tue, 30 Oct 2018 12:55:28 -0700 (PDT)
X-Received: by 2002:a19:288c:: with SMTP id o134-v6mr70661lfo.124.1540929327811;
 Tue, 30 Oct 2018 12:55:27 -0700 (PDT)
MIME-Version: 1.0
References: <20181030191710.GA23042@fieldses.org>
In-Reply-To: <20181030191710.GA23042@fieldses.org>
From:   Linus Torvalds <torvalds@linux-foundation.org>
Date:   Tue, 30 Oct 2018 12:55:12 -0700
X-Gmail-Original-Message-ID: <CAHk-=wi+-POnmS41x9SKR+CB9va3ZnmRmCF8S7wNEw0QVATHXA@mail.gmail.com>
Message-ID: <CAHk-=wi+-POnmS41x9SKR+CB9va3ZnmRmCF8S7wNEw0QVATHXA@mail.gmail.com>
Subject: Re: [GIT PULL] nfsd changes for 4.20
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        jlayton@redhat.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 30, 2018 at 12:17 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> Please pull nfsd changes for 4.20:

Pulled,

                  Linus
