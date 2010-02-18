Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753535Ab0BRO1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2010 09:27:39 -0500
Message-ID: <4B7D4E55.4040002@RedHat.com>
Date: Thu, 18 Feb 2010 09:27:33 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Subject: ANNOUNCE: nfs-utils-1.2.2 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

New Features in this release:

   * Client side IPv6 support is available with the 
     --enable-ipv6 configuration flag.

   * A very large number of bug fixes 

The tarball can be found at:

  http://www.kernel.org/pub/linux/utils/nfs/
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log:

commit bc7736ea87166e99d6b4f57da84d26d007db8ae4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Feb 18 06:41:11 2010 -0500

    mount: Set protocol family properly for "udp" and "tcp"
    
    In nfs_nfs_proto_family(), *family is never set if the legacy
    "udp" or "tcp" mount options are specified.  The result is an error
    message at umount time, for example:
    
    umount.nfs: DNS resolution failed for
      2001:5c0:1101:2f00:250:8dff:fe95:5c61: ai_family not supported
    
    even if mount was built with IPv6 support.
    
    The man page says that "udp" is a synonym for "proto=udp", and
    likewise for "tcp".  Thus, we don't look at config_default_family
    here, but always use AF_INET explicitly, to be consistent with the
    meaning of proto=.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Reviewed-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6d5ac3fa75024be569b458f4d9b6ce05be47f601
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Feb 17 14:38:19 2010 -0500

    nfsd: Disable NFS 4.1 functionality by default
    
    Due to the fact the current kernel code do not completely
    conform to the NFS 4.1 RFC, this patch disable the 4.1 support
    on the server.
    
    To control this 41 functionality, the NFS41_SUPPORTED
    configuration variable now exist that will allow us to
    re enable the functionality  without any code changes.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 33203b53ac5f43eef995c100299e45bd441c67d8
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Feb 12 14:35:31 2010 -0500

    mount.nfs: make nfs_{nfs,mount}_proto set errno on error
    
    Have nfs_nfs_proto and nfs_mount_proto set errno to EPROTONOSUPPORT on
    error. This helps default_value to display sane warning messages.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1d4a0cb29ee88257b42d18a22388e1b23cf13bcc
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Feb 12 14:33:34 2010 -0500

    mount.nfs: return error if proto= option specified IPv6 when IPv6 isn't supported
    
    Right now, there's nothing that expressly forbids someone from
    specifying proto=tcp6 for instance, even when nfs-utils it built without
    IPv6 support. This may not work well if (for instance) they are using
    NFSv3, since statd won't support IPv6. Explicitly return an error if
    someone specifies an IPv6 proto= or mountproto= option and IPv6 isn't
    supported.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit abba588f7458ab4b29bb05782c0570b71ee8967c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Feb 12 14:26:46 2010 -0500

    statd: Remove SIMU_CRASH warning
    
    SM_SIMU_CRASH isn't used, so this warning is never seen today.
    However, if we ever wanted to use SM_SIMU_CRASH, this warning
    is unnecessarily alarming, and serves no real purpose.
    
    At some point in the near future I'd like us to consider using
    SM_SIMU_CRASH, so let's get rid of this message now.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8f9493d13f884a62d7581326c1925a8171b3b0bd
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Feb 12 14:23:16 2010 -0500

    This is the second iteration of this patch. The only difference here
    is that this one has default_value call nfs_nfs_proto_family regardless
    of whether IPV6_SUPPORTED is set.
    
    When IPv6 is enabled, the Proto= config file option is treated as a
    netid, and the address family for lookups is selected based on that
    setting. The Defaultproto= option however still only affects the
    protocol setting for the sockets (IPPROTO_*) and not the address family.
    
    This patch makes it so that if someone sets the "Defaultproto=" option
    in the nfsmount.conf, it's used to determine the default address family
    for lookups as well as the protocol type.
    
    This gives users a way to force a particular address family to be used
    universally for mounts and brings the behavior of the Defaultproto=
    option in line with the Proto= option.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7b0e4faaf3169c69828d3f7769ed8ce9142e100b
Author: Ben Myers <bpm@sgi.com>
Date:   Fri Feb 12 14:02:21 2010 -0500

    nfs-utils: don't fdatasync the rmtab
    
    If we're using the new caching interface the rmtab will be ignored by
    exportfs so there is no need to fdatasync. This improves mountd performance.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2ba89d65421cba255a0e75a7f646e4bbb2487193
Author: Ben Myers <bpm@sgi.com>
Date:   Fri Feb 12 14:00:52 2010 -0500

    nfs-utils: dont leak fd in mountlist_list
    
    Don't leak this file descriptor if stat should fail.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a797fe77beb2748bebfa84e4d1d9033fbd65da57
