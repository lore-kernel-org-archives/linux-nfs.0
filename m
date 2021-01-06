Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D735C433E6
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Jan 2021 07:53:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 22ECD2310A
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Jan 2021 07:53:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727206AbhAFHxc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Jan 2021 02:53:32 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51532 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727042AbhAFHxb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2021 02:53:31 -0500
Received: from mail-wm1-x32f.google.com (mail-wm1-x32f.google.com [IPv6:2a00:1450:4864:20::32f])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3F5F4C06134C
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jan 2021 23:52:51 -0800 (PST)
Received: by mail-wm1-x32f.google.com with SMTP id g185so1786491wmf.3
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jan 2021 23:52:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=UMYk5w/fnPA5fxUdRj4gf0mfOxHScDKTZlOD67mOqec=;
        b=ZwVNAYQQhdHYwNDD3NVg7wlGNXNMu6ya0Asrtfj7SIgOXYraJJ8VfhdxEUdFkyP+kB
         tns9a0kBz0dxuCbWwILbqssq2LgGIc98u/V2bK+OquGg9xQjN7v5aiVw8ZbL1WwGGS/a
         foQbB0Gw0zIBVP4Zl++8vT0jqBKu5U5ZAvYy3PU2fAI9QGK1reuA0Q8HDEB3quBz3SiO
         S+VijzBok70VgMRdXJFsaT4QJCqS0pq/i0h0K/hDdm5lwq6657tD6HeKj/IZBYnltMwf
         k95Hw8ztYl8MJHX/TeCS5kqdcd3V7jm1en66i3Kb2661H2FXwRyJTVoeJrk4/48ZOqZ6
         sW2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=UMYk5w/fnPA5fxUdRj4gf0mfOxHScDKTZlOD67mOqec=;
        b=Gtvpk6O3ZdJePbGBjs6CcRG88gIXB7IwNR9KGWsWTCdlT6xN0YHhmFpnqm1wcpjV19
         SrGor/2CMinIc4TejanjoDwlydpIMHDw4A5Ircb4sHH8LVRA/+DJgNdIqZsDcQvZp9eo
         70Zt9g090Lv77CIrHH7v5BqEA97xLCizQ2ot+4nenW5xSl4bUNo2RLAUapyeUb4prQ07
         XhdvqjLL3G8LFC4eYOIkUqHj+ufO/CP3A9VHfY7HytPPiA6Mzo4PHui9qFhPO+eLpzO+
         5Vi/8KZS9o4oXP896Jn0F1v88ed57ItRg1qO2K/l3Xsn/9mBPZ9jvkXlQpjwaAN0HMIk
         lr/A==
X-Gm-Message-State: AOAM5336bE5zzoFVTZpO1od9cf8ylfaq27fgMj/KV7ei1nhbeUnI46Ne
        pAdJ7wetbQcGoKrHKUpysvo=
X-Google-Smtp-Source: ABdhPJxcY39jujeB7uwx9pFZEbU12OhXhnoLcS2CqLgZX9zPkSNn9nUbDPob38Q26Y/3npTMdBpspg==
X-Received: by 2002:a7b:cd90:: with SMTP id y16mr2506217wmj.115.1609919570006;
        Tue, 05 Jan 2021 23:52:50 -0800 (PST)
Received: from localhost.localdomain ([31.210.181.203])
        by smtp.gmail.com with ESMTPSA id h16sm1865536wmb.41.2021.01.05.23.52.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 05 Jan 2021 23:52:49 -0800 (PST)
From:   Amir Goldstein <amir73il@gmail.com>
To:     "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] Improvements to nfsd stats
Date:   Wed,  6 Jan 2021 09:52:33 +0200
Message-Id: <20210106075236.4184-1-amir73il@gmail.com>
X-Mailer: git-send-email 2.17.1
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Bruce,

Per your request, I added a cleanup patch for unused counter.

Replaced the hacky counters array "union" with proper array
and added helpers to update the counters to avoid human mistakes
related to counter indices.

Thanks,
Amir.

Changes since v1:
- Cleanup unused stats counters (Bruce)
- Replace counters array hack with proper array (Chuck)
- Helpers to update both global and per-export stats

Amir Goldstein (3):
  nfsd: remove unused stats counters
  nfsd: protect concurrent access to nfsd stats counters
  nfsd: report per-export stats

 fs/nfsd/export.c   |  68 +++++++++++++++++++++++----
 fs/nfsd/export.h   |  15 ++++++
 fs/nfsd/netns.h    |  23 +++++----
 fs/nfsd/nfs4proc.c |   2 +-
 fs/nfsd/nfscache.c |  52 +++++++++++++++------
 fs/nfsd/nfsctl.c   |   8 +++-
 fs/nfsd/nfsd.h     |   2 +-
 fs/nfsd/nfsfh.c    |   4 +-
 fs/nfsd/stats.c    | 114 +++++++++++++++++++++++++++++++--------------
 fs/nfsd/stats.h    |  96 +++++++++++++++++++++++++++++---------
 fs/nfsd/vfs.c      |   4 +-
 11 files changed, 292 insertions(+), 96 deletions(-)

-- 
2.17.1

