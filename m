Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:38771 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269AbaCDTFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 14:05:46 -0500
Received: by mail-ie0-f177.google.com with SMTP id rl12so7661466iec.8
        for <linux-nfs@vger.kernel.org>; Tue, 04 Mar 2014 11:05:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andy Adamson <andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] NFSv4 fix nfs4_stateid_is_current processing
Date: Tue,  4 Mar 2014 14:05:40 -0500
Message-Id: <1393959943-9919-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1393954269-3974-1-git-send-email-andros@netapp.com>
References: <1393954269-3974-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

Would this be a sufficient fix?

Cheers
  Trond

Andy Adamson (1):
  NFSv4.1 Fail data server I/O if stateid represents a lost lock

Trond Myklebust (2):
  NFSv4: Fix the return value of nfs4_select_rw_stateid
  NFSv4: Fail the truncate() if the lock/open stateid is invalid

 fs/nfs/nfs4filelayout.c | 10 ++++++----
 fs/nfs/nfs4proc.c       |  9 ++++++---
 fs/nfs/nfs4state.c      |  6 ------
 3 files changed, 12 insertions(+), 13 deletions(-)

-- 
1.8.5.3

