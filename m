Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34121 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbbGMJ2Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:28:24 -0400
Received: by pacan13 with SMTP id an13so13011299pac.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:28:24 -0700 (PDT)
Message-ID: <55A384B1.8030207@gmail.com>
Date: Mon, 13 Jul 2015 17:28:17 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 00/14] nfsd:  some updates and cleanups
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first five are some bugfix and update,
the last nine are some cleanups.

Kinglong Mee (14):
  nfsd: Add layouts checking for state resources
  nfsd: Add missing gen_confirm nfsd4_setclientid()
  nfsd: Fix memory leak of so_owner.data in nfs4_stateowner
  nfsd: Fix a memory leak of struct file_lock
  nfsd: Use check_stateid_generation() for generation checking
  nfsd: Drop duplicate locks_init_lock()
  nfsd: Remove unneeded values in nfsd4_open()
  nfsd: Drop duplicate checking of seqid in nfsd4_create_session()
  nfsd: Remove nfs4_set_claim_prev()
  nfsd: Remove unused values in nfs4_setlease()
  nfsd: Remove duplicate checking of nfsd_net in nfs4_laundromat()
  nfsd: Remove macro LOFF_OVERFLOW
  nfsd: Use lk_new_xxx instead of v.new.xxx for nfs4_lockowner
  nfsd: Remove unused clientid arguments from find_lockowner_str{_locked}

 fs/nfsd/nfs4layouts.c |  7 +++--
 fs/nfsd/nfs4proc.c    |  4 +--
 fs/nfsd/nfs4state.c   | 74 ++++++++++++++++++++++-----------------------------
 fs/nfsd/state.h       |  1 +
 4 files changed, 37 insertions(+), 49 deletions(-)

-- 
2.4.3

