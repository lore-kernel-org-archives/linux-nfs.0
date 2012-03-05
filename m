Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63689 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab2CEQml (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2012 11:42:41 -0500
Received: by yenl12 with SMTP id l12so1734348yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Mar 2012 08:42:41 -0800 (PST)
MIME-Version: 1.0
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfsd: bugfixes for
Date: Mon,  5 Mar 2012 11:42:34 -0500
Message-Id: <1330965756-24180-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches are a couple of bugfixes for some problems I noticed
while working on the nfsdcld patches. Bruce asked that I break them
out separately and rebase the rest of the set on top.

I've tested earlier patchsets with similar changes, but have not
heavily tested these individually. Unfortunately, I might not get to
it for a little while.

Jeff Layton (2):
  nfsd: convert nfs4_client->cl_cb_flags to a generic flags field
  nfsd: only initialize client tracking if nfs4_state_start is
    successful

 fs/nfsd/nfs4callback.c |   14 +++++-----
 fs/nfsd/nfs4proc.c     |    3 +-
 fs/nfsd/nfs4recover.c  |    7 ++---
 fs/nfsd/nfs4state.c    |   64 ++++++++++++++++++++++++++++++------------------
 fs/nfsd/state.h        |   11 +++++---
 5 files changed, 59 insertions(+), 40 deletions(-)

-- 
1.7.7.6