Author: Ben Myers <bpm@sgi.com>
Date:   Fri Feb 12 13:58:57 2010 -0500

    nfs-utils: remove xflock timeout
    
    Remove this 10 second timeout which can cause unexpected behavior and
    corruption in the rmtab when hit.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 19c786fc87aba2ecae3072d54ca0a994d5bb997b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Feb 12 13:38:59 2010 -0500

    text-based mount: Support protocol family negotiation
    
    Jeff Layton pointed out that the current negotiation logic in
    stropts.c simply doesn't handle the case where a server may have an
    IPv6 address and an IPv4 address, but only NFS/IPv4 is supported.
    This is typical of all currently deployed Linux servers.
    
    Add support for trying all addresses returned from DNS when
    "proto=" is not specified on the command line.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0f76458dd0f9a34210e44515a67d55e713a990ce
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Feb 12 13:36:17 2010 -0500

    text-based mount: Set addr= option in nfs_try_mount_foo()
    
    When retrying a mount request with a different server address, the
    addr= option may change each time through the fg/bg loop.
    
    Instead of setting the addr= option in nfs_validate_options(), set it
    in nfs_try_mount_v2v3() and nfs_try_mount_v4().  This is much the
    same thing we did recently with the version-specific mount options
    which might change each time through the fg/bg retry loop.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 25dd860f13b93109dfd54ef8be0bfd91e4353af1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Feb 12 13:10:03 2010 -0500

    text-based mount: Replace nfs_lookup() with getaddrinfo(3)
    
    Originally I thought it would be best to share the DNS query code
    between the legacy mount code and the new text-based code, hence
    the introduction of nfs_lookup().  However, it now appears we want
    the text-based code to do a little more than take the first address
    returned by the query.
    
    So, let's invoke getaddrinfo(3) directly in stropts.c, and save
    the returned addrinfo struct until the end of processing.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit df6c9d1821585c773297fbfffa1dd315b9c84359
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Feb 12 13:04:14 2010 -0500

    text-based mount: Retry when server can't be reached
    
    We want new default behavior from mount.nfs when the server refuses a
    connection.  Since connection refusal can be spurious (for example,
    if the server is rebooting), mount.nfs should retry.
    
    NFS shares that are automatically mounted by /etc/fstab at boot
    time may be problematic.  The new behavior can be disabled by
    specifying the "retry=0" mount option, or these mounts can be changed
    to background mounts by specifying the "bg" option.
    
    A kernel code change is still required for the mount(2) system call to
    return ECONNREFUSED for NFSv4 mounts (see 2.6.33).  For v2/v3, the
    version and transport negotiation logic in mount.nfs should drive a
    retry if the server's rpcbind can't be reached.
    
    Note that if a v2/v3 mount request encounters an unregistered NFS
    service, it will still fail immediately.  That wouldn't be too hard
    to change as well, but there are many more corner cases there where
    failing immediately is appropriate.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0422d28f513d2e9ea116e28a2556cee54c8f1d19
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Feb 8 10:36:23 2010 -0500

    nfsstat: use symbolic constants for operation array sizes
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1f76eab5b434cf13895920e7cab5ddf790d67b4f
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Feb 8 10:34:19 2010 -0500

    Add recalim_complete to client stats.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f808c94e8abb104e5248ee92acf6aeaf2e06e76a
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Feb 4 17:03:53 2010 -0500

    nfsd: fix version-setting regression on old kernels
    
    /proc/fs/nfsd/versions was extended to allow turning on/off minor
    versions by echoing "+4.1" or "-4.1" to /proc/fs/nsfd/versions.
    
    Unfortunately, pre-2.6.30 kernels just stop parsing at first non-digit,
    so "-4.1" is interpreted as "-4".  If new nfs-utils (on old kernel)
    writes "+2", "+3", "+4", then "-4.1", result therefore is to turn off
    4.1.
    
    Given that historical behavior, it may have been a mistake to extend the
    interface the way we did; but at this point we're probably stuck with
    it.  So, just reverse the order we write versions in.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6318d601cf182d2848d397af323ca9c4fbdecb97
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jan 25 13:09:04 2010 -0500

    Teach nfs_compare_sockaddr() to handle NULL arguments.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d9c22d2e825d050a89da8c798c56f3a96d2359b0
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 22 12:30:58 2010 -0500

    Added the sys/stat.h header file to a number of
    files which ensure the S_ISDIR() macro is defined.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 207cf7da3868e13439544ac83b64e8e5efcbdf91
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 22 12:24:05 2010 -0500

    Remove the idmapd.conf man. It now lives in the
    libnfsidmap library git tree
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d63f9e0ccb836d592593a9816ccc00a51c903328
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jan 20 15:05:46 2010 -0500

    mount.nfs: Configuration file parser ignoring options
    
    When the protocol version is set on the command line,
    none of the variables set in the configuration file
    are passed down to the kernel due to a bug in the
    parsing routine.
    
    Tested-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8e710e90bcf937d500445082800503f374560399
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 15 16:02:49 2010 -0500

    tcpwrapper: Add support for IPv6
    
    Assuming the tcp_wrappers library can actually support IPv6 addresses,
    here's a crack at IPv6 support in nfs-utils' TCP wrapper shim.
    
    Some reorganization is done to limit the number of times that @sap
    is converted to a presentation address string.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 7d81b45faeb9ca652f4076cfecd0da742caa22a8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Jan 17 16:53:02 2010 -0500

    tcpwrapper: Eliminated shadowed declaration warnings
    
    Clean up: the use of identifiers called "access" and "daemon" shadow
    function declarations in unistd.h.  Seen with "-Wextra -pedantic".
    
    tcpwrapper.c: In function haccess_add:
    tcpwrapper.c:112: warning: declaration of access shadows a global
    declaration /usr/include/unistd.h:288: warning: shadowed declaration is here
    tcpwrapper.c: In function good_client:
    tcpwrapper.c:161: warning: declaration of daemon shadows a global declaration
    /usr/include/unistd.h:953: warning: shadowed declaration is here
    tcpwrapper.c: In function check_default:
    tcpwrapper.c:212: warning: declaration of daemon shadows a
    global declaration
    /usr/include/unistd.h:953: warning: shadowed declaration is here
    
    good_client() is used only in support/misc/tcpwrapper.c, so make it
    static (and update its prototype to c99 standard form).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 90c944c9cc1fde845caa29b98c2864eb32660403
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Jan 17 16:50:29 2010 -0500

    tcpwrapper: Fix signage problems in the tcp_wrappers hash function
    
    Eliminate the following compiler warnings:
    
    tcpwrapper.c:78: warning: no previous prototype for strtoint
    tcpwrapper.c: In function strtoint
    tcpwrapper.c:81: warning: conversion to int size_t may change the
        sign of the result
    tcpwrapper.c:85: warning: conversion to unsigned int from int may
        change the sign of the result
    tcpwrapper.c: In function hashint:
    tcpwrapper.c:91: warning: conversion to int from unsigned int may
        change the sign of the result
    
    The hash value is probably computed consistently even with
    unexpected sign inversions.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e94001c0bb9ee7847a2ef7a3b436acd74acb9fd6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Jan 17 16:48:56 2010 -0500

    tcp_wrapper: Clean up logit()
    
    Eliminate these compiler warnings:
    
    tcpwrapper.c: In function logit
    tcpwrapper.c:225: warning: unused parameter procnum
    tcpwrapper.c:225: warning: unused parameter prognum
    
    Actually, @procnum is not used anywhere in our tcpwrapper.c, so
    let's just get rid of it.
    
    Since there is only one logit() call site in tcpwrapper.c, the macro
    wrapper just adds needless clutter.  Let's get rid of that too.
    
    Finally, both mountd and statd now use xlog(), which adds an
    appropriate program name prefix to every message.  Replace the
    open-coded syslog(2) call with an xlog() call in order to
    consistently identify the RPC service reporting the intrusion.
    
    Since logit() no longer references "deny_severity" and no nfs-utils
    caller sets either allow_severity or deny_severity, we remove them.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4bc0dbaed1ba2f58beea2cdb0595b461e0c88b8e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 15 15:53:07 2010 -0500

    tcp_wrappers: Use getifaddrs(3) if it is available
    
    After glibc 2.3.3, getifaddrs(3) can return AF_INET6 addresses for
    local network interfaces.  Using the library call is easier than
    trying to update the open code in from_local(), and means we have
    less to maintain in nfs-utils going forward.
    
    And, since from_local() can now support IPv6, change its synopsis to
    take a "struct sockaddr *" .
    
    Note that the original code discovers local addresses once.  These
    days, with wifi, DHCP, and NetworkManager, the local network
    configuration can change dynamically over time.  So, call getifaddrs()
    more often to ensure from_local() has up-to-date network configuration
    information.
    
    This implementation refreshes the list if from_local() has not been
    called in the last second.  This is actually not terribly honerous.
    check_default() invokes from_local() only when the remote host is not
    in its access cache, or the access/deny files have changed.
    
    So new hosts will cause a refresh, but previously seen hosts
    (including localhost) should not.
    
    On the other hand, it still may not be often enough.  After the first
    call, if only previously seen hosts attempt to access our daemons,
    from_local() would never be called, and the local list would never be
    updated.  This might be possible during steady-state operation with
    a small number of servers and clients.
    
    It would also be nice if we could free the local interface address
    list at shutdown time, but that would be a lot of trouble for little
    gain.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit e8c917f53741100d6ea710100dca7c914791880b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jan 15 15:14:38 2010 -0500

    tcpwrappers: Use xlog() instead of perror(3) and syslog(2)
    
    Clean up: Replace calls to syslog(2) and perror(3) in from_local.c
    with calls to xlog().  The problems displayed by the perror(3) calls
    especially should be reported.  Currently they are never seen in the
    system log.
    
    As part of a build test, I defined TEST, and found a couple of
    problems with main(), which are also addressed in this patch.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit fb69c9d6320b303acbb7971da9e8f18d32b33e2f
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 15 13:51:04 2010 -0500

    Tone down a number xlog messages in svc_create_bindaddr()
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ec8a23e674ba39b3c4048095c4d848dfb1b15c0f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:44 2010 -0500

    statd: update rpc.statd(8) and sm-notify(8) to reflect IPv6 support
    
    Expand and clarify the explanation of NSM operation on Linux, and
    provide the same text in both man pages.
    
    Update descriptions of the command line options to match the operation
    of the current implementation.
    
    Introduce sections discussing security and operational issues, and
    IPv6 operation.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 7dd134204d88c22b414a4ecfcd986efb57fedebf
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:39 2010 -0500

    statd: Support TI-RPC statd listener
    
    If TI-RPC is available, use it to create statd's svc listener.  If
    not, use the old function, rpc_init(), to create statd's listener.
    
    IPv6 can be supported if TI-RPC is available.  In this case,
    /etc/netconfig is searched to determine which transports to advertise.
    
    Add the new listener creation API in libnfs.a since other components
    of nfs-utils (such as rpc.mountd) will eventually want to share it.
    
    A little re-arrangement of when the statd listener is created is done
    to make unregistration of the statd service more reliable.  As it is
    now, the statd service is never unregistered when it exits.  After it
    is gone, other programs usually hang when trying to access statd or
    see if it's running, since the registration is still there but statd
    itself does not respond.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit e2446fda6e7cdb1b9462162b81b0e50fd6efaf56
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:34 2010 -0500

    libnsm.a: retain CAP_NET_BIND when dropping privileges
    
    I'm about to switch the order of listener creation and dropping root
    privileges.  rpc.statd will drop privileges first, then create its
    listeners.  The reason for the new ordering is explained in a
    subsequent patch.
    
    However, for non-TI-RPC builds, rpc_init() needs to use a privileged
    port to do pmap registrations.  For both TI-RPC and non-TI-RPC builds,
    CAP_NET_BIND is required in case the admin requests a privileged
    listener port on the statd command line.
    
    So that these requirements are met, nsm_drop_privileges() will now
    retain CAP_NET_BIND while dropping root.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit d16bd0400fc096ec2fed36d5dfa8620b2370e4d1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:30 2010 -0500

    statd: Remove NL_ADDR() macro
    
    Clean up: The contents of NL_ADDR are fixed: they are always the IPv4
    loopback address.  Some time ago, the use of NL_ADDR() was stubbed out
    of the NLM downcall forward path, replaced with a constant IPv4
    loopback address.
    
    Stub it out of the reply path as well, and then remove NL_ADDR
    entirely.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 17d144b236c84150c2ca896c0d3eea05931d938e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:23 2010 -0500

    statd: Support IPv6 in sm_stat_1_svc()
    
    SM_STAT is usually not used by most contemporary NSM implementations,
    but for consistency, it gets the same treatment as sm_mon_1_svc(),
    since both should use the same logic to determine whether a mon_name
    is able to be monitored.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 8ce130c4c828b9d13d429f22160f992b9c1d45cd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:15 2010 -0500

    statd: Support IPv6 in sm_mon_1_svc()
    
    Replace deprecated gethostbyname(3) and gethostbyaddr(3) calls in
    monitor.c, and address a couple of memory leaks.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit ffee293b10bbb80599ff4345a3155ff36ec05112
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:08 2010 -0500

    statd: Add API to canonicalize mon_names
    
    Provide a shared function to generate canonical names that statd
    uses to index its on-disk monitor list.  This function can resolve
    DNS hostnames, and IPv4 and IPv6 presentation addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 7f98c14d38badedd30d2d4a6b1d15e913967bf87
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:24:00 2010 -0500

    libnsm.a: Add support for multiple lines in monitor record files
    
    To support IPv6, statd must support multi-homed remote peers.  For our
    purposes, "multi-homed peer" means that more than one unique IP
    address maps to the one canonical host name for that peer.
    
    An SM_MON request from the local lockd has a "mon_name" argument that
    statd reverse maps to a canonical hostname (ie the A record for that
    host).  statd assumes the canonical hostname is unique enough that
    it stores the callback data for this mon_name in a file named after
    that canonical hostname.
    
    Because lockd can't distinguish between two unique IP addresses that
    may be from the same physical host, the kernel can hand statd a
    mon_name that maps to the same canonical hostname as some previous
    mon_name.  So that the kernel can keep this instance of the mon_name
    unique, it creates a fresh priv cookie for each new address.
    
    Note that a mon_name can be a presentation address string, or the
    caller_name string sent in each NLMPROC_LOCK request.  There's
    nothing that requires the caller_name to be a fully-qualified
    hostname, thus it's uniqueness is not guaranteed.  The current
    design of statd assumes that canonical hostnames will be unique
    enough.
    
    When a mon_name for a fresh SM_MON request maps to the same canonical
    hostname as an existing monitored peer, but the priv cookie is new,
    statd will try to write the information for the fresh request into an
    existing monitor record file, wiping out the contents of the file.
    This is because the mon_name/cookie combination won't match any record
    statd already has.
    
    Currently, statd doesn't check if a record file already exists before
    writing into it.  statd's logic assumes that the svc routine has
    already checked that no matching record exists in the in-core monitor
    list.  And, it doesn't use O_EXCL when opening the record file.  Not
    only is the old data in that file wiped out, but statd's in-core
    monitor list will no longer match what's in the on-disk monitor list.
    
    Note that IPv6 isn't needed to exercise multi-homed peer support.
    Any IPv4 peer that has multiple addresses that map to its canonical
    hostname will trigger this behavior.  However, this scenario will
    become quite common when all hosts on a network automatically get both
    an IPv4 address and an IPv6 address.
    
    I can think of a few ways to address this:
    
    1.  Replace the current on-disk format with a database that has a
    uniqueness constraint on the monitor records
    
    2.  Create a new file naming scheme; eg. one that uses a truly
    unique name such as a hash generated from the mon_name, my_name, and
    priv cookie
    
    3.  Support multiple lines in each monitor record file
    
    Since statd's on-disk format constitutes a formal API, options 1 and 2
    are right out.  This patch implements option 3.  There are two parts:
    adding a new line to an existing file; and deleting a line from a file
    with more than one line.  Interestingly, the existing code already
    supports reading more than one line from these files, so we don't need
    to add extra code here to do that.
    
    One file may contain a line for every unique mon_name / priv cookie
    where the mon_name reverse maps to the same canonical hostname.  We
    use the atomic write facility added by a previous patch to ensure the
    on-disk monitor record list is updated atomically.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit b148d3414a8d574ff7883ad99d3d1dd980a12603
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:53 2010 -0500

    libnsm.a: Factor atomic write code out of nsm_get_state()
    
    We're about to use the same logic (mktemp, write, rename) for
    other new purposes, so pull it out into its own function.
    
    This change also addresses a latent bug: O_TRUNC is now used when
    creating the temporary file.  This eliminates the possibility of
    getting stale data in the temp file, if somehow a previous "atomic
    write" was interrupted and didn't remove the temporary file.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit d56192a1e4ddb962f961721b1c5d094696b2d206
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:48 2010 -0500

    sm-notify: Save mon_name and my_name strings
    
    Currently sm-notify does not use the mon_name and my_name strings
    passed to smn_get_host().  Very soon we're going to need the mon_name
    and my_name strings, so add code to store those strings in struct
    nsm_host, and free them when each host is forgotten.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit d5836a3c08b1b43afc78b18e0c06bab6d89be3b1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:42 2010 -0500

    statd: Support IPv6 in sm_simu_crash_1_svc
    
    Ensure that SM_SIMU_CRASH does not allow non-AF_INET callers to
    bypass the localhost check.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit d1f7c031ee37a7b962777e18dd46cb79b806e1c3
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:37 2010 -0500

    statd: Support IPv6 is caller_is_localhost()
    
    For the time being, statd is not going to support receiving SM_MON
    calls from the local lockd via IPv6.
    
    However, the upcalls (SM_MON, etc.) from the local lockd arrive on the
    same socket that receives calls from remote peers.  Thus
    caller_is_localhost() at least has to be smart enough to notice that
    the caller is not AF_INET, and to display non-AF_INET addresses
    appropriately.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit b5b794b165956a7d213b04e51b06597b7b1f8bee
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:27 2010 -0500

    statd: add IPv6 support in sm_notify_1_svc()
    
    We have all the pieces in place, so update sm_notify_1_svc() to handle
    SM_NOTIFY requests sent from IPv6 remotes.
    
    This also eliminates a memory leak: the strdup'd memory containing the
    callers' presentation address was never freed.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit d6ea66438d89c7708a10e464013491655f5361b0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:23 2010 -0500

    statd: add nsm_present_address() API
    
    Add an API to convert a socket address to a presentation address
    string.  This is used for displaying error messages and the like.
    
    We prefer getnameinfo(3) over inet_?to?(3) as it supports IPv6 scope
    IDs.  Since statd has to continue to build correctly on systems whose
    glibc does not have getnameinfo(3), an inet_?to?(3) version is also
    provided.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit cbd3a131e5c02bbd7b92a72b3ac467d71cfee1c4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:19 2010 -0500

    statd: Introduce statd version of matchhostname()
    
    For the near future, statd will support IPv6 but exportfs will not.
    Thus statd will need a version of matchhostname() that can deal
    properly with IPv6 remotes.  To reduce the risk of breaking exportfs,
    introduce a separate version of matchhostname() for statd to use while
    exportfs continues to use the existing AF_INET-only implementation.
    
    Note that statd will never send matchhostname() a hostname string
    containing export wildcards, so is_hostame() is not needed in the
    statd version of matchhostname().  This saves some computational
    expense when comparing hostnames.
    
    A separate statd-specific implementation of matchhostname() allows
    some flexibility in the long term, as well.  We might want to enrich
    the matching heuristics of our SM_NOTIFY, for example, or replace
    them entirely with a heuristic that is not dependent upon DNS.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit f0d3a4bedccca7cce48296757bc1c8bd59b80828
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:15 2010 -0500

    nfs-utils: Collect socket address helpers into one location
    
    Introduce generic helpers for managing socket addresses.  These are
    general enough that they are useful for pretty much any component of
    nfs-utils.
    
    We also include the definition of nfs_sockaddr here, so it can be
    shared.  See:
    
      https://bugzilla.redhat.com/show_bug.cgi?id=448743
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 18c3a41364836e61ceeb8e615e2b059904c5b65f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:23:09 2010 -0500

    sm-notify: Support IPv6 DNS lookups in smn_lookup
    
    When IPV6_SUPPORTED is enabled and the local system has IPv6 support,
    request AF_INET6 and AF_INET addresses from the DNS resolver.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 51fdac83e3afd86d0885c6b83123758708da61b1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:22:59 2010 -0500

    sm-notify: Use getaddrinfo(3) to create bind address in smn_create_socket()
    
    This patch updates the "bind to a user-specified port" arm of
    smn_create_socket() so it can deal with IPv6 bind addresses.
    
    A single getaddrinfo(3) call can convert a user-specified bind address
    or hostname to a socket address, optionally plant a provided port
    number, or whip up an appropriate wildcard address for use as the main
    socket's bind address.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 86cfdf1d38da18f9f917c674daba79a4435445a7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:22:42 2010 -0500

    sm-notify: IPv6 support in reserved port binding in smn_create_socket()
    
    This patch updates the "bind to an arbitrary privileged port" arm of
    smn_create_socket() so it can deal with IPv6 bind addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit f867499c8521a957776d52a9657b15fa7c2a513f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:22:33 2010 -0500

    sm-notify: Support creating a PF_INET6 socket in smn_create_socket()
    
    Socket creation is unfortunately complicated by the need to handle the
    case where sm-notify is built with IPv6 support, but the local system
    has disabled it entirely at run-time (ie, socket(3) returns
    EAFNOSUPPORT when we try to create an AF_INET6 socket).
    
    The run-time address family setting is made available in the global
    variable nsm_family.  This setting can control the family of the
    socket's bind address and what kind of addresses we want returned by
    smn_lookup().  Support for that is added in subsequent patches.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 56f9d50712481ed0f84f26e3a9f9dd012cf1995f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:22:26 2010 -0500

    sm-notify: factor socket creation out of notify()
    
    The top half of the notify() function creates the main socket that
    sm-notify uses to do its job.  To make adding IPv6 support simpler,
    refactor that piece into a separate function.
    
    The logic is modified slightly so that exit(3) is invoked only in
    main().  This is not required, but it makes the code slightly easier
    to understand and maintain.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 4f3f745c172202bf3846f8f1ee5d0a430b6014af
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:22:12 2010 -0500

    statd: Update rmtcall.c
    
    Replace the open code to construct NLM downcalls and PMAP_GETPORT RPC
    requests with calls to our new library routines.
    
    This clean up removes redundant code in rmtcall.c, and enables the
    possibility of making NLM downcalls via IPv6 transports.  We won't
    support that for a long while, however.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit e132bb5d5ef85420bb188bceecea361d30cb2bfe
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Thu Jan 14 12:22:09 2010 -0500

    sm-notify: Replace RPC code
    
    Replace the open code to construct SM_NOTIFY and PMAP_GETPORT RPC
    requests with calls to our new library routines that support
    IPv6 and RPCB_GETADDR as well.
    
    This change allows sm-notify to send RPCB_GETADDR, but it won't do
    that until the main sm-notify socket supports PF_INET6 and the DNS
    resolution logic is updated to return IPv6 addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit d89f50b2902305020a8e5d63ddc0b024679a1fc1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jan 12 16:41:43 2010 -0500

    libnsm.a: Add RPC construction helper functions
    
    To manage concurrency, both statd and sm-notify construct raw RPC
    requests in socket buffers, and use a minimal request scheduler
    to send these requests and manage replies.  Both statd and sm-notify
    open code the RPC request construction.
    
    Introduce helper functions that can construct and send raw
    NSMPROC_NOTIFY, NLM downcalls, and portmapper calls over a datagram
    socket, and receive and parse their replies.  Support for IPv6 and
    RPCB_GETADDR is featured.  This code (and the IPv6 support it
    introduces) can now be shared by statd and sm-notify, eliminating
    code and bug duplication.
    
    This implementation is based on what's in utils/statd/rmtcall.c now,
    but is wrapped up in a nice API and includes extra error checking.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

