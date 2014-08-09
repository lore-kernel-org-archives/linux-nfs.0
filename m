Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:51792 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658AbaHIOWw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Aug 2014 10:22:52 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so6539664qaj.21
        for <linux-nfs@vger.kernel.org>; Sat, 09 Aug 2014 07:22:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] nfsd: lease handling cleanups
Date: Sat,  9 Aug 2014 10:22:39 -0400
Message-Id: <1407594162-28342-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset represents some small-ish lease-handling cleanups. In
particular, it moves the vfs_setlease F_UNLCK call out from under any
spinlocks, which is necessary for eventually allowing ->setlease methods
to block.

These aren't strictly bugfixes, so they can probably wait until v3.18
if needed.

Jeff Layton (3):
  nfsd: protect lease-related nfs4_file fields with fi_lock
  nfsd: call nfs4_put_deleg_lease outside of state_lock
  nfsd: allow find_any_file to return a fi_deleg_file reference

 fs/nfsd/nfs4state.c | 45 +++++++++++++++++++++++++++++++--------------
 1 file changed, 31 insertions(+), 14 deletions(-)

-- 
1.9.3

