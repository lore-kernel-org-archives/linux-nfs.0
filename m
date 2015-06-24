Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:36850 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752868AbbFXQKe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jun 2015 12:10:34 -0400
Received: by yhan67 with SMTP id n67so18399216yha.3
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jun 2015 09:10:33 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: thomas.haynes@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] nfs: fix credential handling problems in flexfiles code
Date: Wed, 24 Jun 2015 12:10:22 -0400
Message-Id: <1435162224-1184-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom reported seeing some NFSv3 WRITE calls going to a mirror DS that
were using the MDS credentials instead of the ones that were provided
in the LAYOUTGET response.

The problem turns out to be an issue in how mirror creds were being
set up. Creds are associated with the mirror, not the DS, but we'd
skip trying to set up the credentials in the mirror when we found that
the DS was already connected.

While I was in there, I spotted a potential credential leak too and
fixed that as well.

Jeff Layton (2):
  nfs: fix potential credential leak in ff_layout_update_mirror_cred
  nfs: always update creds in mirror, even when we have an already
    connected ds

 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

-- 
2.4.3

