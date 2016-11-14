Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35875 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753358AbcKNQT7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2016 11:19:59 -0500
Received: by mail-it0-f68.google.com with SMTP id n68so15108799itn.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2016 08:19:58 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] Fix CLOSE races
Date: Mon, 14 Nov 2016 11:19:54 -0500
Message-Id: <1479140396-17779-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust (2):
  NFSv4: Fix CLOSE races with OPEN
  NFSv4: Don't call close if the open stateid has already been cleared

 fs/nfs/nfs4_fs.h  |  7 +++++++
 fs/nfs/nfs4proc.c | 15 ++++++++-------
 2 files changed, 15 insertions(+), 7 deletions(-)

-- 
2.7.4

