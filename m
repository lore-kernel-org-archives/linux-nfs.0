Return-Path: <SRS0=UHwe=23=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7441C33C8C
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:42:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 985D9208C4
	for <linux-nfs@archiver.kernel.org>; Mon,  6 Jan 2020 18:42:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aIPG3D8l"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726622AbgAFSms (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 6 Jan 2020 13:42:48 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:42216 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726612AbgAFSmr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2020 13:42:47 -0500
Received: by mail-yw1-f68.google.com with SMTP id x138so22275020ywd.9
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2020 10:42:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ZxVr+e5p70pKs41NRCMlls0hfGIjuOVxkMNNPVIgkmo=;
        b=aIPG3D8lfurLkQaALAsFYcEYReIgDlMlvuMlw4tsmiGkOOmk0JRBk4gbQLAhErkWaD
         XgS7FhFqGTy5K8kchl7lpOZDVb2GhcOg+Yq+rPwYorFOVGc7IZDcPOMmB4bQ98tXccWx
         ub9spCLREGjGypFabsZer4jOOGfu4cxRiNMFO1MYLoFVQ3Apl9arDnmQR8FDfQDcmDRP
         9EimOa4k/n9u1EcFNET9WpYIwpl+oLqGkrZjMxmjhnW0Z9ViEegSWn1z/PXRj+LSTAEy
         sbkf2jTwbBJmxUAHJjagYknyu1bZE1++kZxfMVqlcIzUfcUIVPp91YhWodaLIEKvJKbO
         sQRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=ZxVr+e5p70pKs41NRCMlls0hfGIjuOVxkMNNPVIgkmo=;
        b=mTrbajv8ll92mwtuHvzwN1wu9pJ+Loqx5FwTaZzlw+BDzPL1Pum9veJDQI6l+3znoJ
         QNlo3fF8LD5nf1YSzw+HavGRrdQrV0Eaa8H56VkYOvIvEYI1p8iYQO45BPnu+qWrpxqG
         83s38VAeyCpDj0lCRP0i2qmzR46RmrnQpkDs6tagJh1qCwb9j4beV9/Mg6u+i63eJ+PT
         FQgm6N1HIWP3k1T5S20IDpgMB0AGPmN+6dLwRbkkuFr2RVplRvgyeyW1wAMze6+sRMM5
         /SjGKgPkHenIAdL+/3QZnHczoNnMke1JNc3mo2tD6ViXlLI85Ot7g+4Zu3Saa0XJvsGP
         HZbw==
X-Gm-Message-State: APjAAAUC3M7WGZIYVvHBJEp9TWDv8iveSta+FIGXhYD+30qD9cUSYChV
        d6H92p+HDnl+MbcEkyalwH/zKku5Gw==
X-Google-Smtp-Source: APXvYqxJ4Rw07uf/kK4TobtnYYHk4IjR+H/TnWfwWBqlire7ksipOGHN45ONvbvmXpJN6ODRIex5BA==
X-Received: by 2002:a0d:ca14:: with SMTP id m20mr76713543ywd.251.1578336166593;
        Mon, 06 Jan 2020 10:42:46 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id u136sm28223497ywf.101.2020.01.06.10.42.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 06 Jan 2020 10:42:46 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] Fix error reporting for NFS writes
Date:   Mon,  6 Jan 2020 13:40:28 -0500
Message-Id: <20200106184037.563557-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.24.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In cases where we have transient errors, such as ENOSPC, it is important
to ensure that errors are reported on all writes that may be affected.

The problem we have is that not all errors are guaranteed to be reported
at write time. Some are reported only when we call fsync(). In
particular, this can be a problem for stable NFS writes. Since most
filesystems protect the write to the page cache with the inode lock,
but do not protect the subsequent call to generic_write_sync(), this
means that if we have parallel writes to the same file, we can end up
assigning the error to the wrong stable write call. If the application
expects to be able to fix the transient errors, it may end up replaying
the wrong write. One area where we have seen this happen is in flexfiles
writes, where the server is capable of freeing up space on the DS in
case of ENOSPC.

The other area where we have seen a similar problem is when we have
unstable writes, and the client sends a backgrounded commit in order
to free up memory. If there are outstanding writes while the commit
gets a transient error and bumps the write verifier, then we want to
ensure that those writes get the approprite write verifier depending
on whether they were affected by the fsync() or not. Right now,
because the NFSv3 verifier is set in the XDR encoder well after the
write is done, there is fairly large window for a race with a
background commit.

This patch series deals with both issues by adding per-file-descriptor
locking that ensures that writes, fsync error handling, and write verifier
updates are appropriately serialised.

Trond Myklebust (9):
  nfsd: Allow nfsd_vfs_write() to take the nfsd_file as an argument
  nfsd: Fix stable writes
  nfsd: Update the boot verifier on stable writes too.
  nfsd: Pass the nfsd_file as arguments to nfsd4_clone_file_range()
  nfsd: Ensure exclusion between CLONE and WRITE errors
  sunrpc: Fix potential leaks in sunrpc_cache_unhash()
  sunrpc: clean up cache entry add/remove from hashtable
  nfsd: Ensure sampling of the commit verifier is atomic with the commit
  nfsd: Ensure sampling of the write verifier is atomic with the write

 fs/nfsd/filecache.c |  1 +
 fs/nfsd/filecache.h |  1 +
 fs/nfsd/nfs3proc.c  |  5 +--
 fs/nfsd/nfs3xdr.c   | 16 +++------
 fs/nfsd/nfs4proc.c  | 14 ++++----
 fs/nfsd/nfsproc.c   |  2 +-
 fs/nfsd/vfs.c       | 79 ++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/vfs.h       | 16 +++++----
 fs/nfsd/xdr3.h      |  2 ++
 net/sunrpc/cache.c  | 48 ++++++++++++++-------------
 10 files changed, 115 insertions(+), 69 deletions(-)

-- 
2.24.1

