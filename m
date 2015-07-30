Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34818 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbbG3NtI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:49:08 -0400
Received: by pabkd10 with SMTP id kd10so23922024pab.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:49:08 -0700 (PDT)
Message-ID: <55BA2B46.90204@gmail.com>
Date: Thu, 30 Jul 2015 21:48:54 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 0/5] NFSD: some bugfixes and updates
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first three are bugfixes, the last two are updates for EXCLUSIVE4_1.

Kinglong Mee (5):
  NFSD: Store parent's stat in a sperate value
  NFSD: Fix a encode bug of FS_LAYOUT_TYPES and LAYOUT_TYPES
  NFSD: SUPPATTR_EXCLCREAT must be encoded before SECURITY_LABEL.
  NFSD: Set the attributes used to store the verifier for EXCLUSIVE4_1
  NFSD: Return word2 bitmask if setting security label in OPEN/CREATE

 fs/nfsd/nfs4proc.c |  12 ++--
 fs/nfsd/nfs4xdr.c  | 158 +++++++++++++++++++++++++++++++++--------------------
 fs/nfsd/vfs.c      |   6 --
 fs/nfsd/vfs.h      |   6 ++
 4 files changed, 112 insertions(+), 70 deletions(-)

-- 
2.4.3

