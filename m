Return-Path: <SRS0=zNNA=XL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58329C49ED7
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Sep 2019 22:29:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1FE12214AF
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Sep 2019 22:29:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=delphix.com header.i=@delphix.com header.b="eKql6OrY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387419AbfIPW3D (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 Sep 2019 18:29:03 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:36586 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728049AbfIPW3D (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Sep 2019 18:29:03 -0400
Received: by mail-io1-f66.google.com with SMTP id b136so2919218iof.3
        for <linux-nfs@vger.kernel.org>; Mon, 16 Sep 2019 15:29:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=delphix.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to;
        bh=H0ZsSGTSv+cL7Oj6JGDCmKbMzERwb43OxPJbmdmv35w=;
        b=eKql6OrYBZhI75WY3ioLSz5CP+VrQPQFvyCjHYWznrMHqyoBAkSpdSYRiOCY9JV0tg
         0Q87iooqiRlmejo5h12KuF+pAbGZ1cVmE+T0Kw97L5P8bkQVVOSU3SCFmFtmsutNK/Os
         Pkt3riTHzAp6/PfMB0VsFyQFkvdgOwGX2w3A8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to;
        bh=H0ZsSGTSv+cL7Oj6JGDCmKbMzERwb43OxPJbmdmv35w=;
        b=OZuuKORqTVb+Pjtj6jBhQUYUGrUq6NjLiPY3dSpOtfsqS0oAwcaFDXjZcsinaOwjKK
         M9PUsPVZa8PgtnTKGWRDr4e5XBBl63g3PsUAm5ftdDgc/CGUPr1GoGugLtM+Fqsp0pEm
         0hhWUWZY4qo7Jbqe6SLIb8bU+Aa0OtoeqMC9r5WjK+0exFqlJHyw190rExgUzfDqkQxa
         N8+A3YNWq51NwyXeH1wfNZmN36PP2Q/beIXUJD4IrrM0G44Jr2DrysfTf2SIOtC/iyzv
         8QikY1RyBz1Tcrm771lYoEM8Ekq3zXpzCljUHT6aZvUL/evuo+lcWJ/GQE6kYgQxfkxo
         PKbw==
X-Gm-Message-State: APjAAAWkCuJABLd0WVnK5RKIsBfBT+JKeQKN3MHehFMyx3695z40b2Ug
        GIswfVmt6scQIokMRI5VsLkCIS+hXpDfFzrNy0LjDvs9GLk=
X-Google-Smtp-Source: APXvYqwqAg3UCvOQM14brsJRHqjPjGooBdYLlHbCcs1vJMzxUlhUpY/QkNGrLydGq11vFI1SndLVvVhT6Re59l1qWEE=
X-Received: by 2002:a6b:400f:: with SMTP id k15mr129915ioa.153.1568672942506;
 Mon, 16 Sep 2019 15:29:02 -0700 (PDT)
MIME-Version: 1.0
References: <1567518908-1720-1-git-send-email-alex@zadara.com>
In-Reply-To: <1567518908-1720-1-git-send-email-alex@zadara.com>
From:   John Gallagher <john.gallagher@delphix.com>
Date:   Mon, 16 Sep 2019 15:28:26 -0700
Message-ID: <CANHi-ReAFifZwBrRniLBiRnQOWeJKu-EYp18LDHwtr50eifVMw@mail.gmail.com>
Subject: Re: [RFC-PATCH] nfsd: provide a procfs entry to release stateids of a
 particular local filesystem
To:     alex@zadara.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Sep 3, 2019 at 6:57 AM Alex Lyakas <alex@zadara.com> wrote:
> This patch allows user-space to tell nfsd to release stateids of a particular local filesystem.
> After that, it is possible to unmount the local filesystem.

We recently ran into this exact same issue. A solution along these
lines would be very useful to us as well. I am curious, though, is it
feasible to release all state related to a filesystem immediately when
it is unexported? It seems like that would be ideal from the
perspective of the administrator of the server, but perhaps there are
technical reasons why that isn't easy or even possible.

-John
