Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56070 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752061AbZFBQIi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 12:08:38 -0400
Message-ID: <4A254DD1.5060507@RedHat.com>
Date: Tue, 02 Jun 2009 12:05:37 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Subject: nfs-utils-1.2.0 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The main reason for this release was the updated
RPC licenses that were worked out with Sun Microsystems

A while back it was notice that some of the copyrights
in nfs-utils were a bit GPL incompatible. So working with
Sun all the RPC licenses were replaced with BSD licenses
which are a bit more GPL compatible.

Note: all of the licenses in both rpcbind and libtirpc have
also been updated. 

steved.

The tarball can be found at:

  http://www.kernel.org/pub/linux/utils/nfs/
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log:

commit 6b7ad21f8162ec85766fd1369ea13ab432e287f8
Author: Tom spot Callaway <tcallawa@redhat.com>
Date:   Tue Jun 2 10:43:05 2009 -0400

    Replace the Sun RPC license with the BSD license,
    with the explicit permission of Sun Microsystems
    
    Signed-off-by: Tom "spot" Callaway <tcallawa@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2b8bc77817f45759346593eaedebaacddea05978
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 18 13:29:38 2009 -0400

    umount.nfs: Harden umount.nfs error reporting
    
    Add additional error reporting to nfs_advise_umount().
    These messages can be displayed if the "-v" option
    is specified with umount.nfs.  Normally these
    messages do not appear.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 383a026d99624c88c0e802103ef4c4865db8eb71
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 18 13:27:25 2009 -0400

    nfs-utils: Fix IPv6 support in support/nfs/rpc_socket.c
    
    Use the correct #ifdef variable to enable IPv6 support for privileged
    RPC clients.  Without this fix, unmounting an IPv6 NFSv2/v3 server
    fails.
    
    Introduced by commit 8c94296bc84f3a204f2061c0391a1d2350e4f37e.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e456ee18bfbe422750dfad36f0afe2583f412538
