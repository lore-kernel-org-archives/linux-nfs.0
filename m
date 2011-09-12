Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:55738 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab1ILWNh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:13:37 -0400
Received: by yxm8 with SMTP id 8so574577yxm.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:13:37 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Fixes for nfs-utils-1.2.next
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:05:56 -0400
Message-ID: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

For review: eight patches that address some minor issues in and around
sm-notify.

---

Chuck Lever (8):
      sm-notify: sm-notify leaves monitor records in sm.bak
      sm-notify: Avoid extra rpcbind queries
      sm-notify: Use correct retransmit timeout when sending a fresh RPC
      sm-notify: Refactor insert_host() and recv_rpcbind_reply()
      nfsumount: Squelch compiler warning
      configure.ac: Add --with-statd-extension configure option
      configure.ac: Clean up help string for --enable-mount
      configure.ac: Fix help string for --with-statedir= option


 configure.ac            |   13 +++++++-
 support/nsm/file.c      |    9 +----
 utils/mount/nfsumount.c |    3 +-
 utils/statd/sm-notify.c |   77 +++++++++++++++++++++++++++++------------------
 4 files changed, 62 insertions(+), 40 deletions(-)

-- 
Chuck Lever
