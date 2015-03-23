Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065AbbCWQ4m convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 12:56:42 -0400
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
cc: dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] FS-Cache: Fixes for dead objects handling and operation cancellation
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 23 Mar 2015 16:56:37 +0000
Message-ID: <16262.1427129797@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Could you pull these FS-Cache fixes please?

The main thrust of the fixes are:

 (1) Handle a race between operation submission on an object (eg. reading data
     from that object) and the object transitioning to the dead state.  The
     race shows up as an assertion at fs/cachefiles/interface.c:339 indicating
     that the dead object still has operations queued against it.

 (2) Permit in-progress operations to be cancelled under some circumstances,
     otherwise we can unexpectedly see operations in progress on a killed
     object.  This shows up as an assertion on fs/fscache/operation.c:432.

 (3) Pass initialised ops through fscache_put_operation() rather than freeing
     them directly.  This allows better cleanup handling.

 (4) The cancellation method for an operation wasn't being called everwhere
     that was necessary, leaving the operation in an unclean state.  This
     shows up as an assertion at fs/fscache/page.c:261.

To help find and monitor these the patches also added better accounting for
operations and objects through /proc/fs/fscache/stats.  Are you okay with
these being left intertwined with the patches?

Also, do you want me to add these to the patches?

	Reviewed-by: Steve Dickson <steved@redhat.com>
	Acked-by: Jeff Layton <jeff.layton@primarydata.com>

Thanks,
David
---
The following changes since commit b2b89ebfc0f0287e20516a5443d93af309b800cf:

  Merge tag 'locks-v3.20-2' of git://git.samba.org/jlayton/linux (2015-02-18 10:21:47 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/fscache-fixes-20150226

for you to fetch changes up to bab9a8e45f7b5e917a8e976c37b23b46774e3642:

  FS-Cache: Retain the netfs context in the retrieval op earlier (2015-02-26 13:54:28 +0000)

----------------------------------------------------------------
FS-Cache fixes

----------------------------------------------------------------
David Howells (13):
      FS-Cache: Count culled objects and objects rejected due to lack of space
      FS-Cache: Move fscache_report_unexpected_submission() to make it more available
      FS-Cache: When submitting an op, cancel it if the target object is dying
      FS-Cache: Handle a new operation submitted against a killed object
      FS-Cache: Synchronise object death state change vs operation submission
      FS-Cache: fscache_object_is_dead() has wrong logic, kill it
      FS-Cache: Permit fscache_cancel_op() to cancel in-progress operations too
      FS-Cache: Out of line fscache_operation_init()
      FS-Cache: Count the number of initialised operations
      FS-Cache: Fix cancellation of in-progress operation
      FS-Cache: Put an aborted initialised op so that it is accounted correctly
      FS-Cache: The operation cancellation method needs calling in more places
      FS-Cache: Retain the netfs context in the retrieval op earlier

 Documentation/filesystems/caching/backend-api.txt |  23 ++
 Documentation/filesystems/caching/fscache.txt     |   7 +-
 fs/cachefiles/internal.h                          |   1 -
 fs/cachefiles/namei.c                             |  33 ++-
 fs/fscache/cookie.c                               |   8 +-
 fs/fscache/internal.h                             |  12 +-
 fs/fscache/object.c                               |  69 +++++-
 fs/fscache/operation.c                            | 254 ++++++++++++++--------
 fs/fscache/page.c                                 |  86 ++++----
 fs/fscache/stats.c                                |  14 +-
 include/linux/fscache-cache.h                     |  55 +++--
 11 files changed, 378 insertions(+), 184 deletions(-)
