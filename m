Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:37493 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800AbaGNNNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 09:13:48 -0400
Received: by mail-qa0-f49.google.com with SMTP id dc16so3164282qab.8
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jul 2014 06:13:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfsd: avoid taking state_lock in delegation lm_break callback
Date: Mon, 14 Jul 2014 09:13:40 -0400
Message-Id: <1405343622-14385-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the interest of pushing this series out in smaller pieces, these two
patches clean up the delegation break callback. The basic idea here is
to avoid taking the state_lock while holding the i_lock, as it's a
highly contended global lock.

Jeff Layton (2):
  nfsd: eliminate nfsd4_init_callback
  nfsd: Avoid taking state_lock while holding inode lock in
    nfsd_break_one_deleg

 fs/nfsd/nfs4callback.c | 23 +++++++++++++++-----
 fs/nfsd/nfs4state.c    | 58 +++++++++++++++++++++++++++++++++-----------------
 fs/nfsd/state.h        |  4 +++-
 3 files changed, 59 insertions(+), 26 deletions(-)

-- 
1.9.3