commit 1c0f9045bf479f38ec39ffa5c6a4c77a8fcabda8
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jan 12 20:08:24 2010 -0500

    Revert "Automatically set 'nohide' on referral exports."
    
    This partially reverts commit ec637de16210c1c6fcb3a0df34d7889592f577dc.
    
    Only NFSv4 clients will actually want to see referall points--others are
    better off just seeing an empty directory, that they can manually (or
    with automount) mount the appropriate filesystem on.
    
    So we want the kernel to automatically traverse only in the v4 case (as
    recent kernels do).
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit b1e28d50c2cf1d52c68c771921fd01f2af1c0a3b
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Jan 12 19:27:21 2010 -0500

    mountd: better hiding of v4root exports from mountd clients
    
    We've hidden v4root exports from get_exportlist (hence from the
    showmount command), but not from other mountd operations--allowing
    clients to attempt to mount exports when they should be getting an
    immediate error.
    
    Symptoms observed on a linux client were that a mount that previously
    would have returned an error immediately now hung.  This restores the
    previous behavior.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit e0819debc9d1d322e06ca4047a125a4fd8176d13
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sat Jan 9 10:44:57 2010 -0700

    mountd: minor v4root_set cleanup, check strdup return
    
    Move more of v4root_set into a helper function.
    
    Also, check the return value from strdup.  (We don't really handle the
    error well yet--we'll end up giving negative replies to export upcalls
    when we should be giving the kernel exports, resulting in spurious
    -ENOENTs or -ESTALE's--but that's better than crashing with a NULL
    dereference.)
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 40af0d2957a168bee50337695379313f3f88c635
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sat Jan 9 10:26:41 2010 -0700

    mountd: simplify export list deferral in v4root_set
    
    We're adding new entries, but not deleting them, so we don't need to do
    the usual double-counter trick here.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 37d9e4f9e0d1aeeb296583e40a36ae729786230d
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sat Jan 9 10:22:17 2010 -0700

    mountd: minor optimization in v4root_set
    
    Since we're adding new exports as we traverse the export list, it's
    possible we may find ourselves revisiting an export we just added.  It's
    harmless to reprocess those exports, as we're currently doing.  But it's
    also pointless.
    
    (Actually, the current code appears to always add new export entries at
    the head of each list, so we shouldn't hit this case.  It still may be a
    good idea to keep this check, though, as insulation against future
    changes to that data structure.)
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 5ccc7064cb5f59b29586474ba7c1f3e8a7255c5f
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Oct 8 18:24:45 2009 -0500

    mountd: kill unnecessary m_mayexport check
    
    Only exportfs uses m_mayexport; mountd always populates the export list
    with auth_reload(), which always sets m_mayexport on the entries it
    creates.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit e0ad421dabad027c33f78268d4829643b19165fd
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Oct 8 18:05:22 2009 -0500

    mountd: mountlist_del_all cleanup
    
    Common exit code.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 250c232f53bce01ffd0696f7a55b1e2b0feca51a
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Nov 27 15:54:11 2009 -0500

    mountd: auth_authenticate_internal further cleanup
    
    Move newcache case into its own function.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 195d28eb8136260a456dffa880ed80850115983a
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Nov 27 15:52:22 2009 -0500

    mountd: auth_authenticate_internal cleanup
    
    Break up another big function.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 1ca2e791eee22895907bceac07f2cbd2ea0193e8
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Oct 6 18:53:22 2009 -0500

    exports: common exportent initializer
    
    Consolidate duplicated initialization code.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 04258cf9107761f8e08c58964d59d5d628ad7eea
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Oct 6 17:18:04 2009 -0500

    exports: export_read() cleanup
    
    Use standard indentation, move warnings to helper function.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 55257d644359aec6fba463968bd503d5ae231eb7
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Nov 27 15:05:10 2009 -0500

    mountd: get_exportlist() cleanup
    
    Comment clarification, minor style cleanup.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 8ec371fe01e96c008cdc6143db716f1a9bfb6566
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri Nov 27 15:01:12 2009 -0500

    mountd: move most of get_exportlist() into helpers
    
    I needed to understand get_exportlist() recently, and it gave me
    trouble.
    
    Move detail work into helper functions to make the basic logic clear,
    and to remove need for excessive nesting (and fix inconsistent
    indentation levels).  Also remove unnecessary casts of void returns from
    xmalloc().
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit b25694320f2bdd79de82f2003209b8229eafff36
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Dec 1 07:20:43 2009 -0500

    exports: turn on pseudo exports
    
    If a pseudo root is not defined in the export file, the
    v4root_needed global variable will be set, signaling
    v4root_set() create the dynamic pseudo root.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit de108c531e29ba936a68a6efb99095ad6d6cec8f
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Dec 1 09:04:30 2009 -0500

    exports: hide pseudo exports from clients
    
    Don't show pseudo exports when clients ask to see what
    is exported via the showmount mount command.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 948cd2fb7983a4970132a97463b7928399bc51de
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Dec 24 15:51:20 2009 -0500

    mountd: prefer non-V4ROOT exports.
    
    If paths A and A/B are both exported, then we have a choice of exports
    to return for A (or under A but still above A/B): we could return A
    itself, or we could return a V4ROOT export leading to B.
    
    For now, we will always prefer the non-V4ROOT export, whenever that is
    an option.  This will allow clients to reach A/B as long as
    adminstrators keep to the rule that the security on a parent permits the
    union of the access permitted on any descendant.
    
    In the future we may support more complicated arrangements.
    
    (Note: this can't be avoided by simply not creating v4root exports with
    the same domain and path, because different domains may have some
    overlap.)
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 3b777b084a438f55482c8bf7508903ff4c30e1db
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Dec 1 07:16:13 2009 -0500

    exports: NFSv4 pseudoroot support routines
    
    Create v4root exports for each directory that is a parent of an explicit
    export.  Give each the minimal security required to traverse to any of
    its children.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 7f39d93b2cac65467999375e4a09bc5debb730e6
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Dec 1 06:22:08 2009 -0500

    exports: add new flag for NFSv4 pseudoroot
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0fe42a6e2cd7252c5c12a5f4edb4c27789b0c043
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Dec 22 13:02:08 2009 -0500

    mountd: don't require mountpoint in crossmnt case
    
    Currently,
    
    	mount --bind /path /path
    
    where /path is a subdirectory of a crossmnt export, can cause client
    hangs, since the kernel detects that as a mountpoint, but nfs-util's
    is_mountpoint() function does not.
    
    I don't see any sure-fire way to detect such mountpoints.  But that's
    OK: it's harmless to allow this upcall to succeed even when the
    directory is not a mountpoint, so let's just remove this check.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 9ec1b2c771ad0e16e0f031b017832d957c4bde56
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Dec 22 12:50:26 2009 -0500

    mountd: further split up lookup_export
    
    More trivial cleanup (no change in functionality) to group logical
    operations together into a single function.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 48cf3539933f5b0ba9c891b4e4010c0b6651d648
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Tue Dec 22 11:22:58 2009 -0500

    mountd: move export lookup into separate function
    
    Move this main loop to a separate function, to make it a little easier
    to follow the logic of the caller.
    
    Also, instead of waiting till we find an export to do the dns
    resolution, do it at the start; it will normally be needed anyway, and
    this simplifies the control flow.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit d778309abd38fcd6a240448606192b9ef3411565
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Dec 14 17:07:19 2009 -0500

    exports: let kernel decide which flags vary by flavor
    
    Query the kernel to ask which flavors vary by pseudoflavor, and use that
    instead of a fixed constant.  To allow the possibility of more flags
    varying by pseudoflavor, use the set/clear_flags functions for all
    options instead of setting some by hand.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit f783ec6a999e424054ccab773e7c6ba6b38eb1fe
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Dec 14 16:57:47 2009 -0500

    exports: minor parse_opts cleanup
    
    Move this into a helper function.  (We'll be adding a little more code
    here.)
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

