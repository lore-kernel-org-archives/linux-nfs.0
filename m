Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8A9CECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9D88920833
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EULgr709"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D88920833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727432AbeJYE2P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:15 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:37685 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726221AbeJYE2P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:15 -0400
Received: by mail-qt1-f194.google.com with SMTP id d14-v6so7108416qto.4;
        Wed, 24 Oct 2018 12:58:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=+0fsrlOq/dSjaEtkyCmz/HyRHi0zkd/mUP3yrg/KeN8=;
        b=EULgr7097K2Ned1BR7S+KHDiMM+5pTQXBi+/v10X8ADiQzLQl/hB68Nh11aCmZH1+z
         9TMxogvhuGvmH1QtWRTAAGDMjGqV8SwD21HpH8gBJD9ojphTdHCJYvgCSJK6ZDedbrTl
         hBh5DTRVxp9k7LuJQvplERe2NZbWCp7EvhvxLNexVtw2WHqZaxRtVp2/vg5w+tnZ1U55
         s0MSjWZ329QH1iUPKqs9gOmOOeNtXHA7ZNuFX8tIOnMMETzgwaMnvaU8jV/iT5EiSkEM
         N8xEzOSMjcxgZauWmm6FjRagSHNMyyQisVoYEuPLUhCMVr0AFdRdeG5fDdMzOZtxOce4
         D1MQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=+0fsrlOq/dSjaEtkyCmz/HyRHi0zkd/mUP3yrg/KeN8=;
        b=o4UngGN+KiDHd2dqR/h5T9Sw9qK293q5R12SCXML914mSODoBsrtHL1GOOTuJkmhee
         vf0/DnLwyqG7o+K/n0McW+rjSwEJJqFPAN06cBnLUFA0X1t1sEYBi4qy/XbOBsFcyy1d
         Q6mm32ADZpGdrLkVN7jiBu9mVFEUdoUbhEaKFwZnkHzCkFuAOJCUZfHjr8Z8eL05Xny9
         2Pz9rG0gum5te4Z2phX9nBgQZ+M9SiuSaSKUdvMEcfVCXb70OYdouLR4noJZaeTWp1vd
         hCRYl8OtEi3E+JcLGrYPhV+NOTfJJboh7o4xfGlt0pBMc0J+NDxiEZWRCCDyVzOjOEgC
         +i6w==
X-Gm-Message-State: AGRZ1gIeDB1oP9HWBI2BqkhMDRcBGM+gOO88apGvLHhsXA4UmpmQzKyR
        vN+3ixFJM/Pfv5Yuio1Jlq/sUT9v
X-Google-Smtp-Source: AJdET5foZ7hC57QxWf9Wc6rH2HTULwU9uUkA9F0tcrzg6Xcsf/l6e2MUB6hAs4jrF9fqe4ExAC+7ag==
X-Received: by 2002:ac8:550e:: with SMTP id j14-v6mr3936452qtq.139.1540411128393;
        Wed, 24 Oct 2018 12:58:48 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.46
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:47 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 05/13] VFS: Don't copy beyond the end of the file
Date:   Wed, 24 Oct 2018 15:58:29 -0400
Message-Id: <20181024195837.35532-7-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Enforce the check that source offset can't be beyond the end of the file.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/read_write.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index fb4ffca..7bdbf39 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1570,6 +1570,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (unlikely(ret))
 		return ret;
 
+	if (pos_in >= i_size_read(inode_in))
+		return -EINVAL;
+
 	if (!(file_in->f_mode & FMODE_READ) ||
 	    !(file_out->f_mode & FMODE_WRITE) ||
 	    (file_out->f_flags & O_APPEND))
-- 
1.8.3.1

