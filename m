Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:34923 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbHEVNn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:43 -0400
Received: by ykcq64 with SMTP id q64so41663639ykc.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:42 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 00/18] nfsd: open file caching for v2/3
Date: Wed,  5 Aug 2015 17:13:18 -0400
Message-Id: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- changelog cleanups and clarifications
- allow COMMIT to use cached open files
- tracepoints for nfsd_file cache
- proactively close open files prior to REMOVE, or a RENAME over a
  positive dentry

This is the v2 set of this series. It's a little larger than the v1
series, but adds a bit more functionality.

The last several patches you may be less-inclined to take. Since one of
our use-cases is a reexporter for NFS, we want to avoid triggering
sillyrenames when possible. Closing files proactively prior to a
REMOVE or RENAME is something we want to do. I'm less sure however
whether it's something you'll want to bother with for more general uses.
Your call there.

I'd still like to see this merged for v4.3 if possible.

Original cover letter follows:

---------------------[snip]------------------------

Hi Bruce!

This patchset adds a new open file cache for knfsd. As you well know,
nfsd basically does an open() - read/write() - close() cycle for every
nfsv3 READ or WRITE. It's also common for clients to "spray" several
read and write requests in parallel or in quick succession, so we could
skip a lot of that by simply caching these open filps.

The idea here is to cache them in a hashtable for a little while (1s by
default) in the expectation that clients may try to issue more reads or
writes in quick succession. When there are any entries in the hashtable,
there is a recurring workqueue job that will clean the cache.

I've also added some hooks into sunrpc cache code that should allow us
to purge the cache on an unexport event, so this shouldn't cause any
problems with unmounting once you've unexported the fs.

I did a little testing with it, but my test rig is pretty slow, and I
couldn't measure much of a performance difference on a bog standard
local fs.

We do have some patches that allow the reexporting of NFSv4.1 via knfsd.
Since NFS has a relatively slow open routine, this provides a rather
large speedup.

Without these patches:
$ dd if=/dev/urandom of=/mnt/dp01/ddfile bs=4k count=256 oflag=direct
256+0 records in
256+0 records out
1048576 bytes (1.0 MB) copied, 54.3109 s, 19.3 kB/s

With these patches:
$ dd if=/dev/urandom of=/mnt/dp01/ddfile bs=4k count=256 oflag=direct
256+0 records in
256+0 records out
1048576 bytes (1.0 MB) copied, 1.05437 s, 995 kB/s

It should also be possible to hook this code up to the nfs4_file too,
but I haven't done that in this set. I'd like to get this in and settled
before we start looking at that, since it'll mean a bit of reengineering
of the NFSv4 code not to pass around struct file pointers.

I'd like to have these considered for the v4.3 merge window if they look
reasonable.

Jeff Layton (18):
  nfsd: include linux/nfs4.h in export.h
  nfsd: move some file caching helpers to a common header
  nfsd: convert laundry_wq to something less nfsd4 specific
  nfsd: add a new struct file caching facility to nfsd
  nfsd: hook up nfsd_write to the new nfsd_file cache
  nfsd: hook up nfsd_read to the nfsd_file cache
  sunrpc: add a new cache_detail operation for when a cache is flushed
  nfsd: add a ->flush routine to svc_export_cache
  nfsd: allow the file cache expire time to be tunable
  nfsd: handle NFSD_MAY_NOT_BREAK_LEASE in open file cache
  nfsd: hook nfsd_commit up to the nfsd_file cache
  nfsd: move include of state.h from trace.c to trace.h
  nfsd: add new tracepoints for nfsd_file cache
  nfsd: have _fh_update take a knfsd_fh instead of a svc_fh
  nfsd: have set_version_and_fsid_type take a knfsd_fh instead of svc_fh
  nfsd: add a fh_compose_shallow
  nfsd: close cached files prior to a REMOVE or RENAME that would
    replace target
  nfsd: call flush_delayed_fput from nfsd_file_close_fh

 fs/file_table.c              |   1 +
 fs/nfsd/Makefile             |   3 +-
 fs/nfsd/export.c             |  14 ++
 fs/nfsd/export.h             |   1 +
 fs/nfsd/filecache.c          | 451 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/filecache.h          |  51 +++++
 fs/nfsd/nfs3proc.c           |   2 +-
 fs/nfsd/nfs4state.c          |  40 +---
 fs/nfsd/nfsd.h               |   1 +
 fs/nfsd/nfsfh.c              | 139 ++++++-------
 fs/nfsd/nfsfh.h              |   2 +
 fs/nfsd/nfsproc.c            |   2 +-
 fs/nfsd/nfssvc.c             |  22 ++-
 fs/nfsd/trace.c              |   2 -
 fs/nfsd/trace.h              | 126 ++++++++++++
 fs/nfsd/vfs.c                | 146 ++++++++------
 fs/nfsd/vfs.h                |   3 +-
 include/linux/sunrpc/cache.h |   1 +
 net/sunrpc/cache.c           |   3 +
 19 files changed, 851 insertions(+), 159 deletions(-)
 create mode 100644 fs/nfsd/filecache.c
 create mode 100644 fs/nfsd/filecache.h

-- 
2.4.3

