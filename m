Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53629 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641Ab2HHByk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Aug 2012 21:54:40 -0400
Received: by pbbrr13 with SMTP id rr13so606214pbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 07 Aug 2012 18:54:40 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] pnfsblock: fix IO alignment bug
Date: Wed,  8 Aug 2012 09:54:10 +0800
Message-Id: <1344390854-1771-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Peng Tao (4):
  Revert "pnfsblock: bail out partial page IO"
  pnfsblock: fix partial page buffer wirte
  pnfsblock: fix non-aligned DIO read
  pnfsblock: fix non-aligned DIO write

 fs/nfs/blocklayout/blocklayout.c |  270 ++++++++++++++++++++++++++++++++-----
 fs/nfs/blocklayout/blocklayout.h |    1 +
 2 files changed, 234 insertions(+), 37 deletions(-)

