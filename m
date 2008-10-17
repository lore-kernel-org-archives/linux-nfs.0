Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <48F8AC8A.1040304@RedHat.com>
Date: Fri, 17 Oct 2008 11:17:30 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Subject: nfs-utils-1.1.4 released.
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

As promised I just cut the 1.1.4 nfs-utils release. The tarball
can be found at all the usual places:

  http://www.kernel.org/pub/linux/utils/nfs/
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log:

commit c8d18e26d2a53d9036a32c2dafebccaf4ce1634d
Author: Phil Endecott <phil_bnaqb_endecott@chezphil.org>
Date:   Tue Oct 14 14:36:58 2008 -0400

    sm-notify should exit as soon as its determined
    there are no hosts to notify. This also decreases
    start up time by a few seconds.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fd705586d3ec76a5b324db151b87be1e4514f8af
Author: Mike Frysinger <vapier@gentoo.org>
Date:   Wed Oct 8 11:08:55 2008 -0400

    rpcgen: include sys/ioctl.h on linux systems
    
    The rpcgen tool included with nfs-utils will generate calls to ioctl() but not
    actually generate the sys/ioctl.h header include.  Attached patch should fix
    this.
    
    Signed-off-by: Mike Frysinger <vapier@gentoo.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4bd5ab69e5aa8bac905409eff111dbbc24581973
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Oct 8 10:59:53 2008 -0400

    nfs(5): Clarify behavior of the mountproto= and proto= options
    
    Document the interaction between the mountproto= and the proto= mount
    options in a new subsection of nfs(5).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 695906482ffc0c3778c3df765cf980d19da25414
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Oct 8 10:45:12 2008 -0400

    nfs-utils: make makesock() static
    
    Clean up:  The makesock() function can become static since it is only used in
    rpcmisc.c, where it is defined.  Fix some minor nits while we're in the area:
    
     o  Move it so we can remove it's forward declaration.
    
     o  Get rid of unneeded newlines in the xlog() format strings.
    
     o  Use htonl(INADDR_ANY) instead of INADDR_ANY to initialize sin_addr.
        Should make no run-time difference, but is slightly more proper,
        as the standard definition of INADDR_ANY is in host byte-order.
    
     o  Remove the parentheses in the "return" statements.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6e419afa493acc1c88fbc4d1a27bfb1784c1297a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Oct 8 10:42:41 2008 -0400

    nfs-utils: Clean up support/nfs/rpcmisc.c:closedown()
    
    Clean up: update closedown()'s synopsis to modern C style, and move the
    function so we can remove the forward declaration.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b803949b6e3025f231e325562ec729a7080af435
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Oct 1 14:36:25 2008 -0400

    Cleaned up the wording in the rpc.nfsd(8) manpage
    (BZ: https://bugzilla.linux-nfs.org/show_bug.cgi?id=159)
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a339207222ba3e31ad191b18af9f82d6a4ada0ee
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Oct 1 14:30:12 2008 -0400

    Cleared up a contradiction in the export(5) man page
    (BZ: https://bugzilla.linux-nfs.org/show_bug.cgi?id=161)
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6fdba8870cc40a2f40ed87c4b3563e8b29ad124c
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Sep 29 10:20:57 2008 -0400

    mountd: change "unknown host" error message to "unmatched host"
    
    mount request from unknown host 10.11.14.99 for /export
    
    The hosts are listed in DNS with proper reverse records, so the reason
    why the host is "unknown" isn't clear. This patch just changes the
    wording of this error to hopefully make it more clear why the mount
    request was rejected. This also makes this error message use a format
    more similar to the other error messages in auth_authenticate().
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8f1abb8ab1f7afcb9c2c0c094255d7e438b57b09
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Sep 29 07:52:40 2008 -0400

    nfs(5): Replace the term "netid" in mount option descriptions
    
    TI-RPC introduced the concept of "netid" which is a string that is
    mapped to a set of transport capabilities via a netconfig database.
    RPC services register a netid and bindaddr with their local rpcbind
    daemon to advertise their ability to support particular transports.
    
    Mike Eisler noted that the use of the term "netid" in nfs(5) is not
    appropriate, since Linux does not treat the value of the proto= or
    mountproto= options as a netid proper, but rather to select a
    particular transport capability provided locally on the client.
    
    The Linux NFS client currently uses a simple internal mapping between
    these names and its own transport capabilities rather than using the
    names as part of an rpcbind query, thus these strings are really not
    netids.  They are more akin to what TI-RPC calls "protocol names".
    
    Remove the term "netid" from nfs(5) for now.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Cc: Mike Eisler <mike.eisler@netapp.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4b3c476a3dd3a1fa7d6b1ff2a91406c30775208d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Sep 29 07:34:59 2008 -0400

    nfs(5): Replace the term "netid" in mount  option descriptions
    
    Mike Eisler noted that the use of the term "netid" in the descriptions
    of the "proto=" option is not appropriate, since Linux does not allow
    "udp6" or "tcp6".
    
    Replaced the term "netid" with "transport" in nfs(5).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Tom Talpey <Thomas.Talpey@netapp.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 572efae32f6fb311dff0e065d0d1dd527db60d0c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 16:16:09 2008 -0400

    rpc.statd: Stop overloading sockfd in utils/statd/rmtcall.c
    
    The Linux kernel's lockd requires that rpc.statd perform notification
    callbacks from a privileged source port.  To guarantee rpc.statd gets a
    privileged source port but runs unprivileged, it calls
    statd_get_socket() then drops root privileges before starting it's svc
    request processing loop.
    
    Statd's svc request loop is the only caller of the process_foo()
    functions in utils/statd/rmtcall.c, but one of them,
    process_notify_list() attempts to invoke statd_get_socket() again.
    
    In today's code, this is unneeded because statd_get_socket() is always
    invoked before my_svc_run().  However, if it ever succeeded, it would
    get an unprivileged source port anyway, causing the kernel to reject
    all subsequent requests from statd.
    
    Thus the process_notify_list() function should not ever call
    statd_get_socket() because root privileges have been dropped by this
    point, and statd_get_socket() wouldn't get a privileged source port,
    causing the kernel to reject all subsequent SM_NOTIFY requests.
    
    So all of the process_foo functions in utils/statd/rmtcall.c should use
    the global sockfd instead of a local copy, as it already has a
    privileged source port.
    
    I've seen some unexplained behavior where statd starts making calls to
    the kernel via an unprivileged port.  This could be one way that might
    occur.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7bc7c11507c853b8835e9f2ad758b8958c5607af
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 16:14:49 2008 -0400

    rpc.statd: Use __func__ in dprintf
    
    Clean up: The named function in many of the debugging messages in
    utils/statd/rmtcall.c is out of date.  To prevent this from happening
    in the future, replace these with __func__.
    
    Also, note() and dprintf() do not require a terminating '\n' in their
    format string.  So make all invocations consistent.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9b13713fa592b02da0dc79c5505fdf7002155d13
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 16:13:45 2008 -0400

    rpc.statd: Clean up: replace "if (!(foo = rtnl))".
    
    Static code checkers flag this kind of thing because it's easy to
    confuse with "if (!(foo == rtnl))".  In one of these cases, the
    combination of evaluation and assignment isn't even necessary.
    
    While we are in the neighborhood, remove an extra argument to note() that is
    not called for in the passed-in format string.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2fd04076023d696e5e7ffa17998e9d32990e57bf
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 16:12:49 2008 -0400

    nfs-utils: whitespace clean ups in support/nfs/rpcmisc.c
    
    Clean up: fix a few spurious white space issues in support/nfs/rpcmisc.c.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ec2e72c3e6f13dfa049598427c56115f1cbed16c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 16:11:57 2008 -0400

    nfs-utils: Remove excess log reporting
    
    Clean up: The makesock() function already reports an error if it can't
    create a socket.  Remove the redundant error check and logging done in
    rpc_init() after a makesock() call.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 173f4c79c08a947742970a5e12d529249c2c3631
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 16:10:48 2008 -0400

    nfs-utils: make makesock() static
    
    Clean up:  The makesock() function can become static since it is only used in
    rpcmisc.c, where it is defined.  Fix some minor nits while we're in the area:
    
     o  Move it so we can remove it's forward declaration.
    
     o  Get rid of unneeded newlines in the xlog() format strings.
    
     o  Use htonl(INADDR_ANY) instead of INADDR_ANY to initialize sin_addr.
        Should make no run-time difference, but is slightly more proper,
        as the standard definition of INADDR_ANY is in host byte-order.
    
     o  Remove the parentheses in the "return" statements.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7de004227d2a95ac10a591a68f95057a242d8dc0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 16:03:27 2008 -0400

    showmount: destroy RPC client when finished
    
    Clean up: call clnt_destroy() in the showmount command as needed to
    destroy the RPC client properly (and close the associated socket) before
    the program exits.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a663cf4c59e9b4fa56d8ca976c582ccf929140d2
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:28:10 2008 -0400

    nfs-utils: remove disabled code from support/nfs/rpcmisc.c
    
    After some recent discussions, we want to rely on the kernel's network
    layer to autotune socket buffers.  Since this code is already disabled in
    support/nfs/rpcmisc.c (and has been for some time), let's just remove it.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 06d0b0c9d3f1727d6a7f51d9edd7c3e7c38a293a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:27:23 2008 -0400

    nfs-utils: Remove unused function rpc_svcrun()
    
    Clean up: remove function that has been disabled (via #if 0) for almost a
    decade.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7e76a0509947d9b906f25cf762b0aac1a3281809
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:26:23 2008 -0400

    nfs-utils: remove unused function rpc_logcall()
    
    Clean up: Eliminate rpc_logcall(), which has no callers.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 69620a042d1151871a31f07ccd210b2dab49c628
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:25:19 2008 -0400

    sm-notify command: use static function definitions
    
    Clean up.
    
    The sm-notify command is built from a single source file.
    Some of its internal functions are appropriately defined as static.
    
    However, some are declared static, but defined as global.  Some are
    declared and defined as global.  None of them are used outside of
    utils/statd/sm-notify.c.
    
    Make all the internal functions in utils/statd/sm-notify.cstatic.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 93e355bf3a07b7565d88c1139ff24d1eb4f0a275
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:24:24 2008 -0400

    sm-notify command: replace nsm_address typedef
    
    Clean up: replace "typedef struct sockaddr_storage nsm_address" with
    standard socket address types.  This makes sm-notify.c consistent with other
    parts of nfs-utils, and with typical network application coding conventions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7862a784c2990b1f5330959d30069a637a041715
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:23:18 2008 -0400

    sm-notify command: clean up error logging
    
    Clean up a few issues with logging in sm-notify.c.
    
    Sometimes in sm-notify, when a system call fails the problem is reported
    to stderr but not logged, and then usually sm-notify exits.  In cases like
    this, there are probably more hosts to notify, but sm-notify dies silently.
    
    Make sure these errors are logged, and that the log messages explain the
    nature of the problem.
    
    Also, if sm-notify exits prematurely, make sure this is always reported at
    the LOG_ERR level, not at the LOG_WARNING level.
    
    Remove a couple of unnecessary '\n' in the arguments of nsm_log() calls --
    nsm_log() already appends an '\n' to the message.
    
    Finally, use exit() consistently in main().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e36a9e8af8bba0ff661da3c8dc0656bfe9952767
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:21:43 2008 -0400

    sm-notify command: getaddrinfo(3) addrinfo leak
    
    Make sure the results of getaddrinfo(3) are properly freed in notify().
    
    Note this is a one-time addrinfo allocation that would be automatically
    freed when sm-notify exits anyway, so this is more of a nit than a real
    bug fix.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 37130ec4041bd703d706207d77b4398ea252be5a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:20:49 2008 -0400

    sm-notify command: include <config.h>
    
    Clean up: Include config.h as other source files do; instead of using
    "config.h" use the HAVE_CONFIG_H macro and include <config.h>.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 44d18e8887cd2fdcf4996ddcbb827ed19aca8b2d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 13:18:11 2008 -0400

    showmount command: clean up error returns from connect_nb()
    
    Clean up connect_nb() in the showmount command.
    
    Sometimes it returns -1 on error, and sometimes a negative errno.  On error,
    it should always return one of these or the other, not both.
    
    Similar functions in other parts of nfs-utils return -1 on error, and set
    errno; so let's do that here too.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 18c6c616e07ec4fcd27108d87b6f02280d9687d6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 12:42:45 2008 -0400

    rpc.statd: eliminate --secure_statd
    
    Clean up: Remove RESTRICTED_STATD to help make IPv6 changes simpler.
    We keep the code behind RESTRICTED_STATD, and toss anything that is
    compiled out when it is set.
    
    RESTRICTED_STATD was added almost 10 years ago in response to CERT
    CERT CA-99.05, which addresses exposures in rpc.statd that might allow
    an attacker to take advantage of buffer overflows in rpc.statd while it
    is running in privileged mode.
    
    These days, I can't think of a reason why anyone would want to run
    rpc.statd without setting RESTRICTED_STATD.  In addition, I don't
    think rpc.statd is ever tested without it.
    
    Removing RESTRICTED_STATD will get rid of some address storage and
    comparison issues that will make IPv6 support simpler.  Plus it will
    make our test matrix smaller!
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Acked-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4ac04d76dc0fffe48313d6a16b4ca9b44c135818
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Sep 26 12:39:13 2008 -0400

    rpc.tatd: refactor check to see if call is from	loopback address
    
    Refactor common logic to check if SM_FOO request is from loopback
    address.
    
    We'll have to do something about this for IPv6.  On IPv6-capable
    systems, there will be only one AF_INET6 listener.  The loopback caller
    will get either an IPv6 loopback address, or a mapped IPv4 loopback --
    either way this will be an AF_INET6 address.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Acked-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 92e4d5c342f15940362fc2b2df19df0893f0dd13
Author: Neil Brown <neilb@suse.de>
Date:   Thu Aug 28 11:32:33 2008 -0400

    mount: enable retry for nfs23 to set the correct protocol for mount.
    
    Use a connected port when talking to portmap via UDP.
    
    This allows us to get ICMP errors reported back so we can avoid
    timeouts.  Also catch the error (RPC_CANTRECV) properly in getport.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 83a8da644b553680e9d578843a6fa0fc9347af0e
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Aug 28 11:25:29 2008 -0400

    Remove idmapd.conf
    
    The example idmapd.conf file is kept in libnfsidmap now, which is what's
    responsible for parsing it anyway.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 603017f2c1587d760e2649b889b581ca267ffee7
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Aug 28 11:23:05 2008 -0400

    Determine supported pseudoflavors from export
    
    Instead of using a static list of supported flavors, we should be taking
    the list from the export.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 60107345a32982bb0ff9eb8a17f8f0edf0276a98
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Aug 28 11:20:58 2008 -0400

    Minor mountd.c cleanup
    
    I find it more readable to have the normal (non-error) case unindented,
    and to keep conditionals relatively simple, as is the usual kernel
    style.  Fix some inconsistent indentation while we're there.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 124b74413e943ab9c02cdff2832d1d81dc9fda87
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Aug 28 11:17:34 2008 -0400

    Remove redundant m_path field
    
    Contrary to the comment above its definition, the field m_path always
    has the same value as e_path: the *only* modifications of m_path are all
    of the form:
    
    	strncpy(exp->m_export.m_path, exp->m_export.e_path,
    		sizeof (exp->m_export.m_path) - 1);
    	exp->m_export.m_path[sizeof (exp->m_export.m_path) - 1] = '\0';
    
    So m_path is always just a copy of e_path.  In places where we need to
    store a path to a submount of a CROSSMNT-exported filesystem, as in
    cache.c, we just use a local variable.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ec16220910f0bf1bf2b8e1d50e78df7da11d8b1e
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Aug 28 11:07:53 2008 -0400

    Stop exportfs warning about needing fsid, when we actually have one
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3a340251597a5b0c579c31d8caf9aa3b53a77016
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Aug 28 11:05:17 2008 -0400

    Use fsid from statfs for UUID if blkid can't cope (or not used)
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8d52fc2691783dc9ef5bd9d9a1fa4c0ec33b20bc
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Aug 28 10:56:57 2008 -0400

    Explicit UUID handling doesn't require blkid; factor out get_uuid_blkdev()
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0ae97c5b87a56870e74a74ae50aeb2ae0e496907
Author: David Woodhouse <David.Woodhouse@intel.com>
Date:   Thu Aug 28 10:29:54 2008 -0400

    Fix handling of explicit uuid
    
    Fix a couple of bugs which show up if you try to explicitly set a
    16-byte UUID when exporting a file system. First, exportfs cuts the
    first two bytes off the UUID and writes something invalid to etab.
    Second, mountd writes the _ascii_ form of the UUID to the kernel,
    instead of converting it to hex.
    
    Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 86c3a79a108091fe08869a887438cc2d4e1126ed
Author: Neil Brown <neilb@suse.de>
Date:   Wed Aug 27 16:30:19 2008 -0400

    mount issue with Mac OSX and --manage-gids, client hangs
    
    Make sure are zero len group list is sent down to the
    kernel when the gids do not exist on the server.
    
    Tested-by: Alex Samad <alex@samad.com.au>
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2d173a587a7dbee81ffaf246d044f384fb6487c8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jul 31 05:24:18 2008 -0400

    mount.nfs command: old glibc missing some flags
    
    Old versions of glibc (< 2.4) have a getaddrinfo(3) implementation, but
    do not include public definitions of the AI_V4MAPPED, AI_ALL, and
    AI_ADDRCONFIG flags because it was believed that these flags were not
    standardized.  However, these flags have standard definitions both in
    POSIX 1003 and in RFCs, and were thus included in later releases of
    glibc.
    
    To allow the mount.nfs command to build on systems with these older
    versions of glibc, add conditional definitions for these flags in
    utils/mount/network.c.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
