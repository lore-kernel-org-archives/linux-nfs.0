Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42554 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbZCEMzI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Mar 2009 07:55:08 -0500
Message-ID: <49AFCB01.10701@RedHat.com>
Date: Thu, 05 Mar 2009 07:52:17 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Subject: nfs-utils-1.1.5 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is a maintenance release along with a number IPv6 enablers 
such as the new "--enable-tirpc" configuration flag
that will enable the used of RPC code in libtirpc 
instead of the glibc RPC code.
 
The tarball can be found at:

  http://www.kernel.org/pub/linux/utils/nfs/
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log:

commit d201426838f6cd02e52e7e841901fa92a20e74f1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 5 06:23:25 2009 -0500

    gssd: include gssapi/gssapi.h before write_bytes.h
    
    In gssd/context_lucid.c, ensure that gss_buffer_desc and gss_OID_desc
    are defined before write_bytes.h, which uses these definitions, is
    included.  With TI-RPC, these definitions are not provided by
    rpc/rpc.h.
    
    It appears that <gssapi/gssapi_krb5.h> already includes krb5.h and
    gssapi.h (on my system, anyway) so let's drop those includes.
    
    Ideally write_bytes.h itself should include the needed headers, but
    some source files that use Heimdal include a different, Heimdal-
    compatible, header to get these definitions.
    
    Pointed-out-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d78a45a152d2270b6e92b451b6b4585567ec2f8a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 5 06:22:31 2009 -0500

    gssd: Use same style for including config.h that rest of nfs-utils uses
    
    Clean up.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e0e72c9ee9bbbf6bb10b76a33f1259aeaa4a8f61
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 5 06:21:34 2009 -0500

    mount.nfs: squelch compiler warning for TI-RPC builds
    
    The printf format string in nfs_pp_debug() assumes the @program and
    @version arguments are unsigned long, because the legacy RPC headers
    define both rpcprog_t and rpcvers_t as unsigned long types.
    
    However, the TI-RPC headers define both types as uint32_t, which
    requires a different printf format type.  If we replace the legacy
    headers with TI-RPC headers, this type mismatch generates compiler
    warnings that are nothing but noise.
    
    We are about to provide a switch at ./configure time to allow the use
    of either the legacy RPC headers or the TI-RPC headers, so we need
    a printf format that works in both cases.
    
    To squelch the compiler warnings that occur when using the TI-RPC
    headers, cast both arguments in the fprintf statement to the widest of
    the two types ("unsigned long" or "uint32_t").
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 27a49079b03316eebcbc74197b73988b01b58ecc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 5 06:20:40 2009 -0500

    nfs-utils: Provide type-checked version of svc_getcaller()
    
    TI-RPC's version of the svc_getcaller() macro points to a sockaddr_in6,
    not a sockaddr_in, though for AF_INET callers, an AF_INET address
    resides there.  To squelch compiler warnings when the TI-RPC version of
    the svc_req structure is used, add inline helpers with appropriate
    type casting.
    
    Note that tcp_wrappers support only AF_INET addresses for now.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5529fdbb4acb2507b79acf07e08c2a88c1df9e38
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 5 06:16:04 2009 -0500

    configure: Remove CPPFLAGS substitution
    
    At least on my systems, the AM_CPPFLAGS substitution at the end of
    configure.ac is not needed.  It adds an extra copy of
    "-I../../support/includes" to each compile step.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2f3c0dc6908f534341f4dd24c44dcfbea7c7b253
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Mar 5 06:13:33 2009 -0500

    nfs-utils: Replace getservbyname(3)
    
    The getservbyname(3) function is not re-entrant, and anyway,
    the man page says it is obsolete.  Replace it with a call
    to getaddrinfo(3).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 71cbf46e564621d4cd2af61c384a79b2c0174a36
Author: Valerie Aurora Henson <vaurora@redhat.com>
Date:   Wed Mar 4 17:53:41 2009 -0500

    Update example in exports(5) man page
    
    Signed-off-by: Valerie Aurora Henson <vaurora@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c8e40bc4a1a9f8e7c91ca909d553172b7a684a18
