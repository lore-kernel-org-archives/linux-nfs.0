Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45127 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab2HWQ2a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 12:28:30 -0400
Received: by pbbrr13 with SMTP id rr13so1767813pbb.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2012 09:28:29 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH-resend 0/6] NFS41 and pnfsblock bugfixes
Date: Fri, 24 Aug 2012 00:27:47 +0800
Message-Id: <1345739273-2241-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, hi,

The 6 patches were sent before. They are all bugfixes and 4 of them
are needed in stable as well. Please see if they are OK to be merged
in one of the rc pushes.

Thanks,
Tao

Peng Tao (6):
  NFSv41: fix DIO write_io calculation
  NFS41: fix error of setting blocklayoutdriver
  Revert "pnfsblock: bail out partial page IO"
  pnfsblock: fix partial page buffer wirte
  pnfsblock: fix non-aligned DIO read
  pnfsblock: fix non-aligned DIO write

 fs/nfs/blocklayout/blocklayout.c |  270 ++++++++++++++++++++++++++++++++-----
 fs/nfs/blocklayout/blocklayout.h |    1 +
 fs/nfs/client.c                  |    1 -
 fs/nfs/direct.c                  |    4 +-
 fs/nfs/nfs4proc.c                |    5 +-
 5 files changed, 240 insertions(+), 41 deletions(-)

