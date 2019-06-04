Return-Path: <SRS0=y/Bv=UD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 289E4C282CE
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Jun 2019 17:59:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E04FC2075B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Jun 2019 17:59:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fUrQa1IV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726200AbfFDR7o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Jun 2019 13:59:44 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:43001 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726162AbfFDR7o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jun 2019 13:59:44 -0400
Received: by mail-io1-f66.google.com with SMTP id u19so2163044ior.9
        for <linux-nfs@vger.kernel.org>; Tue, 04 Jun 2019 10:59:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=UmlynYV9JJPJaf9M5rJDa/z6DTWGMv75t9kRIvP99Fo=;
        b=fUrQa1IVlW5W4ikCT9lae1FW2mbT9PzZVGc99KsDNurQJriV8x6P56iU0dG3cdyqby
         WDA2yNbbIhyB7gKAd4h6ARjsu97UymvX0EydfbibM6nzME0QNhMr0DFa9L1P+EdyKQnc
         vxe9csaXWdTsHd30lB98Gz8rLIwxlE35SmHA+c1ABcTS6Xol64nwpBVq1vIwyqW0sTth
         33MqHaiHhebp+Zq+ieeOIS53pSIROraJyFld49F2MH5rWt3sQ8KlamlZ/kE8mHQEvWG3
         lodKUeltH+eGAT8+VNVmE5W9eWw364S0ycplAlM450asSULi3TaU+vAaRzNF9PlNKj0l
         zGFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=UmlynYV9JJPJaf9M5rJDa/z6DTWGMv75t9kRIvP99Fo=;
        b=X1AiNqQQJEeyYBwoCeqtgIBES11GRX2F7/4kEn97PuV9rAP2SSXFO+KKt2C/ReKMf9
         1EMc/u0csa+lLo2VcURwxK6uvnM9Pvewz2YMCP6nHi14pIU0mI++0ZxI5m9DIsRrbxC2
         2xhZgwWIQSkF3AayamQpPuYnC4gaNZAy9qsvtbcWRjN0aj3sJ8czDl8mhxfeEpTgCxnJ
         hYFEhRxB/bceL8hlhDbd6wh0pvREbd4PQlQOBRiAsynuJsf6J9s0kgiOw+61/ic3mKHq
         WYqn5rKy1hc8JjFbl7/H/XeKRVsID71p+XkXjf5FDwfLInLuImc6e6f6TJ7itHPzAztR
         vrqg==
X-Gm-Message-State: APjAAAWq3r2DbHPF5NsD7Z4W579xOJJIj9/VLeKNOOYmI98jVOuVU6zq
        ErqhwxF0zN++dyl++MjNjWtWxY4=
X-Google-Smtp-Source: APXvYqyFkKhQv0HkRk0rzItzOSs5JLHlA9JTGZoJn1U8vrv43sDl+pVeBMKb02PqS5QRwnkjb1h7mw==
X-Received: by 2002:a05:6602:220d:: with SMTP id n13mr8278998ion.104.1559671183101;
        Tue, 04 Jun 2019 10:59:43 -0700 (PDT)
Received: from localhost.localdomain (50-36-175-138.alma.mi.frontiernet.net. [50.36.175.138])
        by smtp.gmail.com with ESMTPSA id u134sm8355134itb.32.2019.06.04.10.59.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 10:59:42 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Steve Dickson <SteveD@redhat.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] Incremental against [exports] rootdir patchset
Date:   Tue,  4 Jun 2019 13:57:31 -0400
Message-Id: <20190604175734.98657-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These patches fix up a couple of bugs and issues against the [exports]
rootdir patchset for nfs-utils.

v2:
 - Fix nfsd_path_strip_root() return value, as pointed out by Bruce
 - Fix a strlen() bug in nfsd_path_strip_root()

Trond Myklebust (3):
  mountd: Fix up incorrect comparison in next_mnt()
  mountd: Ensure nfsd_path_strip_root() uses the canonicalised path
  mountd: Canonicalise the rootdir in exportent_mkrealpath()

 support/export/export.c  | 12 ++++++++++--
 support/misc/nfsd_path.c | 17 ++++++++++++-----
 utils/mountd/cache.c     |  8 +++++---
 3 files changed, 27 insertions(+), 10 deletions(-)

-- 
2.21.0

