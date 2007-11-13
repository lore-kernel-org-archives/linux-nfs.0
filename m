From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: linux-2.6.24-rc2-CITI_NFS4_ALL-1
Date: Tue, 13 Nov 2007 18:17:41 -0500
Message-ID: <E1Is50n-0002tK-Jo@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org
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

http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.24-rc2-1/linux-2.6.24-rc2-CITI_NFS4_ALL-1.diff

This is basically all the NFS-related stuff I know of that I have some
reason to believe might be ready for 2.6.25 (though not all of it's
really been reviewed yet).

I haven't seen a new patch series from Trond yet, so I'm probably
missing a lot of pending client-side stuff.

The biggest outstanding thing obviously is the server rdma and transport
switch code.

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

J. Bruce Fields (24):
      sunrpc: rpc_pipe_poll may miss available data in some cases
      sunrpc: document the rpc_pipefs kernel api
      knfsd: fix spurious EINVAL errors on first access of new filesystem
      nfsd4: recheck for secure ports in fh_verify
      nfsd: move callback rpc_client creation into separate thread
      knfsd: fix broken length check in nfs4idmap.c
      knfsd: fix cache.c comment
      knfsd: cleanup nfsd4 properly on module init failure
      nfsd: cleanup nfsd module initialization cleanup
      nfsd: fail module init on reply cache init failure
      nfsd: Fix handling of negative lengths in read_buf()
      knfsd: cache unregistration needn't return error
      nfsd: make separate function for registration of cache proc files
      nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
      nfsd: fail init on /proc/fs/nfs/exports creation failure
      knfsd: allow cache_register to return error on failure
      rdma: remove binary names for new rdma sysctls
      SUNRPC: allow gss callbacks to client
      knfsd: support callbacks with flavors other than AUTH_UNIX
      Fix compiler warning in server rdma code
      Merge branch 'nfs-client-stable'
      Merge branch 'gss-callback'
      Merge branch 'server-xprt-switch'
      Add CITI_NFS4_ALL version to kernel version number

Kevin Coffman (2):
      sunrpc: gss_pipe_downcall(), don't assume all errors are transient
      sunrpc: return error if unsupported enctype or cksumtype is encountered

Olga Kornievskaia (1):
      nfsd: pass client principal name in rsc downcall

Prasad P (1):
      Fix incorrect assignment

Tom Tucker (61):
      svc: Add an svc transport class
      svc: Make svc_sock the tcp/udp transport
      svc: Change the svc_sock in the rqstp structure to a transport
      svc: Add a max payload value to the transport
      svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
      svc: Add transport specific xpo_release_rqst function
      svc: Add per-transport delete functions
      svc: Add xpo_prep_reply_hdr
      svc: Add a transport function that checks for write space
      svc: Move close processing to a single place
      svc: Add xpo_accept transport function
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
      svc: Remove sk_lastrecv
      svc: Move the authinfo cache to svc_xprt.
      svc: Make deferral processing xprt independent
      svc: Move the sockaddr information to svc_xprt
      svc: Make svc_sock_release svc_xprt_release
      svc: Make svc_recv transport neutral
      svc: Make svc_age_temp_sockets svc_age_temp_transports
      svc: Move common create logic to common code
      svc: Removing remaining references to rq_sock in rqstp
      svc: Make svc_check_conn_limits xprt independent
      svc: Move the xprt independent code to the svc_xprt.c file
      svc: Add transport hdr size for defer/revisit
      svc: Add /proc/sys/sunrpc/transport files
      knfsd: Support adding transports by writing portlist file
      svc: Move setting of XPT_LISTENER bit to svc_tcp_init
      svc: Add a sockaddr length argument to the xpo_create function.
      svc: Remove extraneous debug svc_send printk
      svc: Modify svc_create_xprt to return local port
      svc: Add svc API that queries for a transport instance
      svc: Place type on same line for new API
      svc: Add xprt header len to svc_deferred_req
      svc: Change sockaddr to sockaddr_storage in svc_create_xprt
      svc: Fix bugs in svc_find_xprt
      knfsd: Modify write_ports to use svc_find_xprt service
      svc: Don't call xpo_free until after releasing auth data
      svc: bzero the xprt memory in svc_xprt_init
      svc: Restore rq_xprt_hlen in svc_deferred_recv
      svc: Fix skip computation in svc_defer and svc_revisit
      svc: svc_addsock needs to set the svc_xprt address
      svc: Add svc_xprt_names service to replace svc_sock_names
      svc: Move svc_xprt_received call to follow addition of xprt to list
      rdma: sysctl for SVCRDMA transport module
      rdma: SVCRMDA Header File
      rdma: SVCRDMA Transport Module
      rdma: SVCRDMA Core Transport Services
      rdma: SVCRDMA recvfrom
      rdma: SVCRDMA sendto
      rdma: ONCRPC RDMA protocol marshalling
      rdma: makefile
      rdma: Kconfig
