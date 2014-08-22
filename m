Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:56050 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaHVTKo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 15:10:44 -0400
Received: by mail-ie0-f178.google.com with SMTP id rd18so7039364iec.37
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2014 12:10:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] Simple-minded server fixes for sidecar backchannel
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 22 Aug 2014 15:10:42 -0400
Message-ID: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I've been testing these for my client backchannel work. These are a
naive first pass at fixing server issues with multiple connections
per session.

---

Chuck Lever (4):
      nfsd: Assert SEQ4_STATUS_CB_PATH_DOWN_SESSION
      nfsd: Mark back channel down if SESSION4_BACK_CHAN is clear
      NFSD: Always initialize cl_cb_addr
      sunrpc: fix byte-swapping of displayed XID


 fs/nfsd/nfs4state.c  |    8 ++++++--
 net/sunrpc/svcsock.c |    2 +-
 2 files changed, 7 insertions(+), 3 deletions(-)

-- 
Chuck Lever
