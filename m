Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:62515 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbaFFNHS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 09:07:18 -0400
Received: by mail-qg0-f51.google.com with SMTP id q107so4370750qgd.10
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2014 06:07:18 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH v2 0/2] nfsd: preliminary patches for client_mutex removal
Date: Fri,  6 Jun 2014 09:07:04 -0400
Message-Id: <1402060026-26511-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a respin of the last two patches in the 9 patch series I posted
last week. Bruce dropped patch #8, as it caused a lockdep pop due to
lock inversion between the i_lock and the state_lock. Patch #9 was
dropped due to objections from Christoph. Bruce indicated that he would
take the others, so I won't repost them here.

These two patches should address the previous concerns -- let me know if
there are any objections.

Jeff Layton (1):
  nfsd: avoid taking the state_lock while holding the i_lock

Trond Myklebust (1):
  nfsd: Protect addition to the file_hashtbl

 fs/nfsd/nfs4callback.c |   9 +++-
 fs/nfsd/nfs4state.c    | 123 ++++++++++++++++++++++++++++++++++++-------------
 fs/nfsd/state.h        |   2 +
 3 files changed, 101 insertions(+), 33 deletions(-)

-- 
1.9.3

