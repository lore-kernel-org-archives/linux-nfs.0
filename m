Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38490 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405AbcAYOJu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 09:09:50 -0500
Received: by mail-ig0-f169.google.com with SMTP id mw1so31378474igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2016 06:09:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Convert client back-channel to use session slot table
Date: Mon, 25 Jan 2016 09:09:11 -0500
Message-Id: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patchset is intended to convert the current ad-hoc backchannel
session semantics to use the generic slot table in fs/nfs/nfs4session.c
This should suffice to allow us to grow the size of the slot table at will.

Trond Myklebust (5):
  NFSv4.x: Remove hard coded slotids in callback channel
  NFSv4.x: CB_SEQUENCE should return NFS4ERR_DELAY if still executing
  NFSv4.x: Enforce the ca_maxresponsesize_cached on the back channel
  NFSv4.x: Fix wraparound issues when validing the callback sequence id
  NFSv4.x: Allow multiple callbacks in flight

 fs/nfs/callback.h      |  3 ++-
 fs/nfs/callback_proc.c | 64 ++++++++++++++++++++++++++------------------------
 fs/nfs/callback_xdr.c  | 12 ++++++----
 fs/nfs/nfs4proc.c      |  2 +-
 fs/nfs/nfs4session.c   | 54 ++++++++++++++++++++++++++++++++----------
 fs/nfs/nfs4session.h   |  8 +++++++
 6 files changed, 93 insertions(+), 50 deletions(-)

-- 
2.5.0

