Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49238 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750863AbdFSNYJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jun 2017 09:24:09 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 0/2 v5] Fixups for l_pid
Date: Mon, 19 Jun 2017 09:24:05 -0400
Message-Id: <cover.1497877897.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

LTP fcntl tests (fcntl11 fcntl14 fcntl17 fcntl19 fcntl20 fcntl21) have been
failing for NFSv4 mounts due to an unexpected l_pid.  What follows are some
fixups:

v2: - Rebase onto linux-next
    - Revert back to using the stack in locks_mandatory_area(), and fixup
	patch description for 1/3

v3: - The lkp-robot found some serious per_thread_ops performance
	regressions for v1 and v2, so this version changes things around to not
	acquire a reference to struct pid in fl_nspid for every lock.  Instead,
	it drops fl_nspid altogether, and defers the lookup of the
	namespace-translated pid until it actually needed.

v4: - Instead of looking up the virtual pid by way of referencing the struct
	task of the that pid, instead use find_pid_ns() and pid_nr_ns(), which
	avoids a the problem where we race to get a reference to the struct task
	while it may be freed.

v5: - Squash previous 2/3 and 3/3 to avoid regression where F_GETLK would
	return the init_ns pid instead of a translated pid.


Benjamin Coddington (2):
  fs/locks: Use allocation rather than the stack in fcntl_getlk()
  fs/locks: Remove fl_nspid and use fs-specific l_pid for remote locks

 fs/locks.c         | 116 ++++++++++++++++++++++++++++++++---------------------
 include/linux/fs.h |   2 +-
 2 files changed, 72 insertions(+), 46 deletions(-)

-- 
2.9.3