Author: Ben Greear <greearb@candelatech.com>
Date:   Wed Mar 4 17:07:55 2009 -0500

    Have sizeof using the correct value in nfs_getlocalport()
    
    Signed-off-by: Ben Greear <greearb@candelatech.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 882cf0a91b9df297b5ebe8c79a40478d3de4ae05
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 4 16:58:47 2009 -0500

    nfs-utils: Remove fprintf() call from support/nfs/getport.c
    
    getport.c is effectively a library, so it should not be emitting
    messages via printf.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ea85571bf87062790dfceb6a0eee3549c8890ad0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 4 16:31:10 2009 -0500

    showmount command: remove legacy RPC logic
    
    Turns out both legacy RPC and TI-RPC have a clnt_create(3) API.  So
    there's
    really no need to keep the old open-coded transport logic around.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0417c70889eb6ee8e009ceeeca398ea8e563bbcc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 4 16:29:29 2009 -0500

    nfs(5): document new [no]resvport option
    
    Kernel 2.6.25 deprecates intr/nointr.  Reflect this change in nfs(5).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 260eb781154f288055f42602aaa25b3f608404ea
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 4 16:27:36 2009 -0500

    nfs(5): document new [no]resvport option
    
    Kernel 2.6.28 adds a new mount option: [no]resvport.  Document the new
    option in the nfs(5) man page.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 20618b27acf6ff52f2654740ebf32516eb1ab1e0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 4 16:26:48 2009 -0500

    The legacy version of nfs_name_to_address() returned an incorrect
    value for the size of the returned address.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 38667906c89d6944faaced7fbcda027643dc10ad
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Mar 4 15:54:39 2009 -0500

    configure: fix AC_CACHE_VAL warnings on Fedora 10
    
    Autoconf 2.63 (and maybe earlier releases) complains about the cache
    variable name used in aclocal/libblkid.m4:
    
    configure.ac:217: warning: AC_CACHE_VAL(libblkid_is_recent, ...):
    suspicious cache-id, must contain _cv_ to be cached
    ../../lib/autoconf/general.m4:1974: AC_CACHE_VAL is expanded from...
    aclocal/libblkid.m4:2: AC_BLKID_VERS is expanded from...
    configure.ac:217: the top level
    
    This addresses
      https://bugzilla.redhat.com/attachment.cgi?bugid=481386 .
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9d1cf415ecf3466ca5c4cf518915e363d75a6a6e
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Mar 4 15:36:27 2009 -0500

    General clean up. Removed unused routines. Reworked syslog
    message to (hopefully) make it more sensible. Move
    "#ifdef HAVE_LIBWRAP" around so nothing will be defined
    when tcp wrapper is not configured.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ae8e7dbe9641dbc69c34bcede416f0d91612d3f1
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Mar 4 15:24:58 2009 -0500

    Converted good_client() to correctly use the tcp wrapper
    interface and added a note to the mountd man page saying
    hostnames will be ignored when they can not be looked up.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 681d340e682d95dd9fa6c120de2a24ddb155d581
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Mar 4 15:22:37 2009 -0500

    Only hash on IP address and Program number. Including the Procedure
    number only creates needles extra hash entries.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4cacc965afc4fb03a465ffcc6cb3078aeadc3818
