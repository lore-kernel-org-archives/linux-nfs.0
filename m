Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:53425 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab0LIQsM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 11:48:12 -0500
Received: by gyb11 with SMTP id 11so1492648gyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 09 Dec 2010 08:48:12 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] RFC: Split nlm_host cache
To: linux-nfs@vger.kernel.org
Date: Thu, 09 Dec 2010 11:48:08 -0500
Message-ID: <20101209163555.4513.94435.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch series splits the nlm_host cache into a client-only and
server-only cache.  Originally this cache contained entries for both
client and server peers.

The garbage collection logic for this cache is convoluted.  The
purpose of GC in this cache is to prevent an nlm_host from vanishing
for a while, even if it's reference count is zero.  This is because no
reference is held between incoming NLM requests.  We want to keep
these entries around to reduce the overall expense of creating them.

However, GC is unnecessary on the client side, since the client holds
a reference to an nlm_host as long as it has the server mounted.
After unmounting, the nlm_host isn't needed.

Note that for NLM callbacks, there are already two entries in the
nlm_host cache for a peer, since a client lookup can't match if
h_server is asserted (and vice versa).

Splitting the nlm_host cache might allow further simplifications.
First, Bruce has suggested replacing the GC mechanism with a simpler
LRU scheme.  Another possibility would be to replace the hash tables
with red-black trees; this would take up less memory, and we would no
longer have to worry about the efficacy of the nlm_host hash function.

Comments?

---

Chuck Lever (9):
      lockd: Remove src_sap and src_len from nlm_lookup_host_info struct
      lockd: Remove nlm_lookup_host()
      lockd: Make nrhosts an unsigned long
      lockd: Rename nlm_hosts
      lockd: Clean up nlmsvc_lookup_host()
      lockd: Create client-side nlm_host cache
      lockd: Split nlm_release_call()
      lockd: Add nlm_destroy_host_locked()
      lockd: Add nlm_alloc_host()

J. Bruce Fields (2):
      lockd: reorganize nlm_host_rebooted
      lockd: define host_for_each{_safe} macros


 fs/lockd/clntlock.c         |    4 
 fs/lockd/clntproc.c         |   18 +-
 fs/lockd/host.c             |  404 ++++++++++++++++++++++++++-----------------
 fs/lockd/svc4proc.c         |   20 +-
 fs/lockd/svclock.c          |    4 
 fs/lockd/svcproc.c          |   28 ++-
 include/linux/lockd/lockd.h |    6 -
 7 files changed, 286 insertions(+), 198 deletions(-)

-- 
Chuck Lever
