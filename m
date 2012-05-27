Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:60512 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab2E0Fdl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 May 2012 01:33:41 -0400
Received: by pbbrp8 with SMTP id rp8so3356136pbb.19
        for <linux-nfs@vger.kernel.org>; Sat, 26 May 2012 22:33:41 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] NFS41: make block layout driver work w/ NFS DIO changes
Date: Sun, 27 May 2012 13:32:57 +0800
Message-Id: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This applies to Trond's devel branch.

Peng Tao (3):
  NFS41: add pnfs_dio_begin/dio_end
  pnfsblock: call block plug in bl_dio_begin/end
  pnfsblock: bail out unaligned DIO

 fs/nfs/blocklayout/blocklayout.c |   35 ++++++++++++++++++++++++++++++
 fs/nfs/direct.c                  |   43 ++++++++++++++++++++++++++++++++++---
 fs/nfs/pnfs.h                    |   38 +++++++++++++++++++++++++++++++++
 3 files changed, 112 insertions(+), 4 deletions(-)

