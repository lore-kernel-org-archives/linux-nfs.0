Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:55005 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933272AbaLMOLr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Dec 2014 09:11:47 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so6942289qcq.11
        for <linux-nfs@vger.kernel.org>; Sat, 13 Dec 2014 06:11:47 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfsd: fi_delegees bugfix and cleanup
Date: Sat, 13 Dec 2014 09:11:38 -0500
Message-Id: <1418479900-4757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

As I mentioned on IRC yesterday, here are a couple of patches to the
fi_delegees handling. The first one fixes a bug. I think it's pretty
unlikely to be hit in most cases, so I'm not sure if it's suitable for
stable. Your call there.

The second is just a cleanup patch -- fi_delegees is always handled
under spinlock so it really doesn't need to be an atomic_t.

Jeff Layton (2):
  nfsd: fix fi_delegees leak when fi_had_conflict returns true
  nfsd: fi_delegees doesn't need to be an atomic_t

 fs/nfsd/nfs4state.c | 8 ++++----
 fs/nfsd/state.h     | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

-- 
2.1.0