Author: Robert Schwebel <r.schwebel@pengutronix.de>
Date:   Mon May 18 11:36:14 2009 -0400

    When compiling nfs-utils-1.1.6, I get this error:
    
    arm-iwmmx-linux-gnueabi-gcc -DHAVE_CONFIG_H -I. -I../../support/include
    -isystem
    /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/include
    -isystem
    /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCORE-PXA270.PCM990/sysroot-target/usr/include
    -D_GNU_SOURCE -Wall -Wstrict-prototypes  -pipe -g -O2 -MT sm_inter_svc.o
    -MD -MP -MF .deps/sm_inter_svc.Tpo -c -o sm_inter_svc.o sm_inter_svc.c
    sm_inter_svc.c:10:39: error: sys/ttycom.h: No such file or directory
    
    Use sys/ioctl.h instead.
    
    Signed-off-by: Robert Schwebel <r.schwebel@pengutronix.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bfa1df2e24b7f8c7fee299049a6ee36e1262dacd
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 18 11:17:49 2009 -0400

    mount: remove legacy version of nfs_name_to_address()
    
    Currently we have two separate copies of nfs_name_to_address() since
    some older glibc's don't define AI_ADDRCONFIG.  This means extra
    work to build- and run-test both functions when code is changed in
    this area.
    
    It is also the case that gethostbyname(3) is deprecated, and should
    not be used in new code.
    
    Remove the legacy code in favor of always using getaddrinfo(3).
    
    We can also get rid of nfs_name_to_address()'s @family argument as
    well.
    
    Note also this addresses a bug in nfsumount.c -- it was calling
    nfs_name_to_address() with AF_UNSPEC unconditionally, even if the
    legacy version of nfs_name_to_address(), which doesn't support
    AF_UNSPEC, was in use.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5d253e3e326bfcf0e8a342bca53f1b4db120a7a9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 18 11:08:53 2009 -0400

    sm-notify: Failed DNS lookups should be retried
    
    Currently, if getaddrinfo(3) fails when trying to resolve a hostname,
    sm-notify gives up immediately on that host.  If sm-notify is started
    before network service is available on a system, that means it quits
    without notifying anyone.  Or, if DNS service isn't available due to
    a network partition or because the DNS server crashed, sm-notify will
    simply remove all of its callback files and exit.
    
    Really, sm-notify should try harder.  We know that the hostnames
    passed in to notify_host() have already been vetted by statd, which
    won't monitor a hostname that it can't resolve.  So it's likely that
    any DNS failure we meet here is a temporary condition.  If it isn't,
    then sm-notify will stop trying to notify that host in 15 minutes
    anyway.
    
    [ The host's file is left in /var/lib/nfs/sm.bak in this case, but
      sm.bak is not read again until the next time sm-notify runs. ]
    
    sm-notify already has retry logic for handling RPC timeouts.  We can
    co-opt that to drive DNS resolution retries.
    
    We also add AI_ADDRCONFIG because on systems whose network startup is
    handled by NetworkManager, there appears to be a bug that causes
    processes that started calling getaddinfo(3) before the network came
    up to continue getting EAI_AGAIN even after the network is fully
    operating.
    
    As I understand it, legacy glibc (before AI_ADDRCONFIG was exposed in
    headers) sets AI_ADDRCONFIG by default, although I haven't checked
    this.  In any event, pre-glibc-2.2 systems probably won't run
    NetworkManager anyway, so this may not be much of a problem for them.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3ab7ab5db0f825fdd95d017cdd6d6ee5d207dbe8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon May 18 11:03:54 2009 -0400

    sm-notify: Don't orphan addrinfo structs
    
    sm-notify orphans an addrinfo struct in its address list rotation
    logic if only a single result was returned from getaddrinfo(3).
    
    For each host, the first time through notify_host(), we want to
    send a PMAP_GETPORT request.  ->ai is NULL, and retries is set to 100,
    forcing a DNS lookup and an address rotation.  If only a single
    addrinfo struct is returned, the rotation logic causes a NULL to be
    planted in ->ai, copied from the ai_next field of the returned result.
    
    This means that the second time through notify_host() (to perform the
    actual SM_NOTIFY call) we do a second DNS lookup, since ->ai is NULL.
    The result of the first lookup has been orphaned, and extra network
    traffic is generated.
    
    This scenario is actually fairly common.  Since we pass
    
      .ai_protocol = IPPROTO_UDP,
    
      to getaddrinfo(3), for most hosts, which have a single forward and
      reverse pointer in the DNS database, we get back a single addrinfo
      struct as a result.
    
      To address this problem, only perform the address list rotation if
      there is more than one element on the list returned by getaddrinfo(3).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c88c4091db87c0fc23ed67e76d63439b59a82369
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon May 18 10:50:11 2009 -0400

    utils/nfsd: enable nfs minorvers4 by default
    
    Enable support for the maximum minor version (4.1 at the moment)
    by default.  It can be disabled using the -N command line
    option.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7bd86b3cfb0d929ce1dae2b937c3ac9048e23644
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon May 18 10:47:51 2009 -0400

    Extend -N command line option syntax to accept
    <version>.<minorversion> to disable support
    for <minorversion>. Only 4.1 is currently supported.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b750909f50fb184cb82344d40a150f0d2760ef21
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon May 4 11:44:49 2009 -0400

    utils/nfsd: add support for minorvers4
    
    minorvers4 can be used to either enable or disable nfsv4.x.
    
    If minorvers4 is a positive integer n, in the allowed range (only
    minorversion 1 is supported for now), the string "+4.n" is appended
    to the versions string written onto /proc/fs/nfsd/versions.
    
    Correspondingly, if minorver4 is a negative integer -n, the string
    "-4.n" is written.
    
    With the default value, minorvers4==0, the minor version
    setting is not changed.
    
    Note that unlike the protocol versions 2, 3, or 4.  The minor version
    setting controls the *maximum* minor version nfsd supports.  Particular
    minor version cannot be controlled on their own.  With only minor
    version 1 supported at the moment the difference doesn't matter,
    but for future minor versions greater than 1, enabling minor
    version X will enable support for all minor versions 1 through X.
    Disabling minor version X will disable support for minor
    versions X and up, enabling 1 through X-1.
    
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6a72b8af3abaf3792702c834bab5a5049818f9c6
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Apr 29 12:38:02 2009 -0400

    Host aliases need to be checked when netgroups is used in exports.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