Author: Tomas Richter <krik3t@gmail.com>
Date:   Wed Feb 18 13:33:27 2009 -0500

    Exportfs and rpc.mountd optimalization
    
    There were some problems with exportfs and rpc.mountd for long export
    lists - see https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=76643
    I do optimalization as my bachelors thesis (Facuulty of informatics,
    Masaryk's university Brno, Czech Republic), under lead of Yenya
    Kasprzak.
    
    Both exportfs and rpc.mount build linked list of exports (shared
    functions in export.c). Every time they are inserting new export into
    list, they search for same export in list.
    I replaced linked list by hash table and functions export_add and
    export_lookup by functions hash_export_add and hash_export_lookup
    (export.c).
    
    Because some other functions required exportlist as linked list, hash
    table has some implementation modification im comparison with ordinary
    hash table. It also keeps exports in linked list  and has pointer to
    head of the list. So there's no need of implementation function
    <for_all_in_hash_table>.
    
    Signed-off-by: Tomas Richter <krik3t@gmail.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 35001db4aaafa8a17e13b8c13cf74508d4a93f2f
Author: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date:   Wed Feb 18 07:48:11 2009 -0500

    rpc.idmapd should tell the user more verbosely if Dnotify
    support is missing in kernel.
    
    Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4f15bd6e3ebfebef16c1db61b28a98863c36cb81
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Feb 17 16:27:43 2009 -0500

    umount command: remove do_nfs_umount23 function
    
    Remove do_nfs_umount23() now that it is unused.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c735a8331b082038a0e83ec4187c2656b0804eea
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Feb 17 16:26:31 2009 -0500

    umount.nfs command: Support AF_INET6 server addresses
    
    Replace existing mount option parser in nfsumount.c with the new pmap
    stuffer
    function nfs_options2pmap().  Mount option parsing for umount.nfs now
    works
    the same as it does for mount option rewriting in the text-based
    mount.nfs
    command.
    
    This adds a number of new features:
    
      1.  The new logic supports resolving AF_INET6 server addresses
      2.  Support is added for the recently introduced "mountaddr" option.
      3.  Parsing numeric option values is much more careful
      4.  Option parsing no longer uses xmalloc/xstrdup, so it won't fail
          silently if memory can't be allocated
      5.  Mount program number set in /etc/rpc is respected
      6.  Mount doesn't exit with EX_USAGE if the hostname lookup fails
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 97de03f8c866b9d3e790d64f4e9ac24011aaa5b1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Feb 17 16:25:27 2009 -0500

    umount.nfs command: Add an AF_INET6-capable version of nfs_call_unmount()
    
    We need an AF_INET6-capable version of nfs_call_unmount() to allow the
    umount.nfs command to support unmounting NFS servers over IPv6.  The
    legacy
    mount.nfs command still likes to use nfs_call_umount(), so we leave it
    in
    place and introduce a new API that can take a "struct sockaddr *".
    
    The umount.nfs command will invoke this new API, but we'll leave the
    legacy
    mount.nfs command and the umount.nfs4 command alone.  The umount.nfs4
    command does not need this support because NFSv4 unmount operations are
    entirely local.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a68a1a85533142880a63c2de969db38118341c41
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Feb 17 16:22:53 2009 -0500

    nfs-utils: git should ignore cscope.* files
    
    Tell git to ignore cscope database files.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 52ec1b5fceece8f63b97afc6d6b78bfabff12669
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Feb 17 15:33:58 2009 -0500

    The mount sockaddr len (mnt_salen) is not be set in
    nfs_extract_server_addresses() which causes the mount.nfs
    command to segmentation fault when a NFS server only
    supports UDP mounts.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e7ec5e745e851ad10c56d579463ee7e1b85c9c21
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Feb 17 15:19:58 2009 -0500

    text-based mount command: fix return value from po_rightmost()
    
    Recently commit 0dcb83a8 changed the po_rightmost() function to
    distinguish among several possible mount options by taking a table
    containing the alternatives, and returning the table index of the
    entry which is rightmost in the mount option string.
    
    If it didn't find any mount option that matches an entry from the
    passed-in table, it returned zero.  This was the same behavior it had
    before, when it only checked for two options at a time.  It returned
    PO_NEITHER_FOUND, which was zero.
    
    Since this is C, however, zero also happens to be a valid index into
    the passed-in array of options.
    
    Modify the po_rightmost() function to return -1 if the entry wasn't
    found, and fix up the callers to look for a C-style array index that
    starts at zero.
    
    Thanks to Steve Dickson for troubleshooting the problem.  His solution
    was merely to bump the return value, as callers already expected an
    ordinal index instead of a C-style index.
    
    I prefer this equivalent but slightly more extensive change because it
    makes the behavior of po_rightmost() more closely match how humans
    understand C arrays to work.  Let's address some of the confusion that
    caused this bug, as well as fixing the run-time behavior.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1f0a104ff4aa07141d59cfd1d78157e8ddf7e4ed
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 27 17:48:17 2009 -0500

    text-based mount command: support AF_INET6 in	rewrite_mount_options()
    
    Now that we have an AF_INET6-capable probe_bothports(), we can support
    AF_INET6 when rewriting text-based NFS mount options.  This should be
    adequate to support NFS transport protocol and version negotiation with
    AF_INET6 NFS servers.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3163dabcf0a6b992859508368baf67c918d2c091
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 27 17:47:06 2009 -0500

    text-based mount command: fix mount option rewriting logic
    
    Fix a bunch of corner cases in the text-based mount option rewriting logic.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9d5ee403d5d4fd27ea41a674ca2e99ca1daa9f25
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 27 17:45:48 2009 -0500

    text-based mount options: Use new pmap stuffer when	rewriting mount options
    
    all nfs_options2pmap() in nfs_rewrite_mount_options() instead of
    open-coding the logic to convert mount options to a pmap struct.
    The new nfs_options2pmap() function is more careful about avoiding
    invalid mount option values, and handles multiply-specified transport
    protocol options correctly.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ff4f8ea366103d9b82cd2d9f8ced2426215d62b4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 27 17:43:29 2009 -0500

    text-based mount command: Function to stuff "struct pmap" from mount options
    
    Both the text-based mount.nfs command and the umount.nfs command need
    to fill in a pmap structure based on string mount options.  Introduce
    a shared function that can do this.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0dcb83a870926de215307472676096056dabc9b0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 27 17:41:02 2009 -0500

    text-based mount command: make po_rightmost() work for N options
    
    Sometimes we need to choose the rightmost option among multiple
    different mount options.  For example, we want to find the rightmost
    of "proto," "tcp," and "udp".  Or, the rightmost of "vers," "nfsvers,"
    "v2," and "v3".
    
    Update po_rightmost() to choose among N options instead of just two.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 29ac873f9024c8fcbca38ab09ba54cda3765b746
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jan 7 12:33:09 2009 -0500

    showmount command: Quiesce warning when TI-RPC is disabled
    
    Make sure nfs_sm_pgmtbl is not compiled if TI-RPC functions are not
    available.  This quiesces the following compiler warning:
    
      showmount.c:53: warning: nfs_sm_pgmtbl defined but not used
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ba05418f589c2d01f4e7e44c70d4844f43511927
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jan 7 12:18:11 2009 -0500

    configure: Add new build option "--enable-tirpc"
    
    Allow easier testing of nfs-utils in legacy environments by providing
    a "configure" option to force the build not to use libtirpc, even if
    it's present on the build system.  This can also be tried as a
    fallback if problems are found with the new TI-RPC-based nfs-utils
    code.
    
    The new option is:
    
      --enable-tirpc          enable use of TI-RPC [default=no]
    
    Build option matrix:
    
       --disable-tirpc   --disable-ipv6	Default; IPv4 only, glibc RPC
       --disable-tirpc   --enable-ipv6	'configure' will fail
       --enable-tirpc    --disable-ipv6	IPv4 only, TI-RPC
       --enable-tirpc    --enable-ipv6	IPv4 and IPv6, TI-RPC
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit aee8b1ab778f8e07b30305f10d4f9427023e314d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Jan 7 12:06:14 2009 -0500

    configure: Remove inet_ntop(3) check from configure.ac
    
    nfs-utils no longer uses inet_ntop(3) so remove checks for it from
    configure.ac.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 533e5a05a172306462ac6c11d222a18fe562ec6d
Merge: 09c7ad1... 8b4b718...
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 7 12:03:07 2009 -0500

    Merge branch 'master' of git://linux-nfs.org/nfs-utils

commit 8b4b71895e95e55e9fa924c2cc159311eb329ee5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 6 12:35:15 2009 -0500

    configure: use "--disable-uuid" instead of	"--without-uuid"
    
    Reported by Kevin Coffman and Jonathan Andrews.  Apparently --without-uuid
    doesn't work with some older versions of autoconf, so correct the help text
    to document the option that actually does the trick.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 18e84356811587a9cc405c4c6e18ca5573940e35
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 6 12:12:55 2009 -0500

    mount command: Random clean up
    
    Fix some documenting comments and an error message in configure.ac.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e9dbcba18defacbee9b5a48ddea9f6d3449b34e9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 6 12:08:33 2009 -0500

    mount: getport: don't use getaddrinfo(3) on old systems
    
    Older glibc versions have a getaddrinfo(3) that doesn't support
    AI_ADDRCONFIG.  Detect that case and build something else for
    getport.c that will work adequately on those systems.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 632650fa1a0b358f9d8d617cfd115a334c4b9b66
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 6 12:07:04 2009 -0500

    mount command: use gethostbyname(3) when building on old	systems
    
    Glibc's getaddrinfo(3) implementation was added over time.  Some old
    versions support AI_ADDRCONFIG, but don't define it in header files.
    Some older versions don't support AI_ADDRCONFIG at all.
    
    Let's add specific checks to configure.ac to see that the local
    getaddrinfo(3) implementation is complete.  If it isn't, we will make
    available a resolver that uses gethostbyname(3) and disable IPv6
    entirely.
    
    This patch should apply to 1.1.4 as well as the current nfs-utils repo.
    The next patch has a fix for the getaddrinfo(3) call added since 1.1.4
    in support/nfs/getport.c.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 265f2708bdc6030250c13d46d70ed689c140c34e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 6 12:03:26 2009 -0500

    mount: revert recent fix for build problems on old systems
    
    Revert the patch that added local definitions of AI_ADDRCONFIG and
    friends to utils/mount/network.c.  While old header versions don't
    have those flags, even older versions of getaddrinfo(3) don't
    support those flags at all.
    
    The result is this error:
    
      mount.nfs: DNS resolution failed for 10.10.10.10: Bad value for ai_flags
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 09c7ad1cd9c5ca2fc46631a0057d47309abc8706
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Mon Jan 5 14:07:05 2009 -0500

    gssd: By default, don't spam syslog when users' credentials expire
    
    Change the priority of "common" log messages so that syslog doesn't get
    slammed/spammed when users' credentials expire, or there is another
    common
    problem which would cause error messages for all context creation
    requests.
    
    Note that this will now require that gssd or svcgssd option "-v" is used
    to
    debug these common cases.
    
    Original patch from Andrew Pollock <apollock@google.com>.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    CC: Andrew Pollock <apollock@google.com>

commit 6e3f696e788a56f30b5b3f8250647fe4cd63c884
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Jan 3 14:08:25 2009 -0500

    Now that the TCP wrapper actually works, mounts will
    be denied with misconfigured DNS configurations. Warnings
    will be logged when these types of configurations are
    detected.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 71f9f61517bf301f723b79651d53590ef97c3556
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Dec 19 14:20:14 2008 -0500

    To ensure the hash table of clients has valid
    access rights, check the modification times on
    both access files. If one of them have change,
    update the hash entry instead of creating a
    new entry.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 58e0a308fec476361dd21f7d3856faceb6e308ee
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Dec 19 14:11:09 2008 -0500

    Clients IP address and host names are check on
    every RPC request, to both mountd and statd
    when TCP wrappers are enabled. To help this
    process scale better the access rights are stored
    in a hash table, which are hashed per IP address,
    RPC program and procudure numbers.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e47da19d63ea50a4e15f6ab491535d54097744de
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Dec 19 14:09:59 2008 -0500

    When clients are define as IP addresses in /etc/hosts.deny,
    access is allow due to misinterpreting the return value of
    hosts_ctl(). This patch reworks that logic which closes
    that hole.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bc870150cc2116584aee288d15ac2b9a2f825ff5
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Dec 17 16:41:35 2008 -0500

    statd: not unlinking host files
    
    Statd is not unlinking host files during SM_UNMON and
    SM_UNMON_ALL calls because the given host is still on the run-time
    notify list (rtnl) and the check flag is set when xunlink() is
    called. But the next thing the caller of xunlink() does is
    remove the host from the rtnl list which means the
    unlink will never happen.
    
    So this patch removes the check flag from xunlink() since
    its not needed and correctly allocates and frees memory
    used by xunlink().
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f846abde5faa4742b4823fa981080b1f5dac66b1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Dec 17 14:42:14 2008 -0500

    sm-notify command: fix a use-after-free bug
    
    The recv_reply() function was referencing host->ai in a freeaddrinfo(3)
    call after it had freed @host.
    
    This is not likely to be harmful in a single-threaded user context,
    but it's still bad form, and it will get called out if testing
    sm-notify with poisoned free memory.  The less noise, the better we
    are able to see real problems.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3f23f712477df48fd1d57376b65c44bb2a19ec16
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Dec 17 14:23:43 2008 -0500

    text-based mount command: use po_get_numeric() for	handling retry
    
    Replace the logic in nfs_parse_retry_option() with a call to the new
    po_get_numeric() function.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b5009d23525181846777349f2fc0e4a72b89d24d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Dec 17 14:21:10 2008 -0500

    text-based mount command: add function to parse numeric	mount options
    
    Introduce a function that is especially for parsing keyword mount options
    that take a numeric value.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit eb3a145789b9eedd39b56e1d76f412435abaa747
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Thu Dec 11 11:43:31 2008 -0500

    svcgssd: use the actual context expiration for cache
    
    Instead of sending down an infinite expiration value for the rsi(init) and
    rsc(context) cache entries, use a reasonable value for the rsi cache, and
    the actual context expiration value for the rsc cache.
    
    Prompted by a proposal from Neil Brown as a result of a complaint of a
    server running out of kernel memory when under heavy load of rpcsec_gss
    traffic.  Neil's original patch used one minute for the init cache and one
    hour for the context cache.  Using the actual expiration time prevents
    unnecessary context re-negotiation.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a4f1386224310b6797f083826fc4b6751e91f9b6
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Thu Dec 11 11:39:38 2008 -0500

    gssd/svcgssd: add support to retrieve actual context expiration
    
    Add some plumbing so that the context expiration can be returned while
    serializing the information.  Later patch(es) will actually get the
    expiration and pass it down to the kernel.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8a5ef964599438ea45f849a0cd1431a0c26bf054
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 11 10:30:20 2008 -0500

    mount command: AF_INET6 support for probe_bothports()
    
    Introduce an AF_INET6 capable probe_bothports() API.  This means replacing
    "struct sockaddr_in *" arguments with a "struct sockaddr *" and a socklen_t
    arguments.
    
    These functions often combine a "struct sockaddr_in" and a "struct pmap" into
    a single "clnt_addr_t" argument.  Instead of modifying "clnt_addr_t" and all
    the legacy code that uses it, I'm going to create a new probe_bothports() API
    for the text-based mount command that takes a "struct sockaddr *" and
    sockaddr length, and leave the existing probe_bothports() interface, which
    takes "clnt_addr_t" arguments, for legacy use.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 299a990de1b16ff769201fa0ed38249853254497
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 11 10:28:57 2008 -0500

    mount command: support AF_INET6 in probe_nfsport() and probe_mntport()
    
    Flesh out support for AF_INET6 in the intermediate helper functions
    probe_nfsport() and probe_mntport().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 71433fbcb0e3142e2b555727197f480d24761d7e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Dec 11 10:27:34 2008 -0500

    mount command: full support for AF_INET6 addresses in probe_port()
    
    Now that probe_port() uses an AF_INET6-capable rpcbind query and RPC ping,
    finish updating probe_port() to support AF_INET6 addresses fully.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5d8b800b8438222a55c4698c86b558b15717aa21
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Dec 6 08:31:29 2008 -0500

    sm-notify: always exiting without any notification
    
    Added curly brackets around the record_pid() check which
    stop sm-notify from exiting when a pid file does not
    exist.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b8711a0665b9ecff9d59ee36d756f50823242f64
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 2 07:43:54 2008 -0500

    mount command: remove local getport() implementation
    
    Eliminate local getport() implementation from utils/mount/network.c, as
    it is no longer used.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit cc58ba0c98b2f687810a5af9e6185bcc5e855fb0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 2 07:43:01 2008 -0500

    mount command: Replace clnt_ping() and getport() calls in	probe_port()
    
    Update the mount command's probe_port() function to call the new shared
    rpcbind query and RPC ping functions.  This provides immediate support
    for
    rpcbind v3/v4 queries, and paves the way for supporting AF_INET6 in the
    probe_bothports() path.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 14b0dae49afae3fcf05c19ae84829aeef2f6876e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 2 07:40:16 2008 -0500

    mount command: Use nfs_error() instead of perror()
    
    So we can ensure that error output is directed appropriately, use
    nfs_error() instead of perror() in start_statd().
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ea0473feffd8071216c96217df3202a8deed2c65
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 2 07:39:06 2008 -0500

    mount command: Use nfs_pmap_getport() in probe_statd()
    
    Repace the getport() and clnt_ping() calls in probe_statd() with their
    new shared equivalents.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 33bbeabb40d11a59266e0702adaa6a2e0acb6382
Author: Neil Brown <neilb@suse.de>
Date:   Wed Nov 26 12:01:06 2008 -0500

    Ensure statd gets started if required when non-root
    user mounts an NFS filesystem.
    
    The first time an NFS filesystem is mounted, we start statd from
    /sbin/mount.nfs.  If this first time is a non-root user doing the
     mount, (thanks to e.g.  the 'users' option in /etc/fstab)
    then we need to be sure that the 'setuid' status from mount.nfs
    is inherited through to rpc.statd so that it runs as root.
    
    There are two places where we loose our setuid status due to the shell
    (/bin/sh) discarding.
    
    1/ mount.nfs uses "system" to run /usr/sbin/start-statd.  This runs a
       shell which is likely to drop privileges.  So change that code to use
      'fork' and 'execl' explicitly.
    2/ start-statd is a shell script.  To convince the shell to allow the
      program to run in privileged mode, we need to add a "-p" flag.
    
    We could just call setuid(getuid()) at some appropriate time, and it
    might be worth doing that as well, however I think that getting
    rid of 'system()' is a good idea and once that is done, the
    adding of '-p' is trivial and sufficient.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 068ea89e7d335d381276a2fff73d5abbb2b0a04d
Author: Neil Brown <neilb@suse.de>
Date:   Wed Nov 26 08:48:03 2008 -0500

    gssd:  unblock DNOTIFY_SIGNAL in case it was blocked.
    
    I have a situation where rpc.gssd appears to not be working.
    Mount attempts which need to communicate with it block.
    
    I've narrowed down the problem to that fact that all realtime signals
    have been blocked.  This means that DNOTIFY_SIGNAL (which is a
    realtime signal) is never delivered, so gssd never rescans the
    rpc_pipe/nfs directory.
    
    It seems start_kde (or whatever it is called) and all descendants have
    these
    signals blocked.  xfce seems to do the same thing.  gnome doesn't.
    
    So if you start rpc.gssd from a terminal window while logged in via
    KDE, it doesn't behave as expected.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f7020bd5d3ffca280690c6beba5fecdeb4d305f7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 25 08:39:47 2008 -0500

    showmount command: support querying IPv6 servers
    
    Introduce a version of nfs_get_mount_client() that supports AF_INET6 and
    AF_INET server addresses.  If the TI-RPC library is not available when
    the showmount command is built, fall back to the legacy RPC user-space
    API.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1c96846ba3adeb59a61e0cf33cf4c94c0678853f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 25 08:38:01 2008 -0500

    showmount command: move logic to acquire RPC client	handle out of main()
    
    In preparation to support IPv6 in the showmount command, extract the
    logic that parses/acquires the target hostname and converts it into an RPC
    client handle to contact the remote mountd service, and move it into its
    own function.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e358039c9ffa8a4ead342e8a0cf0ff51a3a21af4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 25 08:35:10 2008 -0500

    showmount command: Remove unused local getport() implementation
    
    Clean up: remove showmount.c's local getport() implementation, now that
    the showmount command uses the shared one.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bb3e50bd5c4f6bf94221ef69d4dc87e73d0e474b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 25 08:15:51 2008 -0500

    showmount command: call nfs_getport instead of local getport
    
    Have the showmount command invoke the shared nfs_getport() function
    instead of its own local version.  This gives the showmount command
    immediate support for querying via rpcbindv3/v4 in addition to
    portmapper, and sets the stage for AF_INET6 support in showmount.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9888a72c18c0798b0fd352f02d5985aa75637743
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Nov 18 12:59:41 2008 -0500

    Added support/nfs/getport.c
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 541bf913ec64dee719b34d2a6850fcfee550e6c0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Nov 17 16:13:48 2008 -0500

    Introduce rpcbind client utility functions
    
    It turns out that at least the mount command and the showmount command
    need to query a server's rpcbind daemon.  They need to query over
    AF_INET6 as well as AF_INET.
    
    libtirpc provides an rpcbind query capability with the rpcb_getaddr(3)
    interface, but it takes a hostname and netconfig entry rather than a
    sockaddr and a protocol type, and always uses a lengthy timeout.  The
    former is important to the mount command because it sometimes must
    operate using a specific port and IP address rather than depending on
    rpcbind and DNS to convert a [hostname, RPC program, netconfig] tuple
    to a [socket address, port number, transport protocol] tuple.
    
    The rpcb_getaddr(3) API also always uses a privileged port (at least
    for setuid root executables like mount.nfs), which is not required for
    an rpcbind query.  This can exhaust the local system's reserved port
    space quickly.
    
    This patch provides a reserved-port-friendly AF_INET6-capable rpcbind
    query C API that can be shared among commands and tools in nfs-utils,
    and allows a query to a specified socket address and port rather than
    a hostname.
    
    In addition to an rpcbind query interface, this patch also provides a
    facility to ping the remote RPC service to ensure that it is operating
    as advertised by rpcbind.  It's useful to combine an RPC ping with an
    rpcbind query because in many cases, components of nfs-utils already
    ping an RPC service immediately after receiving a successful GETPORT
    result.
    
    There are also a handful of utility routines provided, such as a
    functions that can map between [sockaddr, port] and a universal
    address.
    
    I've made an attempt to make these new functions build and operate on
    systems that do not have libtirpc.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 162cbdd19830abaf6a3fd64a22839023ce99185d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Nov 17 16:08:03 2008 -0500

    Add AF_INET6-capable API to acquire an RPC	CLIENT *
    
    Provide a simple interface that any component of nfs-utils can use to acquire
    an RPC CLIENT *.  This is an AF_INET6-enabled API, and can also handle
    PF_LOCAL sockets if libtirpc is present on the system.
    
    When libtirpc is not available, legacy RPC services will be used instead,
    and an attempt to connect to an AF_INET6 address will fail.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 971b780d47558e4688316b6b35bb15989b1541d0
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Oct 21 09:34:58 2008 -0400

    Get rid of empty AUTHORS file
    
    build: remove redundant AUTHORS file
    
    One can use the --foreign automake option to make it not enforce
    presence of an AUTHORS file.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>



