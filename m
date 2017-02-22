Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36198 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933949AbdBVXg1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2017 18:36:27 -0500
Received: by mail-it0-f65.google.com with SMTP id w185so2811599ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2017 15:35:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org, neilb@suse.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/2] Fix up nfsd to enable NFSv4.x without NFSv4.0
Date: Wed, 22 Feb 2017 18:35:31 -0500
Message-Id: <20170222233533.23845-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch series was intended as a standalone series. However it now
aims to fix up a few issues with Neil's initial patch:

1) When the user turns off all minor versions of NFSv4, then that should
   be equivalent to turning off NFSv4 support, and so when someone tries
   to mount, we should return RPC_PROG_MISMATCH.
2) Allow the user to use either '4.0' or '4' in order to enable or disable
   minor version 0. Other minor versions remain enabled/disabled using the
   '4.x' format.
3) Fix up the display of the minor versions so that we don't add '4.0'.
   Previous kernels have always assumed the '4' means 'minor version 0',
   so there should be no need to have both.

v2: Make incremental to Neil's patch
    Fix up display of the version string

Trond Myklebust (2):
  nfsd: Allow enabling NFSv4.x without also requiring NFSv4.0
  nfsd: Fix display of the version string

 fs/nfsd/nfsctl.c | 72 ++++++++++++++++++++++++++------------------------------
 fs/nfsd/nfssvc.c | 14 +++++++++++
 2 files changed, 48 insertions(+), 38 deletions(-)

-- 
2.9.3

