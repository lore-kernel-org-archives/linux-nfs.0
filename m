Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36639 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098Ab0JUQXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 12:23:07 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1P8xv0-0002Up-Ep
	for linux-nfs@vger.kernel.org; Thu, 21 Oct 2010 12:23:06 -0400
Date: Thu, 21 Oct 2010 12:23:06 -0400
To: linux-nfs@vger.kernel.org
Subject: 2.6.37 nfsd changes
Message-ID: <20101021162306.GA9537@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The changes I've already committed for the 2.6.37 submission are
available from

	git://linux-nfs.org/~bfields/linux.git for-2.6.37

(summary below).  I'm also hoping to sneak in some more sessions
patches, but the merge window is opened, so I'll submit this to Linus
soon.

Any testing of that branch is appreciated; it passes all my usual tests,
so hopefully it's not too hairy.

--b.

Andy Adamson (1):
      nfsd: remove duplicate NFS4_STATEID_SIZE declaration

Andy Shevchenko (1):
      sunrpc/cache: don't use custom hex_to_bin() converter

Benny Halevy (1):
      nfsd4: adjust buflen for encoded attrs bitmap based on actual bitmap length

Bryan Schumaker (1):
      lockd: Mostly remove BKL from the server

Chuck Lever (2):
      SUNRPC: Use conventional switch statement when reclassifying sockets
      SUNRPC: Properly initialize sock_xprt.srcaddr in all cases

J. Bruce Fields (23):
      svcrpc: minor cache cleanup
      svcrpc: cache deferral cleanup
      Merge remote branch 'trond/bugfixes' into for-2.6.37
      nfsd4: fix hang on fast-booting nfs servers
      nfsd: fix /proc/net/rpc/nfsd.export/content display
      nfsd4: remove spkm3
      nfsd4: minor variable renaming (cb -> conn)
      nfsd4: combine nfs4_rpc_args and nfsd4_cb_sequence
      nfsd4: rename nfs4_rpc_args->nfsd4_cb_args
      nfsd4: generic callback code
      nfsd4: use generic callback code in null case
      nfsd4: remove separate cb_args struct
      nfsd4: Move callback setup to callback queue
      nfsd4: fix alloc_init_session BUILD_BUG_ON()
      nfsd4: fix alloc_init_session return type
      nfsd4: clean up session allocation
      nfsd4: keep per-session list of connections
      nfsd: provide callbacks on svc_xprt deletion
      nfsd4: use callbacks on svc_xprt_deletion
      nfsd4: refactor connection allocation
      nfsd4: add new connections to session
      nfsd4: return expired on unfound stateid's
      nfsd4: expire clients more promptly

NeilBrown (14):
      sunrpc: extract some common sunrpc_cache code from nfsd
      sunrpc: use seconds since boot in expiry cache
      sunrpc/cache: allow threads to block while waiting for cache update.
      sunrpc: close connection when a request is irretrievably lost.
      nfsd: disable deferral for NFSv4
      nfsd/idmap: drop special request deferal in favour of improved default.
      svcauth_gss: replace a trivial 'switch' with an 'if'
      sunrpc/cache: change deferred-request hash table to use hlist.
      sunrpc/cache: fix recent breakage of cache_clean_deferred
      nfsd: formally deprecate legacy nfsd syscall interface
      nfsd: allow deprecated interface to be compiled out.
      sunrpc: fix race in new cache_wait code.
      sunrpc: Simplify cache_defer_req and related functions.
      sunrpc/cache: centralise handling of size limit on deferred list.

Pavel Emelyanov (37):
      nfsd: Export get_task_comm for nfsd
      sunrpc: Pass the ip_map_parse's cd to lower calls
      sunrpc: Make xprt auth cache release work with the xprt
      sunrpc: Pass xprt to cached get/put routines
      sunrpc: Add net to pure API calls
      sunrpc: Add routines that allow registering per-net caches
      sunrpc: Tag svc_xprt with net
      sunrpc: The per-net skeleton
      sunrpc: Make the /proc/net/rpc appear in net namespaces
      sunrpc: Make the ip_map_cache be per-net
      sunrpc: Factor out rpc_xprt allocation
      sunrpc: Factor out rpc_xprt freeing
      sunrpc: Add net argument to svc_create_xprt
      sunrpc: Pull net argument downto svc_create_socket
      sunrpc: Add net to rpc_create_args
      sunrpc: Add net to xprt_create
      sunrpc: Tag rpc_xprt with net
      net: Export __sock_create
      sunrpc: Create sockets in net namespaces
      sunrpc: Use helper to set v4 mapped addr in ip_map_parse
      sunrpc: Remove unused sock arg from xs_get_srcport
      sunrpc: Remove unused sock arg from xs_next_srcport
      sunrpc: Get xprt pointer once in xs_tcp_setup_socket
      sunrpc: Remove duplicate xprt/transport arguments from calls
      sunrpc: Factor out udp sockets creation
      sunrpc: Factor out v4 sockets creation
      sunrpc: Factor out v6 sockets creation
      sunrpc: Call xs_create_sockX directly from setup_socket
      sunrpc: Merge the xs_bind code
      sunrpc: Merge xs_create_sock code
      sunrpc: Pass family to setup_socket calls
      sunrpc: Remove TCP worker wrappers
      sunrpc: Remove UDP worker wrappers
      sunrpc: Remove useless if (task == NULL) from xprt_reserve_xprt
      sunrpc: Don't return NULL from rpcb_create
      sunrpc: Remove dead "else" branch from bc xprt creation
      sunrpc: Turn list_for_each-s into the ..._entry-s

Stephen Rothwell (1):
      sunrpc: fix up rpcauth_remove_module section mismatch

Tejun Heo (1):
      sunrpc/xprtrdma: clean up workqueue usage

Tom Tucker (2):
      svcrdma: Change DMA mapping logic to avoid the page_address kernel API
      svcrdma: Cleanup DMA unmapping in error paths.

