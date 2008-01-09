From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] Remove per-lock-operation nlm_lookup_host() call
Date: Wed, 09 Jan 2008 12:20:03 -0500
Message-ID: <20080109171834.7067.54266.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:43531 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbYAIRUQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 12:20:16 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Re-post with Christoph's comments addressed.

Calling nlm_lookup_host() during each NLM operation is a lot of overhead.
The nlm_lookup_host() function grabs the nlm_host_mutex, serializing
NLM operations and generating extra CPU invalidations on SMP systems.

The nlm_lookup_host() function can also trigger nlm_host garbage
collection, and reorders the global nlm_host chain after every successful
nlm_host lookup, resulting in extraneous memory write traffic.

In addition, nlmclnt_proc() pokes around in the NFS inode and in the
NFS client's rpc_xprt struct, both of which are layering violations that
we can and should avoid.

The new architecture pins an nlm_host structure to each NFS client
superblock that has the "lock" mount option set.  The client passes
in the pinned nlm_host structure during each call to nlmclnt_proc().  NFS
client unmount processing "puts" the nlm_host so it can be garbage-
collected later.

By pinning an nlm_host for each mount point, we trade the overhead of
looking up or creating a fresh nlm_host struct during every NLM procedure
call for a little extra memory space utilization.

Please consider these patches for 2.6.25.

Sidebar: there are only a few remaining references to the internals of
NFS inodes in the client-side NLM code.  The only references I found are
related to extracting or comparing the inode's file handle via NFS_FH().
One is in nlmclnt_grant(); the other is in nlmclnt_setlockargs().

-- 
corporate:    <chuck dot lever at oracle dot com>
