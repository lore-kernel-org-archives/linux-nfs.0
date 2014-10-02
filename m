Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f44.google.com ([209.85.215.44]:40963 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752166AbaJBNmf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2014 09:42:35 -0400
Received: by mail-la0-f44.google.com with SMTP id gb8so2437306lab.3
        for <linux-nfs@vger.kernel.org>; Thu, 02 Oct 2014 06:42:33 -0700 (PDT)
From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        ncopa@alpinelinux.org
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH v2 0/5] rework access to /proc/net/rpc
Date: Thu,  2 Oct 2014 16:41:56 +0300
Message-Id: <1412257321-5855-1-git-send-email-timo.teras@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes since the first send:
- split to five separate patches
- fixed a bug in cache_get_filehandle() that made result parsing not work
- fixed to check result of write() calls

The review mentioned my patches adding:
nfssvc.c:71:8: warning: ignoring return value of 'system', declared with attribute warn_unused_result [-Wunused-result]
nfssvc.c:325:9: warning: ignoring return value of 'write', declared with attribute warn_unused_result [-Wunused-result]
but this does not make any sense: I'm only adding one #include there.
Is that perhaps uncovering some other issues?

I'm not sure if the NFSv3 related issues were caused by the cache_get_filehandle()
issue or not, so this still needs testing. Another potential cause is that the
kernel is sending to user land requests longer than RPC_CHAN_BUF_SIZE bytes, but
that does not seem likely.

Timo Teräs (5):
  Add string.h to source files that need it
  mountd: talk to kernel using file descriptors instead of FILE
  gssd: talk to kernel using file descriptors instead of FILE
  nfsexport: talk to kernel using file descriptors instead of FILE
  nfslib: remove now unused FILE helpers

 support/include/exportfs.h     |   1 +
 support/include/nfslib.h       |   7 -
 support/include/nfsrpc.h       |   1 +
 support/nfs/cacheio.c          | 111 +------------
 support/nfs/nfsexport.c        |  77 +++++----
 utils/gssd/gssd_proc.c         |   9 +-
 utils/gssd/svcgssd.h           |   2 +-
 utils/gssd/svcgssd_main_loop.c |   9 +-
 utils/gssd/svcgssd_proc.c      |  51 +++---
 utils/gssd/write_bytes.h       |   1 +
 utils/mountd/cache.c           | 343 ++++++++++++++++++++++-------------------
 utils/nfsd/nfssvc.c            |   1 +
 12 files changed, 270 insertions(+), 343 deletions(-)

-- 
2.1.2

