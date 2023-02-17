Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 828B0C636D4
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Feb 2023 11:54:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229750AbjBQLyv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 17 Feb 2023 06:54:51 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36642 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229510AbjBQLyv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2023 06:54:51 -0500
Received: from mail-yw1-x112d.google.com (mail-yw1-x112d.google.com [IPv6:2607:f8b0:4864:20::112d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id F2AE65EC94
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2023 03:54:49 -0800 (PST)
Received: by mail-yw1-x112d.google.com with SMTP id 00721157ae682-53656e6bedaso8583307b3.7
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2023 03:54:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dneg.com; s=google;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=qYqHHok90Vsj+Ms99hgwyJzpGXfvTfmvALwHu1iTRkY=;
        b=b4pekX7PPYufCSMwXQwqQ0D22SikxmJB1ZbLwdR6PT2SLD8HGXnyyY5p6gEi4RuegS
         Tfo0myq/qL7iyPQ0luGtOiC2yanaiQR/yRM64Q+mo27yzHyelrtJX4XFGBn3akfIHHna
         Iw7YittxjbJVGDmWH4EHpOCnXFHEHduI4iM2dXjoxlxCsPscMJO0gFnb3IZ3TEz9iqqc
         e7bFp+M4I2Mk6quexseJwsbJJAoqZOcw/TVF+qVM3l1QdmLJNsU+S+xSQijhoFdhudH7
         /ARgiTjPhzh8o0FgBO9XxYEHEnxvWt7EAQYhURgt4PjGKslAv3X//B9kOQmpkh/mJAXj
         A4rg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=qYqHHok90Vsj+Ms99hgwyJzpGXfvTfmvALwHu1iTRkY=;
        b=hPXZsCtVOYkL1nrBdKLns2brvaHdjW5dbQ+/pEQHQvzyFIORof41FSyP6dde9Io6ic
         NioP+qyGEfz8/0A2YqVVlP/PP2CcpfEBZg2EwqvRvXXGTqehk8BoY2OKaG/BnP+E5WJC
         jkxmwvjh3o08z0uVfWlfj2+gJ3J+I39EyfHvW0ufuhd56wT7CueSXWamDi6Jfp/5z56B
         OOO9/nQwuvatJKuSpHry0zWIBMPKDqq8+bk//Xx01sr2A630ScKT4UC40BRpWIdr/tB1
         wM/+8gapGwVGkulMOvkmIV9u8fHfBBzuWE3Jfb6HM24CYwUtUdTmzcvKyePPVdyZSg5R
         A8OQ==
X-Gm-Message-State: AO0yUKWO264Rv1/DpQmjXTEtUajxM5V2dk7pFrTpQB5kCk/B7tN3EFbR
        fdxJi4raNKXhbHisllMNVMlv1cbpWxVZORNsQlbrvbJFQXPRjG4VFYA=
X-Google-Smtp-Source: AK7set9N/kG8hiKOo6GLkmj3Spw/Gh4jupA3To+C6CJDRmqdOsYLYfqGsJLzTiz2HJcFUJySMfnG+8jRY94k4R/WOgE=
X-Received: by 2002:a81:9381:0:b0:52f:1c60:923 with SMTP id
 k123-20020a819381000000b0052f1c600923mr1203145ywg.149.1676634888998; Fri, 17
 Feb 2023 03:54:48 -0800 (PST)
MIME-Version: 1.0
From:   Daire Byrne <daire@dneg.com>
Date:   Fri, 17 Feb 2023 11:54:12 +0000
Message-ID: <CAPt2mGNEYUk5u8V4abe=5MM5msZqmvzCVrtCP4Qw1n=gCHCnww@mail.gmail.com>
Subject: /proc/PID/io/read_bytes accounting regression?
To:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

Maybe someone here can quickly point me in the right direction for
this oddity that we noticed.

On newer kernels, it looks like the task io accounting is not
incrementing the read_bytes when reading from a NFS mount? This was
definitely working on v5.16 downwards, but has not been working since
v5.18 up to v6.2 (I haven't tested v5.17 yet).

If I read from a local filesystem, then the read_bytes for that PID is
incremented as expected.

If I read over NFS using directIO, then the read_bytes is also
correctly incremented for that PID. It's just when reading normally
without directIO that it is not.

The write_bytes and rchar are also still both correct in all situations.

I have checked the kernel config and I'm fairly sure I have all the
right things enabled:

CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_TASKSTATS=y

Unless there was some extra config introduced specific to the nfs
client in later kernels that I missed?

Cheers,

Daire
