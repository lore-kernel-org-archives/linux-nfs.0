Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:58332 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754690Ab3FEPZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jun 2013 11:25:07 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] NFS v4.2 callbacks
Date: Wed,  5 Jun 2013 11:15:00 -0400
Message-Id: <1370445302-1261-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The labeled NFS patch series adds in support for NFS v4.2 but does not
change the callback code.

Questions and comments are appreciated!

~ Bryan

Bryan Schumaker (2):
  NFS: Make callbacks minor version generic
  NFS: Add in v4.2 callback operation

 fs/nfs/callback.h      |  3 +++
 fs/nfs/callback_proc.c |  3 ++-
 fs/nfs/callback_xdr.c  | 45 ++++++++++++++++++++++++++++++++++++---------
 fs/nfs/internal.h      |  2 +-
 fs/nfs/nfs4client.c    |  6 +++---
 5 files changed, 45 insertions(+), 14 deletions(-)

-- 
1.8.3

