Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34113 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943AbbHYQNc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 12:13:32 -0400
Received: by pabzx8 with SMTP id zx8so37918863pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 09:13:32 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 0/2] NFS: two simple cleanup patches
Date: Wed, 26 Aug 2015 00:13:14 +0800
Message-Id: <1440519196-116456-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

These are extracted from the CLONE patch series.
Just so that they don't have to wait on CLONE patches.

Cheers,
Tao


Peng Tao (2):
  nfs42: decode_layoutstats does not need res parameter
  nfs42: remove unused declaration

 fs/nfs/nfs42.h    | 2 --
 fs/nfs/nfs42xdr.c | 5 ++---
 2 files changed, 2 insertions(+), 5 deletions(-)

-- 
1.8.3.1

