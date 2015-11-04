Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965613AbbKDPUK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 10:20:10 -0500
Subject: [PATCH 0/4] FS-Cache: Miscellaneous fixes
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cachefs@redhat.com,
        linux-kernel@vger.kernel.org
Date: Wed, 04 Nov 2015 15:20:05 +0000
Message-ID: <20151104152005.2987.46683.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Attached are a number of fixes for bugs in FS-Cache and CacheFiles:

 (1) Fix refcounting of parent of netfs index during registration.

 (2) Only set primary index cookie of netfs if registration successful.

 (3) Check block size of backing filesystem is suitable in CacheFiles.

 (4) Fix off-by-one error in checking store limit when writing a page to
     cache.

These can also be found here:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache-fixes

tagged with:

	fscache-fixes-20151104

David
---
David Howells (1):
      FS-Cache: Handle a write to the page immediately beyond the EOF marker

Kinglong Mee (2):
      FS-Cache: Increase reference of parent after registering, netfs success
      FS-Cache: Don't override netfs's primary_index if registering failed

NeilBrown (1):
      cachefiles: perform test on s_blocksize when opening cache file.


 fs/cachefiles/namei.c |    2 +
 fs/cachefiles/rdwr.c  |   73 +++++++++++++++++++++++++------------------------
 fs/fscache/netfs.c    |   38 ++++++++++++--------------
 fs/fscache/page.c     |    2 +
 4 files changed, 58 insertions(+), 57 deletions(-)

