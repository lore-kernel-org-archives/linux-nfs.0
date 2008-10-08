From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd 2.6.28 merge plans
Date: Wed, 8 Oct 2008 19:22:37 -0400
Message-ID: <20081008232237.GH14527@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:55731 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754799AbYJHXWi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 19:22:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus's release announcement for -rc9 suggested 2.6.27 could be released
(and the 2.6.28 merge window opened) any day now.

What I'm currently planning to merge is the contents of

	git://linux-nfs.org/~bfields/linux.git for-2.6.28

summarized below.

Chuck's contributed a ton of small patches preparing for ipv6 support
(which we expect to complete in 2.6.29), Tom Tucker has added support
for fast memory registration to the server rdma code, and Benny's
NFSv4.1 work continues to produce miscellaneous NFSv4.1 bugfixes and
cleanups.

There's also one pure locking patch, which makes vfs support for posix
locking configurable.

And I've got some grace period patches (which I hope will also pave the
way for nfsd lock migration support in 2.6.29), and some minor tweaks to
our rpcsec_gss code which (together with recent nfs-utils patches)
finally makes rpcsec_gss for v2 and v3 work as well as it does for v4.

Thanks to everyone who's contributed!

--b.

Benny Halevy (9):
      nfsd: properly xdr-encode stateid4.seqid as uint32_t for cb_recall
      nfsd: properly xdr-encode deleg stateid returned from open
      nfsd: fix nfsd4_encode_open buffer space reservation
      nfsd: nfs4xdr encode_stateid helper function
      nfsd: don't declare p in ENCODE_SEQID_OP_HEAD
      nfsd: properly xdr-decode NFS4_OPEN_CLAIM_DELEGATE_CUR stateid
      nfsd: nfs4xdr decode_stateid helper function
      nfsd: do_probe_callback should not clear rpc stats
      nfsd: use nfs client rpc callback program

Chuck Lever (32):
      SUNRPC: Add address family field to svc_serv data structure
      SUNRPC: Use proper INADDR_ANY when setting up RPC services on IPv6
      SUNRPC: Set V6ONLY socket option for RPC listener sockets
      SUNRPC: Simplify rpcb_register() API
      SUNRPC: Split portmap unregister API into separate function
      SUNRPC: Support IPv6 when registering kernel RPC services
      NLM: Clean up before introducing new debugging messages
      lockd: address-family independent printable addresses
      lockd: Specify address family for source address
      lockd: Add address family-agnostic helper for zeroing the port number
      SUNRPC: Make svc_addr's argument a constant
      lockd: Use sockaddr_storage + length for h_addr field
      lockd: Use sockaddr_storage for h_saddr field
      NSM: Use sockaddr_storage for sm_addr field
      lockd: Teach nlm_cmp_addr() to support AF_INET6 addresses
      lockd: Support AF_INET6 when hashing addresses in nlm_lookup_host
      lockd: Combine __nsm_find() and nsm_find().
      lockd: Update nsm_find() to support non-AF_INET addresses
      SUNRPC: Register both netids for AF_INET6 servers
      SUNRPC: Use short-hand IPv6 ANYADDR for RPCB_SET
      SUNRPC: Fix up svc_unregister()
      SUNRPC: Clean up debug messages in rpcb_clnt.c
      NLM: Convert nlm_lookup_host() to use a single argument
      lockd: Support non-AF_INET addresses in nlm_lookup_host()
      lockd: Adjust nlmclnt_lookup_host() signature to accomodate non-AF_INET
      lockd: Adjust nlmsvc_lookup_host() to accomodate AF_INET6 addresses
      lockd: change nlmclnt_grant() to take a "struct sockaddr *"
      lockd: Add helper to sanity check incoming NOTIFY requests
      lockd: Remove unused fields in the nlm_reboot structure
      NLM: Always start both UDP and TCP listeners
      NLM: Remove "proto" argument from lockd_up()
      NLM: Remove unused argument from svc_addsock() function

J. Bruce Fields (7):
      nfsd: permit unauthenticated stat of export root
      locks: allow lockd to process blocked locks during grace period
      lockd: don't depend on lockd main loop to end grace
      nfsd: common grace period control
      lockd: move grace period checks to common code
      lockd: reject reclaims outside the grace period
      Merge branch 'from-tomtucker' into for-2.6.28

Jeff Layton (1):
      knfsd: allocate readahead cache in individual chunks

Thomas Petazzoni (1):
      Configure out file locking features

Tom Tucker (10):
      svcrdma: Add Fast Reg MR Data Types
      svcrdma: Add FRMR get/put services
      svcrdma: Query device for Fast Reg support during connection setup
      svcrdma: Add a service to register a Fast Reg MR with the device
      svcrdma: Modify post recv path to use local dma key
      svcrdma: Add support to svc_rdma_send to handle chained WR
      svcrdma: Modify the RPC recv path to use FRMR when available
      svcrdma: Modify the RPC reply path to use FRMR when available
      svcrdma: Update svc_rdma_send_error to use DMA LKEY
      svcrdma: Fix IRD/ORD polarity

