Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:61136 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaGCFFk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 01:05:40 -0400
Received: by mail-pd0-f171.google.com with SMTP id fp1so13161792pdb.30
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jul 2014 22:05:39 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 0/3] nfs41: layoutreturn on last of close/delegation_return
Date: Thu,  3 Jul 2014 13:04:59 +0800
Message-Id: <1404363902-12943-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following patches changed client to do layout return on the last of file close
and delegation return, per Errata ID 3226.

Peng Tao (3):
  nfs4: add nfs4_check_delegation
  nfs41: return layout on last close
  nfs41: layout return on close in delegation return

 fs/nfs/delegation.c | 34 +++++++++++++++++++++--------
 fs/nfs/delegation.h |  1 +
 fs/nfs/nfs4proc.c   | 61 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 85 insertions(+), 11 deletions(-)

-- 
1.9.1

