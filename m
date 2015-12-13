Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:35183 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751145AbbLMRoi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Dec 2015 12:44:38 -0500
Received: by mail-ig0-f179.google.com with SMTP id su19so69727658igc.0
        for <linux-nfs@vger.kernel.org>; Sun, 13 Dec 2015 09:44:37 -0800 (PST)
Message-ID: <1450028669.4152.1.camel@primarydata.com>
Subject: [GIT PULL] Please pull one bugfix for 4.4
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Sun, 13 Dec 2015 12:44:29 -0500
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 527e9316f8ec44bd53d90fb9f611fa7ffff52bb9:

  Linux 4.4-rc4 (2015-12-06 15:43:12 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/trondmy/linux-nfs.git tags/nfs-for-4.4-3

for you to fetch changes up to 756b9b37cfb2e3dc76b2e43a8c097402ac736e07:

  SUNRPC: Fix callback channel (2015-12-07 13:04:59 -0800)

----------------------------------------------------------------
NFS client bugfix for Linux 4.4

Bugfixes:
- SUNRPC: Fix a NFSv4.1 callback channel regression

----------------------------------------------------------------
Trond Myklebust (1):
      SUNRPC: Fix callback channel

 fs/nfs/callback_xdr.c         |  7 ++-----
 net/sunrpc/backchannel_rqst.c |  8 --------
 net/sunrpc/svc.c              | 12 ++++++++++++
 3 files changed, 14 insertions(+), 13 deletions(-)
-- 
Trond Myklebust
Principal System Architect
4300 El Camino Real | Suite 100
Los Altos, CA  94022
W: 650-422-3800
C: 801-921-4583 
www.primarydata.com

