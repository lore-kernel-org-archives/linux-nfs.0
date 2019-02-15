Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BB01C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 21:47:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 01AFA222DE
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 21:47:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AJlzRHAC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392749AbfBOVrx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 16:47:53 -0500
Received: from mail-it1-f171.google.com ([209.85.166.171]:40847 "EHLO
        mail-it1-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387436AbfBOVrx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2019 16:47:53 -0500
Received: by mail-it1-f171.google.com with SMTP id i2so26975558ite.5;
        Fri, 15 Feb 2019 13:47:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:user-agent:mime-version
         :content-transfer-encoding;
        bh=6y/+srQwtB7aEScz+rYdpgohv4hFA3O1A0EoFKMmAlI=;
        b=AJlzRHACxUfo2KS7p1chZ7Zz6FNRnhSPqjKQrpF/NXW+ViSN773GEZ4QtqSzxbAkjI
         pjqz+Pv9VmZzVMCAPUc2OYQlFuMEYIUFoK9xOddV5okVSz2a8Ehiq8TteHJNvQg46SBN
         mJdqkFSU+a9D83M+7/S3sUdLQLidVKvjGeDUmF1FOtcHCc3h6SvU9vAmroiRI2fryfLX
         Jx7JeGlAQZzh30qqB7ZwPJNiNmXzp/2aFz90y/l8W3mEDT/tkv2Rf8MJOfIQYP7wnEDw
         MNhPA0Mca3pFKHJMf6cV/5Z9j+LaUgRDA0IMT9mXamsrjBSdg/btsDUwBR6iZ/OLVfC0
         s9yA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :user-agent:mime-version:content-transfer-encoding;
        bh=6y/+srQwtB7aEScz+rYdpgohv4hFA3O1A0EoFKMmAlI=;
        b=jk1MavYEvSmS6WnFUOnQLvBYcPKIcIVF27LqoQpVAsYbiM2ZqmeZBQgwiwI4Ruw7Nr
         PUnjz9UNW8sgYVgqCVbmQHGh9lPccyXFISkgmILJVSKsYOccOfc7SaXRo8X8bv+69H+5
         avaKPdPduPt9dEpJmVqY1P2sS2HqX4hKdSf+X/BaA0BISCd2BDA2fyY4lIehEiy7d5WE
         JuNvpkfo81S/T+5eBGKHHoitOgniXkj1x3i1vIFHYlrToeEHVlXwGDpWBG6KjZ925l1v
         tqAXZRCJz9NLsHYmcx5hGzjSs7rRxynePqJXTvDlwR93liQNiGHuFl9byn3bIAHOg6E/
         5o1w==
X-Gm-Message-State: AHQUAuaDeiCNp2f+iVP4RVQUMpyqyzp5N9VDL/PHaymMqJ+0HDss87Mr
        ZstXFv2wkKVFUCRImUsV1hfrb/w1Jfk=
X-Google-Smtp-Source: AHgI3IaxxVLVa3LwlQbgfOPQ3msH71MMbrD1yuQA17WzrWdoaeq2aDzJnFsTtPQg2Zp0s/l+Igk66Q==
X-Received: by 2002:a6b:f814:: with SMTP id o20mr6926435ioh.129.1550267271813;
        Fri, 15 Feb 2019 13:47:51 -0800 (PST)
Received: from gouda.nowheycreamery.com (c-73-145-169-100.hsd1.mi.comcast.net. [73.145.169.100])
        by smtp.googlemail.com with ESMTPSA id r17sm2234643ita.31.2019.02.15.13.47.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Feb 2019 13:47:51 -0800 (PST)
Message-ID: <39718a97aca3b96d016069ea46371b193f8ac41a.camel@gmail.com>
Subject: [GIT PULL] Please pull additional NFS client fixes for 5.0
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Date:   Fri, 15 Feb 2019 16:47:50 -0500
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Linus,

The following changes since commit 8fc75bed96bb94e23ca51bd9be4daf65c57697bf:

  NFS: Fix up return value on fatal errors in nfs_page_async_flush() (2019-01-29 
16:33:24 -0500)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-5.0-4

for you to fetch changes up to d2ceb7e57086750ea6198a31fd942d98099a0786:

  NFS: Don't use page_file_mapping after removing the page (2019-02-12 15:56:28
-0500)

----------------------------------------------------------------
Three fixes this time.  Nicolas's is for xprtrdma completion vector allocation
on single-core systems.  Greg's adds an error check when allocating a debugfs
dentry.  And Ben's is an additional fix for nfs_page_async_flush() to prevent
pages from accidentally getting truncated.

Have a good weekend!
Anna
----------------------------------------------------------------
Benjamin Coddington (1):
      NFS: Don't use page_file_mapping after removing the page

Greg Kroah-Hartman (1):
      rpc: properly check debugfs dentry before using it

Nicolas Morey-Chaisemartin (1):
      xprtrdma: Make sure Send CQ is allocated on an existing compvec

 fs/nfs/write.c              | 11 ++++++-----
 net/sunrpc/debugfs.c        |  2 +-
 net/sunrpc/xprtrdma/verbs.c |  3 ++-
 3 files changed, 9 insertions(+), 7 deletions(-)

