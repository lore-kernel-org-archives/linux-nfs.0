Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54E65C43334
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jun 2022 14:12:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1357996AbiFVOMt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jun 2022 10:12:49 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:34226 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1357924AbiFVOMt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2022 10:12:49 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 713C438DBE;
        Wed, 22 Jun 2022 07:12:48 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 167AE61B8D;
        Wed, 22 Jun 2022 14:12:48 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 161FDC34114;
        Wed, 22 Jun 2022 14:12:47 +0000 (UTC)
Subject: [PATCH RFC 00/30] Overhaul NFSD filecache
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     david@fromorbit.com, tgraf@suug.ch, jlayton@redhat.com
Date:   Wed, 22 Jun 2022 10:12:45 -0400
Message-ID: <165590626293.75778.9843437418112335153.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This series overhauls the NFSD filecache, a cache of server-side
"struct file" objects recently used by NFS clients. The purposes of
this overhaul are an immediate improvement in cache scalability in
the number of open files, and preparation for further improvements.

There are three categories of patches in this series:

1. Add observability of cache operation so we can see what we're
doing as changes are made to the code.

2. Improve the scalability of filecache garbage collection,
addressing several bugs along the way.

3. Improve the scalability of the filecache hash table by converting
it to use rhashtable.

The series as it stands survives typical test workloads. Running
stress-tests like generic/531 is the next step.

These patches are also available in the linux-nfs-bugzilla-386
branch of

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git 

---

Chuck Lever (30):
      NFSD: Report filecache LRU size
      NFSD: Report count of calls to nfsd_file_acquire()
      NFSD: Report count of freed filecache items
      NFSD: Report average age of filecache items
      NFSD: Add nfsd_file_lru_dispose_list() helper
      NFSD: Refactor nfsd_file_gc()
      NFSD: Refactor nfsd_file_lru_scan()
      NFSD: Report the number of items evicted by the LRU walk
      NFSD: Record number of flush calls
      NFSD: Report filecache item construction failures
      NFSD: Zero counters when the filecache is re-initialized
      NFSD: Hook up the filecache stat file
      NFSD: WARN when freeing an item still linked via nf_lru
      NFSD: Trace filecache LRU activity
      NFSD: Leave open files out of the filecache LRU
      NFSD: Fix the filecache LRU shrinker
      NFSD: Never call nfsd_file_gc() in foreground paths
      NFSD: No longer record nf_hashval in the trace log
      NFSD: Remove lockdep assertion from unhash_and_release_locked()
      NFSD: nfsd_file_unhash can compute hashval from nf->nf_inode
      NFSD: Refactor __nfsd_file_close_inode()
      NFSD: nfsd_file_hash_remove can compute hashval
      NFSD: Remove nfsd_file::nf_hashval
      NFSD: Remove stale comment from nfsd_file_acquire()
      NFSD: Clean up "open file" case in nfsd_file_acquire()
      NFSD: Document nfsd_file_cache_purge() API contract
      NFSD: Replace the "init once" mechanism
      NFSD: Set up an rhashtable for the filecache
      NFSD: Convert the filecache to use rhashtable
      NFSD: Clean up unusued code after rhashtable conversion


 fs/nfsd/filecache.c | 677 +++++++++++++++++++++++++++-----------------
 fs/nfsd/filecache.h |   6 +-
 fs/nfsd/nfsctl.c    |  10 +
 fs/nfsd/trace.h     | 117 ++++++--
 4 files changed, 522 insertions(+), 288 deletions(-)

--
Chuck Lever