commit 289ad31e013029c924c2777b4d3c0875b87db042
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Jan 12 07:32:51 2010 -0500

    gssd: on krb5 upcall, have gssd send a more granular error code
    
    Currently if a krb5 context expires, GSSAPI authenticated RPC calls
    start returning error (-EACCES in particular). This is bad when someone
    has a long running job that's doing filesystem ops on a krb5 authenticated
    NFS mount and just happens to forget to redo a 'kinit' in time.
    
    The existing gssd always does a downcall with a '-1' error code if there
    are problems, and the kernel always ignores this error code. Begin to
    fix this by having gssd distinguish between someone that has no
    credcache at all, and someone who has an expired one. In the case where
    there is an existing credcache, have gssd downcall with an error code of
    -EKEYEXPIRED. If there's not a credcache, then downcall with an error of
    -EACCES.
    
    We can then have the kernel use this error code to handle these
    situations differently.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fb8077ebc31698893ad09620a4e5d32c1d71287d
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Jan 12 06:03:22 2010 -0500

    Added the following files to .gitignore
     tests/nsm_client/nlm_sm_inter.h
     tests/nsm_client/nlm_sm_inter_clnt.c
     tests/nsm_client/nlm_sm_inter_svc.c
     tests/nsm_client/nlm_sm_inter_xdr.c
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3b2a15cc391a008b3c1f1c617b8224004b391004
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Jan 11 20:27:54 2010 -0500

    nfs-utils: add initial tests for statd that run via "make check"
    
    Leverage the support that automake already has for running tests via
    make check. Add a simple test that just checks that the statd mon and
    unmon calls actually work.
    
    Adding more tests should be a simple matter of adding new scripts
    exit 0 on success and non-zero on fail, and adding those to the
    Makefile.am.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8aca027278a79b1a13f26e6ba8009a076c802b43
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Jan 12 06:00:07 2010 -0500

    nfs-utils: add statdb_dump utility
    
    To dump contents of statd's monitor DB.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 80c537374acc08027dc4853c1801485be6684e6f
