From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfs server patches for 2.6.25
Date: Fri, 25 Jan 2008 18:15:21 -0500
Message-ID: <20080125231521.GG25141@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Below is a summary of the nfs server patches which I expect to submit
(any day now) for 2.6.25; please let me know if you notice anything
wrong or missing.  I'll follow up to linux-nfs@vger.kernel.org with the
full list of patches.

The biggest changes come from Tom Tucker's rdma and server transport
switch patches, which Chuck Lever, Greg Banks, Neil Brown, and others
helped review (thanks!).  The rest is mostly bug fixes and cleanup.

As a reminder, you can see the patches I've got queued up any time from
the nfs-server-stable branch at:

	git://linux-nfs.org/~bfields/linux.git nfs-server-stable

--b.

Chuck Lever (9):
      SUNRPC: Prevent length underflow in read_flush()
      SUNRPC: Use unsigned string lengths in xdr_decode_string_inplace
      NLM: Fix sign of length of NLM variable length strings
      NFSD: Use unsigned length argument for decode_filename
      NFSD: File name length signage in nfsd request argument structures
      NFSD: Adjust filename length argument of nfsd_lookup
      NFSD: Use unsigned length argument for decode_pathname
      NFSD: Fix mixed sign comparison in nfs3svc_decode_symlinkargs
      NFSD: Path name length signage in nfsd request argument structures

Frank Filz (1):
      nfsd: Allow AIX client to read dir containing mountpoints

J. Bruce Fields (34):
      nfsd4: probe callback channel only once
      nfsd: move callback rpc_client creation into separate thread
      knfsd: fix broken length check in nfs4idmap.c
      knfsd: fix cache.c comment
      nfsd: Fix handling of negative lengths in read_buf()
      knfsd: cleanup nfsd4 properly on module init failure
      nfsd: cleanup nfsd module initialization cleanup
      nfsd: fail module init on reply cache init failure
      knfsd: cache unregistration needn't return error
      nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
      nfsd: fail init on /proc/fs/nfs/exports creation failure
      nfsd: move cache proc (un)registration to separate function
      knfsd: allow cache_register to return error on failure
      nfsd: move nfsd/auth.h into fs/nfsd
      nfsd: minor fs/nfsd/auth.h cleanup
      nfsd4: kill some unneeded setclientid comments
      nfsd: eliminate final bogus case from setclientid logic
      nfsd: uniquify cl_confirm values
      nfsd4: kill unnecessary same_name() in setclientid_confirm
      nfsd4: remove unnecessary cl_verifier check from setclientid_confirm
      nfsd4: kill unneeded cl_confirm check
      nfsd: fix encode_entryplus_baggage() indentation
      nfsd4: make current_clientid local
      nfsd4: miscellaneous nfs4state.c style fixes
      nfsd4: recognize callback channel failure earlier
      nfsd4: fix bad seqid on lock request incompatible with open mode
      nfsd: allow root to set uid and gid on create
      nfsd: fix rsi_cache reference count leak
      sunrpc: gss: simplify rsi_parse logic
      nfsd4: clean up access_valid, deny_valid checks.
      svcrpc: ensure gss DESTROY tokens free contexts from cache
      knfsd: don't bother mapping putrootfh enoent to eperm
      lockd: minor log message fix
      nfsd: more careful input validation in nfsctl write methods

Jeff Layton (4):
      SUNRPC: spin svc_rqst initialization to its own function
      SUNRPC: export svc_sock_update_bufs
      NLM: Convert lockd to use kthreads
      NLM: have nlm_shutdown_hosts kill off all NLM RPC tasks

Neil Brown (1):
      knfsd: change mailing list for nfsd in MAINTAINERS

Oleg Drokin (3):
      lockd: fix reference count leaks in async locking case
      lockd: fix a leak in nlmsvc_testlock asynchronous request handling
      Leak in nlmsvc_testlock for async GETFL case

Prasad P (1):
      Fix incorrect assignment

Tom Tucker (47):
      svc: Add an svc transport class
      svc: Make svc_sock the tcp/udp transport
      svc: Change the svc_sock in the rqstp structure to a transport
      svc: Add a max payload value to the transport
      svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
      svc: Add transport specific xpo_release function
      svc: Add per-transport delete functions
      svc: Add xpo_prep_reply_hdr
      svc: Add a transport function that checks for write space
      svc: Move close processing to a single place
      svc: Add xpo_accept transport function
      svc: Remove unnecessary call to svc_sock_enqueue
      svc: Move connection limit checking to its own function
      svc: Add a generic transport svc_create_xprt function
      svc: Change services to use new svc_create_xprt service
      svc: Change sk_inuse to a kref
      svc: Move sk_flags to the svc_xprt structure
      svc: Move sk_server and sk_pool to svc_xprt
      svc: Make close transport independent
      svc: Move sk_reserved to svc_xprt
      svc: Make the enqueue service transport neutral and export it.
      svc: Make svc_send transport neutral
      svc: Change svc_sock_received to svc_xprt_received and export it
      svc: Move accept call to svc_xprt_received to common code
      svc: Remove sk_lastrecv
      svc: Move the authinfo cache to svc_xprt.
      svc: Make deferral processing xprt independent
      svc: Move the sockaddr information to svc_xprt
      svc: Make svc_sock_release svc_xprt_release
      svc: Make svc_recv transport neutral
      svc: Make svc_age_temp_sockets svc_age_temp_transports
      svc: Move create logic to common code
      svc: Removing remaining references to rq_sock in rqstp
      svc: Make svc_check_conn_limits xprt independent
      svc: Move the xprt independent code to the svc_xprt.c file
      svc: Add transport hdr size for defer/revisit
      svc: Add /proc/sys/sunrpc/transport files
      svc: Add svc API that queries for a transport instance
      knfsd: Support adding transports by writing portlist file
      svc: Add svc_xprt_names service to replace svc_sock_names
      rdma: SVCRMDA Header File
      rdma: SVCRDMA Transport Module
      rdma: SVCRDMA Core Transport Services
      rdma: SVCRDMA recvfrom
      rdma: SVCRDMA sendto
      rdma: ONCRPC RDMA protocol marshalling
      rdma: makefile
