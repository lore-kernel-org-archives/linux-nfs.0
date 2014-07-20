Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0187.hostedemail.com ([216.40.44.187]:47238 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752463AbaGTSXu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Jul 2014 14:23:50 -0400
From: Joe Perches <joe@perches.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, David Teigland <teigland@redhat.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Christine Caulfield <ccaulfie@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        cluster-devel@redhat.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH 0/9] fs.h/dlm: Neatening and argument removals
Date: Sun, 20 Jul 2014 11:23:34 -0700
Message-Id: <cover.1405879494.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs.h is an important file read by many.

Because of its age and the number of people that have modified it,
it's not particularly kernel coding style conformant.

Make it more so.

dlm has an unnecessary always NULL argument passed around.
Remove it along with some other neatenings while adding
function prototype argument descriptions.

Joe Perches (9):
  fs.h: Remove unnecessary extern prototypes
  fs.h: Whitespace neatening
  fs.h: A few more whitespace neatenings
  fs.h: Add argument names to struct file_lock_operations (*funcs)
  fs.h: Add member argument descriptions to lock_manager_operations
  dlm: plock: Add argument descriptions to notiy
  dlm: fs: Remove unused conf from lm_grant
  dlm: plock: Reduce indentation by rearranging order
  fs: dlm: lockd: Convert int result to unsigned char type

 fs/dlm/plock.c     |   34 +-
 fs/lockd/svclock.c |   16 +-
 include/linux/fs.h | 1201 ++++++++++++++++++++++++++--------------------------
 3 files changed, 627 insertions(+), 624 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

