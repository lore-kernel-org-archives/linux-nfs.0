Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CD16C54E76
	for <linux-nfs@archiver.kernel.org>; Sat, 18 Nov 2023 06:42:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230044AbjKRGmx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 18 Nov 2023 01:42:53 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40380 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229844AbjKRGmx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Nov 2023 01:42:53 -0500
Received: from mail-ed1-x534.google.com (mail-ed1-x534.google.com [IPv6:2a00:1450:4864:20::534])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 359F1D57
        for <linux-nfs@vger.kernel.org>; Fri, 17 Nov 2023 22:42:49 -0800 (PST)
Received: by mail-ed1-x534.google.com with SMTP id 4fb4d7f45d1cf-54553e4888bso3773395a12.2
        for <linux-nfs@vger.kernel.org>; Fri, 17 Nov 2023 22:42:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1700289767; x=1700894567; darn=vger.kernel.org;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :from:to:cc:subject:date:message-id:reply-to;
        bh=eNr1lcL1qtefdLDACHJuspr2lF6rRn1MzrR4xSI2n6s=;
        b=d+Sx1iDvjFQ4JSUCBR1xzrsW8E6byF1XzCeo+C4vTFEpeFtOAILyRqP1KqVkNvp1lt
         S9MMUjV4FuzVrpwAqGxeLMKXyXy2v+0tIHlC0P3V0s/PJ9pDYrZkqmSgmsM2bw6Qnmbh
         95wE1khA+nYN0Vfg/HnoOTWBdpXHTSecvqqQpLvgSPKJr5uieBzoQ8sUFRjxpA/Bp8HH
         /Uzvd8oLNGEaJn6i6a4gdoHQqENtvGzGdBbSFZpAbcYmHwsRdIHcyv0DQ6Pwqd0cWFmj
         92i9UsKl3WTh57VCjPQbNcS6e0mPsSVopyDduaI6GQqpJ0c0gIqLc0N5+ZuVgOhuIJH3
         agQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1700289767; x=1700894567;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=eNr1lcL1qtefdLDACHJuspr2lF6rRn1MzrR4xSI2n6s=;
        b=JtxCshzE0ZIQwQCESMXAUhVWfgwdEgCmZGGypGLYqRCeDRqnV66X9+coH0vj8uj4nc
         k3PR1tbeKxe5OtkDa3BDObNE6wIozxsBkVRRz5IRwezKVrTsmh3qWUpAfBVNjuhNsQtK
         u4Alc2yAT8pmWcm58uwN3PhFNQaZCzDqbd0KrqCt6AeWjGqsvj+JwKWd1iD7Hg5jjsmG
         SNNp845pca5s70z4uUhtzvCS7iso1uqk5KJFO+4iYzkJZGyUqkvUq+Yv6CqFctzs/16n
         OjFEZrwJTM0zGhXr5XHzzbYmPDlFo4TW0+TjOy5I9DeLIQ10xscm8w5JwXeSrKqxGcUP
         jnbA==
X-Gm-Message-State: AOJu0YyYX5VCzX8wxjL2PHN9ydXNqV50jV2vrSzhcfftXtpqYAx/JwL1
        qzelBTudEPJAxgpGIWZRwgDz731TI90CtCK+FIrxx1jm
X-Google-Smtp-Source: AGHT+IElx6ocLnuZvkv14LxfBmJ+Op+aYbImD7UBBqEC44oeV8LmWF4YX5LLmxTbo9D1nCNBO5zZai7CeVawFvb4gkw=
X-Received: by 2002:aa7:d985:0:b0:544:a27c:f7b6 with SMTP id
 u5-20020aa7d985000000b00544a27cf7b6mr1012462eds.8.1700289767248; Fri, 17 Nov
 2023 22:42:47 -0800 (PST)
MIME-Version: 1.0
References: <bug-218138-226593@https.bugzilla.kernel.org/> <bug-218138-226593-fRCLxzGk3u@https.bugzilla.kernel.org/>
 <CALXu0Ucz2MGCYdMw74ZKGUj_hpGcLP-pxC=MSgpUFGU58=jc=g@mail.gmail.com>
In-Reply-To: <CALXu0Ucz2MGCYdMw74ZKGUj_hpGcLP-pxC=MSgpUFGU58=jc=g@mail.gmail.com>
From:   Cedric Blancher <cedric.blancher@gmail.com>
Date:   Sat, 18 Nov 2023 07:42:11 +0100
Message-ID: <CALXu0UdY=ZgcAqvC6Y-X6htxPQ9=XWemt8V4dxTA99wQmHKz=w@mail.gmail.com>
Subject: Who owns bugzilla.linux-nfs.org - account creation broken? Re: How
 owns bugzilla.linux-nfs.org? Fwd: [Bug 218138] NFSv4 referrals - no way to
 define custom (non-2049) port numbers for referrals
To:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 17 Nov 2023 at 08:42, Cedric Blancher <cedric.blancher@gmail.com> wrote:
>
> How owns bugzilla.linux-nfs.org?

Apologies for the type, it should be "who", not "how".

But the problem remains, I still did not get an account creation token
via email for *ANY* of my email addresses. It appears account creation
is broken.

Ced
>
> Ced
>
> ---------- Forwarded message ---------
> From: <bugzilla-daemon@kernel.org>
> Date: Fri, 17 Nov 2023 at 08:41
> Subject: [Bug 218138] NFSv4 referrals - no way to define custom
> (non-2049) port numbers for referrals
> To: <cedric.blancher@gmail.com>
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=218138
>
> --- Comment #2 from Cedric Blancher (cedric.blancher@gmail.com) ---
> I cannot access bugzilla.linux-nfs.org, it it does not send a "account
> verification token email" to me.
>
> --
> You may reply to this email to add a comment.
>
> You are receiving this mail because:
> You are on the CC list for the bug.
> You reported the bug.
>
>
> --
> Cedric Blancher <cedric.blancher@gmail.com>
> [https://plus.google.com/u/0/+CedricBlancher/]
> Institute Pasteur



-- 
Cedric Blancher <cedric.blancher@gmail.com>
[https://plus.google.com/u/0/+CedricBlancher/]
Institute Pasteur
