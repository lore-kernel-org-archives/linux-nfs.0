Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52784 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750992AbdE3Qbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 12:31:43 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org
Cc: Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] Fixups for l_pid
Date: Tue, 30 May 2017 12:31:37 -0400
Message-Id: <cover.1496161312.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

LTP fcntl tests (fcntl11 fcntl14 fcntl17 fcntl19 fcntl20 fcntl21) have been
failing for NFSv4 mounts due to an unexpected l_pid.  What follows are some
fixups:

on v2:
	- Rebase onto linux-next
	- Revert back to using the stack in locks_mandatory_area(), and fixup
	patch description for 1/3
	- Add a comment to 3/3 explaining the seemingly-redundant fl_pid and
	fl_nspid

These three patches can be pulled from the branch named "fixups_for_l_pid"
here: git://bcodding.com/~bcodding/linux

Benjamin Coddington (3):
  fs/locks: Use allocation rather than the stack in fcntl_getlk()
  fs/locks: Set fl_nspid at file_lock allocation
  fs/locks: Use fs-specific l_pid for remote locks

 fs/locks.c         | 100 ++++++++++++++++++++++++++++++++++-------------------
 include/linux/fs.h |   7 ++++
 2 files changed, 72 insertions(+), 35 deletions(-)

-- 
2.9.3

