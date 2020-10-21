Return-Path: <SRS0=tLVj=D4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DEF2C561F8
	for <linux-nfs@archiver.kernel.org>; Wed, 21 Oct 2020 12:05:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A41FF2224B
	for <linux-nfs@archiver.kernel.org>; Wed, 21 Oct 2020 12:05:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=sargun.me header.i=@sargun.me header.b="jV9z+cRc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2411215AbgJUMFm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 21 Oct 2020 08:05:42 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42886 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2394354AbgJUMFl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2020 08:05:41 -0400
Received: from mail-pj1-x102d.google.com (mail-pj1-x102d.google.com [IPv6:2607:f8b0:4864:20::102d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2049FC0613CE
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2020 05:05:40 -0700 (PDT)
Received: by mail-pj1-x102d.google.com with SMTP id o1so494818pjt.2
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2020 05:05:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sargun.me; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=8TxU0viuBluTKQF9t5UR8OZyp0sXLEy5AAHfwmWIDxM=;
        b=jV9z+cRcDVfCxqwN5YefepN4vjXW1z2aio5WwrZSTBqB0Gb5pqT2DlB2NijmSZVHQd
         cZdaU47qNBGDbqY16uoo3JMqHA/VzYree1aG/8d6A1HFyz7FNOytu4NQ5lTl7IumsbOy
         WwFdbRLbPpQWY7tgDfB0nbPnSVVuMpK4Loz/I=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=8TxU0viuBluTKQF9t5UR8OZyp0sXLEy5AAHfwmWIDxM=;
        b=AXSHA3j5Zf1ea2zNZZNtXsEeJt/dM1R2uTq746rou4m1PYURmZEVjMtpHpP4kcMnJb
         Du4CcQNt98HKTZJSTpOBNGbm2p8m1adxRnXGH6f8ak5CtVyv6+/KafSNDyZMg2Iin98u
         I/f07N8P0in+ShO4sPVxZofPnbz20iPhODMorHdnYaK4BNsGm7D3v/t5lehRAoy4p7+L
         VRTQkJRVumqDW7Ds8vsJ/jYTaBBut+89r6DZpZ00ZvHlMIN70pkGL6qNofzHzJe9ehae
         pd0l8T+RwZVILv50t1w8/bEkhDkJj/+HumZgtYpY/+NOj7HQ8oU7DqoMMeDmqY5przFB
         FICw==
X-Gm-Message-State: AOAM532ijjkBJL0KAt3eyytu5NLDa04WqY4UuRXzjvuGwD92Fu938Uxg
        pVVdtoB+KRxzy5Qc/TsfB2ayHMYgPz9kSTle
X-Google-Smtp-Source: ABdhPJw0U0brZQyoiqLWxgT/1eYrtE4gIGoq7LWQqcalBppLUrkflx48X6zdsTp+QUGOrJ+gqpt3Zw==
X-Received: by 2002:a17:90b:4389:: with SMTP id in9mr3032009pjb.177.1603281939416;
        Wed, 21 Oct 2020 05:05:39 -0700 (PDT)
Received: from ubuntu.netflix.com (203.20.25.136.in-addr.arpa. [136.25.20.203])
        by smtp.gmail.com with ESMTPSA id b5sm2276392pfo.64.2020.10.21.05.05.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Oct 2020 05:05:38 -0700 (PDT)
From:   Sargun Dhillon <sargun@sargun.me>
To:     "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Scott Mayhew <smayhew@redhat.com>
Cc:     Sargun Dhillon <sargun@sargun.me>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, kylea@netflix.com
Subject: [PATCH v3 0/3] NFS User Namespaces
Date:   Wed, 21 Oct 2020 05:05:26 -0700
Message-Id: <20201021120529.7062-1-sargun@sargun.me>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patchset adds some functionality to allow NFS to be used from
containers. It piggybacks on the previous work Trond did to properly
encode, and decode UIDs / GIDs based on user namespaces, and the work
that Scott did in order to use the new fs_context API.

I removed the samples in this patchset, and I added safety in this re-roll.

We can likely "pull back" on this safety over time, in that we can
enable/disable id mapping per mount, and add some logic to make nfs4idmap
user namespace aware. Doing this for GSS is more complicated though.


Changes since v2:
  * Removed samples
  * Split out NFSv2/v3 patchset from NFSv4 patchset
  * Added restrictions around use
Changes since v1:
  * Added samples

Sargun Dhillon (3):
  NFS: NFSv2/NFSv3: Use cred from fs_context during mount
  NFSv4: Refactor: reference user namespace from nfs4idmap
  NFSv4: Refactor NFS to be use user namespaces

 fs/nfs/client.c     | 10 ++++++++--
 fs/nfs/nfs4client.c | 27 ++++++++++++++++++++++++++-
 fs/nfs/nfs4idmap.c  | 17 +++++++++--------
 fs/nfs/nfs4idmap.h  |  3 ++-
 4 files changed, 45 insertions(+), 12 deletions(-)

-- 
2.25.1