Author: Jeff Layton <jlayton@redhat.com>
Date:   Tue Jan 12 05:55:20 2010 -0500

    nfs-utils: introduce new statd testing simulator
    
    rpc.statd is often prone to subtle, difficult to detect breakage. When
    it has problems, they're often invisible and only manifest themselves
    as failed lock recovery.
    
    This program is intended to function as part of a test harness for
    statd. It's a multicall binary that serves as a synthetic NSM client
    program, and a daemon that can simulate lockd for purposes of testing
    the NSM to NLM downcall.
    
    A new top level "tests/" directory is also added to nfs-utils to start
    as a repository for automated tests of nfs-utils components.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a8449be2ab58d67d5028a280f94e661358b58e97
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Jan 11 19:52:47 2010 -0500

    nfs-utils: make private cookie to hex conversion a library routine
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 99979a6cf2f862d2365d27fa90fab4416c374903
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 11 19:13:59 2010 -0500

    statd: Use the new nsm_ file.c calls in rpc.statd
    
    Replace open-coded accesses to on-disk NSM information in rpc.statd
    with calls to the new API.
    
    Behavior should be much the same as it was before.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c74532a864caea0ca126dc8e9f4914e7c8e86898
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 11 19:10:49 2010 -0500

    statd: Use the new nsm_ file.c calls in sm_notify
    
    Replace open-coded accesses to on-disk NSM data with calls to the new
    libnsm.a API.
    
    One major change is that sync(2) is no longer called when the NSM
    state number is updated at boot time.  Otherwise sm-notify should
    behave much the same as it did before.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f16fb1cdc99fb1bd62767b133bec6358e7a793e1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jan 11 19:08:10 2010 -0500

    libnsm.a: Introduce common routines to handle persistent storage
    
    rpc.statd and sm-notify access the same set of files under
    /var/lib/nfs/statd, but both have their own code base to handle this.
    They should share this code.
    
    In addition, the on-disk format used by statd and friends is
    considered a formal interface, so this new code will codify the API
    and provide documentation for it.
    
    The shared code handles switching from the default parent statd
    directory, reducing privileges at start-up, and managing the NSM
    state files, in addition to handling normal operations on the
    monitored host and notification lists on disk.
    
    The new code is simply a copy of the same logic that was used in
    rpc.statd and sm-notify, but wrapped in a nice API.  There should be
    minimal behavioral and no on-disk format changes with the new
    libnsm.a code.
    
    The new code is more careful to check for bad corner cases.
    Occassionally this code may not allow an operation that was permitted
    in the past, but hopefully the error reporting has improved enough
    that it should be easy to track down any problems.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 917cd9a5532d90745d94045f49ee49d0a7636d6d
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jan 11 18:26:41 2010 -0500

    showmount: Try the highest mount version then fall back to lower ones
    
    Showmount should try the highest mount version first then fall
    back to the lower ones when the server returns a RPC_PROGVERSMISMATCH
    error. The idea being not using the lower mount versions will begin
    the process of moving away from NFSv2 support.
    
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6c3abd83758060356db4fa4e9d69d5bec09865e4
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Jan 4 15:42:51 2010 -0500

    mount.nfs: don't use IPv6 unless IPV6_SUPPORTED is set
    Commit 1f3fae1fb25168aac187ff1881738c8ad53a8763 made mount.nfs start
    looking up and trying to use IPv6 addresses when mount.nfs was built
    against libtirpc (even when --enable-ipv6 wasn't specified).
    
    The problem seems to be that nfs_nfs_proto_family() is basing the family
    on HAVE_LIBTIRPC. I think it should be basing it on IPV6_SUPPORTED
    instead.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Acked-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 64a3030683fab242a1608d7c35766130faffc1c0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Dec 23 11:29:19 2009 -0500

    libnsm.a: Move the sm_inter XDR pieces to libnsm.a
    
    Clean up: Move the .x file and the generated C source for NSM to
    libnsm.a, echoing the architecture of mountd and exportfs.  This makes
    the NSM protocol definitions, data types, and XDR routines available
    to be shared across nfs-utils.
    
    This simplifies the addition of other NSM-related code (for example
    for testing or providing clustering support), and also provides
    public data type definitions that can be used to make sense of the
    contents of statd's on-disk database.
    
    Because sim_sm_inter.x still resides in utils/statd, I've left some
    rpcgen build magic in utils/statd/Makefile.am.
    
    This is an internal organization change only.  This patch should not
    affect code behavior in any way.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e6ec4637a0c9b42132dcbde73ad4506666b92975
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Dec 23 11:18:17 2009 -0500

    libexport.a: fix a long-standing typo in name_cmp()
    
    Not sure what "(!*a || !a == ',')" means... but just a few lines later
    is
    "(!*a || *a == ',')".  I think "a is '\0' or ','" is what was intended.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1a1f991870f02b303a05e1d63915226e7cfb9f53
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 12:36:42 2009 -0500

    statd: replace smn_{get,set}_port() with the shared equivalents
    
    Use shared sockaddr port management functions instead of duplicating
    this functionality in sm-notify.  This is now easy because sm-notify
    is linked with libnfs.a, where nfs_{get,set}_port() reside.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 686ae9e82b90881f5ea775602c7fd6c187980cad
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Dec 11 12:34:34 2009 -0500

    statd: squelch compiler warning in sm-notify.c
    
    Clean up:  Get rid of a false positive compiler warning, seen with
    -Wextra.
    
    sm-notify.c: In function ¿record_pid¿:
    sm-notify.c:690: warning: comparison between signed and unsigned integer
    expressions
    
    Document some ignored return codes while we're here.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 85747f37936c9b7ea599b3ad8a2c989989d45e68
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Dec 11 13:05:06 2009 -0500

    gssd: have gssd deal with scopeid field in upcall
    
    Recent kernels (2.6.32) have started displaying the scopeid for some
    addresses in the upcall. gssd doesn't know how to deal with them. Change
    gssd to use getaddrinfo instead of inet_pton since that can deal with
    scopeid's in addresses. That also allows us to elminate the port
    conversion in read_service_info.
    
    If getaddrinfo returns an address with a non-zero sin6_scope_id however,
    reject it. getnameinfo ignores that field and just uses the sin6_addr
    part when resolving. But, two addresses that differ only in
    sin6_scope_id could refer to completely different hosts.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e4719f90f77de2ea2c083cbc304b5cc7a7b516bd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:53:13 2009 -0500

    NFS man page: update nfs(5) with details about IPv6 support
    
    Add details to nfs(5) about how to specify raw IPv6 addresses when
    mounting an
    NFS server.  Mounting via an IPv6 NFS server via hostname should work as
    it
    does with IPv4.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e9ab22a79e385babb16623a9260bda358291c80d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:52:21 2009 -0500

    mount.nfs: Remove nfs_name_to_address()
    
    Clean up:  nfs_name_to_address() has no more callers.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2755eeaa0a573e5cff621bb0102ddf4df3d07e19
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:50:13 2009 -0500

    mount.nfs: Teach umount.nfs to recognize netids in /etc/mtab
    
    umount.nfs has to detect the correct address family to use when
    looking up the server.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0e90c66a66946975029ef08038556e229955eb07
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:48:24 2009 -0500

    mount.nfs: proto=netid forces address family when resolving server names
    
    Using the netid settings, determine the correct address family to use
    for NFS and MNT server name resolution.  Use this family when
    resolving the server name for the addr= and mountaddr= options.
    
    This patch assumes the kernel can recognize a netid, instead of a
    protocol name, as the value of the proto= options.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b58c5b62ac47f84bca17fc7999e30b0a43ccb92d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:46:06 2009 -0500

    mount.nfs: Fix sockaddr pointer aliasing in stropts.c
    
    Using a sockaddr_storage and casting a sockaddr pointer to it breaks
    C's aliasing rules.
    
    See:
    
      https://bugzilla.redhat.com/show_bug.cgi?id=448743
    
    Replacing sockaddr_storage makes this code less likely to break when
    optimized by gcc.  It also saves a significant amount of stack space
    by replacing a 130 byte structure with a union that is less than 32
    bytes.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1f3fae1fb25168aac187ff1881738c8ad53a8763
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:44:34 2009 -0500

    mount.nfs: Add new API for getting protocol family from	netids
    
    Introduce a couple of new functions that extract the protocol family
    from the value of the proto= and mountproto= mount options.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9889b48572e672f4535ca9dafd98d81146b7b834
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:41:45 2009 -0500

    mount.nfs: make nfs_lookup() global
    
    Expose a DNS query API that allows callers to request DNS results from
    a specific address family.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bac279da80ae860267e8485d7fe2109096a326e9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:38:50 2009 -0500

    mount.nfs: support netids in v2/v3 version/transport negotiation
    
    When rewriting mount options during v2/v3 negotiation, restore the
    correct netids, rather than protocol names, in the rewritten protocol
    options.  If TI-RPC is not available, the traditional behavior is
    preserved.
    
    This patch assumes the kernel can recognize a netid, instead of a
    protocol name, as the value of the proto= options.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5ba18c11f31a135c6eeab67e820c271f87004793
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:37:02 2009 -0500

    mount.nfs: support netids in nfs_options2pmap()
    
    When parsing mount options in nfs_options2pmap(), treat the value of
    proto= (and mountproto=) as a netid by looking it up in local
    netconfig and protocol databases to convert it to a protocol number.
    If TI-RPC is not available, the traditional behavior is preserved.
    
    The meaning of the "udp" and "tcp" mount options is not affected by
    this change.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 626010056efb7baa76b08b5e6572720e02e425b4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Dec 11 10:34:42 2009 -0500

    libnfs.a: Provide shared helpers for managing netids
    
    Introduce a couple of shared functions that can convert netids to
    protocol numbers and families, and back.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 26a14b65991b79d317638f78dc6b4e5ac1ef712e
Author: Neil Brown <neilb@suse.de>
Date:   Mon Dec 7 17:23:48 2009 -0500

    mount.nfs: Retry v4 mounts with v3 on ENOENT errors
    
    Retry v4 mounts with a v3 mount when the version
    is not explicitly specified and the mount fails
    with ENOENT. The will help deal with Linux servers
    that do not automatically export a pseudo root
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 77997a364006619874a4585c6821da24666dbaa9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 24 09:08:29 2009 -0500

    statd: Replace nsm_log() with xlog() in sm-notify command
    
    To facilitate code sharing between statd and sm-notify (and with other
    components of nfs-utils), replace sm-notify's nsm_log() with xlog().
    
    Since opt_quiet is used in only a handful of insignificant cases, it
    is removed.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9ccfe0fa5a43dfc4453b09e328565a6c8f999fe4
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 24 08:36:20 2009 -0500

    statd: Replace note() with xlog() in rpc.statd
    
    To facilitate code sharing between statd and sm-notify (and with other
    components of nfs-utils), replace sm-notify's nsm_log() with xlog().
    
    Since opt_quiet is used in only a handful of insignificant cases, it
    is removed.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 29e2293a69a75abf0ce1c85daff0b94c9875d56a
Author: Harshula Jayasuriya <harshula@redhat.com>
Date:   Mon Nov 16 13:42:08 2009 -0500

    nfs-utils: NFSv4: fix backgrounding
    
    he nfsmount() function checks if !bg before running
    switch(rpc_createerr.cf_stat). On the other hand, the nfs4mount()
    function does not, and results in exiting the loop on the first
    iteration even with the bg mount option.
    
    NOTE: This and the previous patch ("nfs-utils: mount options can be lost
    when using bg option") are relevant to non text-based mount options.
    
    See https://bugzilla.redhat.com/show_bug.cgi?id=529370 for details.
    
    Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1cf5510adf8cbf7c342d8fce73f0b62ac1f93612
Author: Harshula Jayasuriya <harshula@redhat.com>
Date:   Mon Nov 16 13:39:35 2009 -0500

    mount options can be lost when using bg option
    
    When mounting an NFS export *without* the "bg" option, try_mount() is
    called only once. Before calling it, the variables mount_opts and
    extra_opts are set up. Then try_mount() calls nfsmount(), the latter
    assumes that the aforementioned variables can be modified. Most
    significantly, it allows the variable extra_opts to be modified.
    
    When the "bg" mount option is used *and* the first try_mount() attempt
    fails, it daemonizes the process and calls try_mount() again,
    unfortunately, we've lost the required mount options in the variable
    extra_opts.
    
    See https://bugzilla.redhat.com/show_bug.cgi?id=529370 for details.
    
    Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fa42ac173d1d7e37a4052471dfc15520a09f102e
Author: Robert Gordon <rbg@openrbg.com>
Date:   Mon Nov 16 13:25:02 2009 -0500

    relax insecure option on mountd
    
    In nfs-utils 1.2.0, I noticed that the insecure option validates that
    the client port is a
    subset of IPPORT_RESERVED as opposed to just validating it is a valid
    reserved port. The following proposed patch would correct that issue.
    
    Acked-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Robert Gordon <rbg@openrbg.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2498a68b1bec01d0ee8a63962b314140e8289036
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Nov 16 12:53:01 2009 -0500

    mount.nfs: Assume v2/v3 if mount-related options are present
    
    Don't try NFSv4 if any MNT protocol related options were
    presented by the user.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit dd31301d485b4244b1b35049f6917df907997da9
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Nov 16 09:44:03 2009 -0500

    gssd: process service= attribute in new upcall
    
    Add processing of the "service=" attribute in the new gssd upcall.
    
    If "service" is specified, then the kernel is indicating that
    we must use machine credentials for this request.  (Regardless
    of the uid value or the setting of root_uses_machine_creds.)
    If the service value is "*", then any service name can be used.
    Otherwise, it specifies the service name that should be used.
    (For now, the values of service will only be "*" or "nfs".)
    
    Restricting gssd to use "nfs" service name is needed for when
    the NFS server is doing a callback to the NFS client.  In this
    case, the NFS server has to authenticate itself as "nfs" --
    even if there are other service keys such as "host" or "root"
    in the keytab.
    
    Another case when the kernel may specify the service attribute
    is when gssd is being asked to create the context for a
    SETCLIENT_ID operation.  In this case, machine credentials
    must be used for the authentication.  However, the service name
    used for this case is not important.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 421406ee159fa27cca1a150600cfc321bbbe33f5
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Nov 16 09:27:22 2009 -0500

    gssd: process target= attribute in new upcall
    
    Add processing of the "target=" attribute in the new gssd upcall.
    Information in this field is used to construct the gss service name
    of the server for which gssd will create a context .
    
    This, along with the next patch handling "service=", is needed
    for callback security.
    
    For Kerberos, the NFS client will use a service principal present
    in its keytab during authentication of the SETCLIENT_ID operation.
    When establishing the context for the callback, the gssd on the
    NFS server will attempt to authenticate the callback against the
    principal name used by the client.
    
    Note: An NFS client machine must have a keytab for the callback
    authentication to succeed.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0cfdc66de043a89d2ae2167a624e7d0b56c122eb
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Nov 16 09:25:22 2009 -0500

    gssd: handle new client upcall
    
    Add support for handling the new client-side upcall.  The kernel,
    beginning with 2.6.29, will attempt to use a new pipe, "gssd",
    which can be used for upcalls for all gss mechanisms.
    
    The new upcall is text-based with an <attribute>=<value> format.
    Attribute/value pairs are separated by a space, and terminated
    with a new-line character.
    
    The intial version has two required attributes,
    mech=<gss_mechanism_name> and uid=<user's_UID_number>, and two
    optional attributes, target=<gss_target_name> and service=<value>.
    
    Future kernels may add new attribute/value pairs.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e55be8bb33f24561bc68c61909750ca94d52c18c
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Nov 16 09:18:42 2009 -0500

    gssd: print full client directory being handled
    
    For convenience, add the full name of the upcall pipe being processed.
    (Distinquishes between "normal" upcall, and a callback upcall.)
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 24de786ec7e7a70e0587b0656a31f309b3b5eb65
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Nov 16 09:15:25 2009 -0500

    gssd: add upcall support for callback authentication
    
    Change the processing so that all subdirectories within the rpc_pipefs
    directory are treated equally.  Any "clnt" directories that show up
    within any of them are processed.  (As suggested by Bruce Fields.)
    
    Note that the callback authentication will create a new "nfs4d_cb"
    subdirectory.  Only new kernels (2.6.29) will create this new directory.
    (The need for this directory will go away with NFSv4.1 where the
    callback can be done on the same connection as the fore-channel.)
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 99ed8de8261beb580c0ab9543ea7f2c8e16c9306
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Nov 16 09:14:31 2009 -0500

    gssd: refactor update_client_list()
    
    Split out the processing for a pipe to a separate routine.  The next
    patch adds a new pipe to be processed.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b695dbb65bb199e3a9ed5a9f780ed2e575061b46
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Mon Nov 16 09:12:22 2009 -0500

    This patch adds the krb5 hostbased principal, name which the
    nfs client used to authenticate, to the svcgssd downcall
    information.  This information is needed for the callback
    authentication.
    
    When estabishing the callback, nfsd will pass the principal
    name in the upcall to the gssd.  gssd will acquire a service
    ticket for the specified principal name.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2905358524c0835311501bad04c521479b0525ff
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Nov 12 14:16:12 2009 -0500

    Remove the AI_ADDRCONFIG hint flag to getaddrinfo() when it's
    call by nfsd to set up the file descriptors that are
    sent to the kernel. The flag causes the getaddrinfo()
    to fail, with EAI_NONAME, when there is not a non-loopback
    network interface configured.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

