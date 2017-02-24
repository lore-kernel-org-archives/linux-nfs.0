Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33376 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751571AbdBXAeM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 19:34:12 -0500
Received: by mail-it0-f65.google.com with SMTP id e137so824863itc.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2017 16:33:53 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.com
Subject: [PATCH 0/2] Patch rpc.nfsd to allow the caller to turn off NFSv4.0
Date: Thu, 23 Feb 2017 19:33:42 -0500
Message-Id: <20170224003344.113724-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset for nfs-utils goes together with the kernel knfsd patches
that were submitted to Bruce on 2/22/2017. It is needed in order to allow
the user to turn off NFSv4 minor version 0.

Trond Myklebust (2):
  nfsd: Allow the caller to turn off NFSv4.0 without turning off NFSv4.x
  nfsd: Change the default to enable all minor versions unless told
    otherwise

 support/include/nfs/nfs.h |  7 +++--
 utils/nfsd/nfsd.c         | 42 ++++++++++++++++----------
 utils/nfsd/nfsd.man       |  4 +--
 utils/nfsd/nfssvc.c       | 76 ++++++++++++++++++++++++++++++++++++-----------
 utils/nfsd/nfssvc.h       |  1 +
 5 files changed, 93 insertions(+), 37 deletions(-)

-- 
2.9.3

