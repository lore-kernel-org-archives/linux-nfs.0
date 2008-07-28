Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <488D718F.200@RedHat.com>
Date: Mon, 28 Jul 2008 03:13:19 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Subject: nfs-utils-1.1.3 released. 
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

I just cut the 1.1.3 nfs-utils release. Unfortunately I'm having
issues accessing my kernel.org account so for the moment the 
tar ball is only available on SourceForge:

     http://sourceforge.net/projects/nfs

As usual the tree is at:
    git://linux-nfs.org/nfs-utils

Here is the change log for this release:

commit 7f6ca07a8836dbdf30a227580441b99607639fd4
Author: Martin Leisner <Martin.Leisner@xerox.com>
Date:   Fri Jul 25 14:50:06 2008 -0400

    showmount issues
    
    The connect_nb() routne returns zero for success and a negative
    value for failure which was not being interpreted correctly
    by the getport() routine. This patch fixes that problem.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit eddfbf7ac8ecd3f17dc295df6c1dac4bbc6ca846
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jul 25 14:31:18 2008 -0400

    nfs(5) man page: Add documentation for the "mountproto=" option
    
    Looks like mountproto= was never documented in nfs(5).  Add a paragraph
    that describes it in the "nfs mount options" section.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit cf8a5cbe7f6e6ae546c3e48710b657e3d940c7fb
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jul 25 14:15:47 2008 -0400

    sm-notify: perform DNS lookup in the background.
    
    If an NFS server has no network connectivity when it reboots,
    it will block in sm-notify waiting for DNS lookup for a potentially
    large number of hosts.  This is not helpful and just annoys the
    sysadmin.
    
    So do the DNS lookup in the backgrounded phase of sm-notify,
    before sending off the NOTIFY requests.
    
    Acked-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ba8dd9533e647b70d6e46beed3dcd8d8036b02af
Author: Neil Brown <neilb@suse.de>
Date:   Wed Jul 16 13:28:52 2008 -0400

    If portmap is not listening on UDP (as apparently happens with
    MS-Windows-Server2003R2SP2), then nfs mounts have to be mounted
    with -o mountproto=tcp to succeed.
    
    In this case a umount will still try UDP and will fail to contact the
    server.  It will still succeed with the local unmount (after a
    timeout) but exits with a non-zero exit status.  This causes
    /bin/mount to retry so we get a strange error about the filesystem
    not being mounted.
    
    So:
      get umount to use tcp if "mountproto=tcp" appears in mtab
      ignore any failure message from the server that would overwrite
         a success message from the local umount syscall.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8508942e7244017325690e2d0c17429fa0cb9873
Author: Neil Brown <neilb@suse.de>
Date:   Wed Jul 16 13:15:46 2008 -0400

    If an NFS server is only listening on TCP for portmap (as apparently
    MS-Windows-Server2003R2SP2 does), mount doesn't cope.  There is retry
    logic in case the initial choice of version/etc doesn't work, but it
    doesn't cope with mountd needing tcp.
    So:
      Fix probe_port so that a TIMEDOUT error doesn't simply abort
        but probes with other protocols (e.g. tcp).
      Fix rewrite_mount_options to extract the mountproto option before
        doing a probe, then set mountproto  (and mount prot) based
        on the result.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8e158aa65577b96494eaa94c4983eed1449116dc
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Jul 15 14:43:00 2008 -0400

    It appears that a recent glibc update now enforces the requirement for a mode
    parameter for open calls with the O_CREAT flag set.  nfs-utils support code
    defines a function xflock used by exportfs and mountd that calls open with
    O_CREAT but no mode parameter.  This causes exportfs and mountd to dump core,
    with the error message:
    *** invalid open64 call: O_CREAT without mode ***:rpc.mountd terminated
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8dfb9661a132a206c10067f40e274cf797dab1b2
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:59:00 2008 -0400

    Clean up: Include the bare minimum of legacy RPC headers in
    utils/mount/network.h.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1a1d3757d8881000496b838ff7d1ede981e9c40d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:57:10 2008 -0400

    Clean up: remove unneeded headers from utils/mount/stropts.c.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 93cfabb56a0b85cffca9c75cfac59e687157d0cc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:55:36 2008 -0400

    Clean up: rename a couple of functions in utils/mount/stropts.c to match
    the naming convention of the others.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit abb44f59bd004112a217011a2560dd7c7f94b5a2
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:53:50 2008 -0400

    Clean up: remove unused IPv4-only functions used by the text-based mount
    command.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1d61a1116198714f50b081daecc663625124403d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:51:07 2008 -0400

    Traditionally the mount command has looked for a ":" to separate the
    server's hostname from the export path in the mounted on device name,
    like this:
    
     mount server:/export /mounted/on/dir
    
    The server's hostname is "server" and the export path is "/export".
    
    You can also substitute a specific IPv4 network address for the server
    hostname, like this:
    
     mount 192.168.0.55:/export /mounted/on/dir
    
    Raw IPv6 addresses present a problem, however, because they look something
    like this:
    
     fe80::200:5aff:fe00:30b
    
    Note the use of colons.
    
    To get around the presence of colons, copy the Solaris convention used for
    raw NFS server IPv6 addresses, which is to wrap the raw IPv6 address with
    square brackets.  This is also suggested in RFC 4038.
    
    Introduce a new device name parser that can support traditional device
    names and square brackets.  Place the parser in a separate source file
    so both the mount and umount paths can derive the server's hostname and
    export pathname the same way.
    
    Bonus points: add a check for NFS URLs and display an appropriate error
    message in that case.  This is cleaner than failing with "unknown host:
    nfs".
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 586a66451679e25c47cb8cd65a0c6a0c44148920
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:38:53 2008 -0400

    Change the fix_mounthost_option() function to support resolving IPv6
    addresses.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 313dcf93f7a8351ff1664a3a7e2a964e02ea624a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:37:07 2008 -0400

    Change the append_clientaddr_option() function to support sending either
    IPv4 or IPv6 addresses to the kernel via the "clientaddr=" option.
    
    If the mount.nfs4 command can't determine an appropriate callback address,
    it used to fail the mount request.  This new function simply sends an ANY
    address instead, so the mount request succeeds, but delegation is disabled.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1adb0e018f57079c6e95a9bdbf904361354b0527
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:34:49 2008 -0400

    Change the append_addr_option() function to support sending either IPv4
    or IPv6 addresses to the kernel via the "addr=" option.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit da8a62dc65d2d105a3304dd41b6bdae5a5ddc742
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:33:32 2008 -0400

    There are three helpers that convert sockaddr-style addresses to text
    addresses, then construct mount options to pass these addresses to the
    kernel.  The tail of each of these helpers does exactly the same thing,
    so introduce a helper that handles the common code.
    
    Magically, the new helper supports IPv6 as well as IPv4.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6ab9cdacd2ea314a837c7affb840aeeec620cb66
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:31:17 2008 -0400

    Introduce IPv6-enabled version of get_client_address.  The legacy mount
    command could use this eventually as well.
    
    If this new function fails to discover an appropriate callback address, it
    fills in an ANY address to indicate to the server that it should not call the
    client back (ie delegations are disabled in this case).
    
    The user can specify a callback address via the clientaddr= mount option in
    this case to enable delegation.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ffb42f63d41542bd2dab4570248d18642e39ed48
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:27:15 2008 -0400

    Introduce two new functions to convert a sockaddr to a presentation format
    string and back.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0ff226cb9dc9382c5215368a03a5bd3a69ee287a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:23:58 2008 -0400

    Add #include directives for additional header files needed to support IPv6
    networking.  This is a separate patch so subsequent
    patches can be reordered without collision.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 20db952fc211b3444d83049f2d127da4f3ca6989
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 13:20:01 2008 -0400

    We want to continue to support building nfs-utils on systems that do not
    have IPv6-enabled RPC libraries and headers installed, so add a
    ./configure switch that allows distros to disable IPv6 functionality.
    
    This patch introduces the nfs-utils autotools configuration to the library
    and header dependencies that will be required in subsequent patches.
    Later patches can then be reordered more easily if these new dependencies
    are added in one heap.
    
    For now, --enable-ipv6 defaults to "no", so this patch should not result in
    any behavioral changes to the nfs-utils build process, by default.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8bca04ebcc345784bf2ef29f0781e66157d76558
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 12:17:19 2008 -0400

    Currently the "-s" option is ignored by the text-based mount interface.  To
    notify the kernel that sloppy mount option parsing is needed, add "sloppy"
    to the string of mount options passed to the kernel.
    
    The 2.6.23 - 2.6.26 kernels will fail the mount if "sloppy" is present, as
    they won't recognize it.  To prevent them from ever seeing this option,
    have the mount command check the kernel version before appending the option.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 46c6575fe23a7468c17ec3329d956e9d3afe60e8
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 12:15:29 2008 -0400

    Lots of parts of nfs-utils already depend on getaddrinfo(3).
    
    We could find each instance where getaddrinfo(3) is invoked, wrap it with
    '#ifdef HAVE_GETADDRINFO', and provide equivalent logic without it, but that's
    a whole lot of work... and no-one has complained about this so far.
    
    So as a clean-up, let's simply add a hard dependency for it in configure.ac,
    and call it a day.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1ca49510fd1742955330583f259db7faf501a5e5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 12:13:10 2008 -0400

    Clean up: add the traditional pre-processor safety check in headers under
    utils/mount to prevent them from being included multiple times.
    
    For headers that already have this, use a more unique macro name to reduce the
    probability that some other header may use the same macro.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d5a09b59916d4ef24b15e34eac394149cb7a641a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 12:10:33 2008 -0400

    Moved the kernel version-ing code into a new version.h
    header file which allows the code to be shared
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4f101548ef4990979400b7095e199c30204b100a
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 12:02:42 2008 -0400

    Introduce a new DNS resolver function in utils/mount/network.c that uses
    getaddrinfo(3), which supports AF_INET6, to resolve host names.
    
    Replace the guts of nfs_gethostbyname() with a call to the new function.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 52fe32278aee9f359d4ef6d1fab7be405ca0b193
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 11:59:03 2008 -0400

    The text-based mount command displays the rather inexplicable "mount:
    internal error" whenever it encounters a problem that is entirely
    unexpected by its designers.
    
    Let's beef that error message up to include instructions about reporting
    the problem, and fix the error code returned by the mount option rewriting
    logic so that also will no longer report "internal error".  An error in there
    should generally only occur if there was an invalid mount option specified.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 191d129672dacdc3ae3ac165cd1f2a877529d0ad
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 15 11:56:13 2008 -0400

    Updated both the mountstats and nfs-iostat scripts to used the
    proper abbreviation for kilobytes per second (kB/s).
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 58080798db321d025143df39c97f707ea994ba26
Author: Christiaan Welvaart <cjw@daneel.dyndns.org>
Date:   Tue Jul 15 11:42:42 2008 -0400

    Ported the create_mtab() routine from util-linux-ng as well
    some add_mtab() updates to better hand the instances where
    /etc/mtab does not exist or is not writable
    
    Signed-off-by: Christiaan Welvaart <cjw@daneel.dyndns.org>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit afa859b029d9cd15604ce7d5f88b5a205ea4c774
Author: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date:   Tue Jul 15 10:12:39 2008 -0400

    The rpc.gssd scans for any suitable kerberos ticket. In cross-realm
    environment this may not be the desired behaviour. Therefore a new
    option, -R preferred realm, is presented so that the rpc.gssd prefers tickets
    from this realm. By default, the default realm is preferred.
    
    Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1e1c7be98749fff054beec4bf67b436b58f6edac
Author: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date:   Tue Jul 15 10:07:45 2008 -0400

    The default expiration of kernel gss contexts is the expiration
    of the Kerberos ticket used in its creation.  (For contexts
    created using the Kerberos mechanism.)  Thus kdestroy has
    no effect in nullifying the kernel context.
    
    This patch adds -t <timeout> option to rpc.gssd so that the client's
    administrator may specify a timeout for expiration of contexts in kernel.
    After this timeout, rpc.gssd is consulted to create a new context.
    
    By default, timeout is 0 (i.e., no timeout at all) which follows the
    previous behavior.
    
    Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b13f13b0f2ebdadc47eef8bf3fd4eb076e144fda
Author: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date:   Tue Jul 15 10:02:49 2008 -0400

    gssd_setup_krb5_user_gss_ccache must return an error if no usable cache is
    found. Trying to use invalid default cache and continue is not good idea at all.
    
    Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 710765a87d599d95de51b79202ba3d82fd03ed95
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jun 25 09:23:45 2008 -0400

    When a FQDN exists in /var/lib/nfs/rmtab it causes
    the exportfs command to seg fault due to the nfs_export pointer
    not being allocated. Reworking the parentheses in rmtab_read()
    so the htype variable is evaluated correctly fix the problem.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2ef57222b10a91f4b96a06808d05a47e8f4c14f7
Author: Tom Talpey <tmt@netapp.com>
Date:   Mon Jun 23 12:57:29 2008 -0400

    Add RDMA as a supported transport for reporting
    the mountstats statistics
    
    Signed-off-by: Tom Talpey <tmt@netapp.com>
    Acked-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ba18e469a8507befdf8969c5ce7a25564744ae01
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jun 23 12:56:14 2008 -0400

    The "nfs-iostat" utility is a Python program that extracts and displays NFS
    client performance information from /proc/self/mountstats.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 589a913e42476a965b686c9f2656b786eaae399e
Author: Tom Talpey <tmt@netapp.com>
Date:   Mon Jun 23 12:54:08 2008 -0400

    Add RDMA as a supported transport for reporting the
    mountstats statistics
    
    Signed-off-by: Tom Talpey <tmt@netapp.com>
    Acked-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c761709ad3abb9c36a68c269f78118bf49d79639
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Jun 23 12:52:33 2008 -0400

    The "mountstats" utility is a Python program that extracts and displays NFS
    client performance information from /proc/self/mountstats.
    
    Note that if mountstats is named 'ms-nfsstat' or 'ms-iostat' it offers
    slightly different functionality.  It needs two man pages and the install
    script should provide both commands by installing the script and providing the
    other command via a symlink.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5be04020788598cb811e51c4b1342cf0796cbb65
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Jun 23 07:21:52 2008 -0400

    The nfsstat program reads /proc/net/rpc/* files to gets info about
    calls. This info is output as unsigned numbers (at least on any
    relatively recent kernel). When nfsstat prints these numbers, they are
    printed as signed integers. When the call counters reach 2^31, things
    start being printed as negative numbers.
    
    This patch changes nfsstat to read and print all counters as unsigned
    integers. Tested by hacking up a kernel to initialize call counters to
    2^31+1.
    
    Thanks to Takafumi Miki for the initial version of this patch.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c6acce67dce1cf89742a6bc4635c1eeda82e9591
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jun 6 17:27:23 2008 -0400

    Removed the initialization of args2 in xlog_backend. It
    caused a compilation error on x86_64 archs.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d03090be4f440d70328988e9f792f3bd0ebd956b
Author: Neil Brown <neilb@suse.de>
Date:   Fri Jun 6 15:17:55 2008 -0400

    nfsstat -m lists all current nfs mounts, with the mount options.
    It does this by reading /proc/mounts and looking for mounts of type
    "nfs".  It really should check for "nfs4" as well.
    
    For simplicity, just check the first 3 characters of the type.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 52dff26c60c07cf1b4fbf8fbd3a1eab7ba90405f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jun 6 15:07:24 2008 -0400

    Fix error reporting when probe_bothports() fails while rewriting mount
    options.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c641800eb0fcaa819199e58e5c4c8d1c2a9dab5d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jun 6 15:06:21 2008 -0400

    Clean up: instead of passing so many arguments to all the helpers, have
    nfsmount_string build a data structure that contains all the arguments, and
    pass a pointer to that instead.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d7a1070383bcf40d32c7f10e535ba443209dedef
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Fri Jun 6 15:02:18 2008 -0400

    Steinar Gunderson reports:
    
    "It seems retry= is now additive with the text-based mount interface. In
    particular, "mount -o retry=0" still gives a two-minute timeout."
    
    Correct the bug and make retry= option parsing more robust.  If parsing
    the retry option fails, the option is ignored and a default timeout is
    used.
    
    Note that currently the kernel parser ignores the "retry=" option if the
    value is a number.  If the value contains other characters, the kernel will
    choke.  A subsequent patch to the kernel will allow any characters as the
    value of the retry option (excepting of course ",").
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 331c2ca949d5b4b4d18d0aca90afb8ae9475bcd6
Author: Neil Brown <neilb@suse.de>
Date:   Fri Jun 6 14:59:21 2008 -0400

    Make the text-based mount path check whether statd is running if the "lock"
    option is in effect.  This echoes similar logic in the legacy mount path.
    
    Signed-off-by: Neil Brown <neilb@suse.de>
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fd54675db0806e81c17ee7e7eec0abfcd33f1f23
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jun 6 14:44:48 2008 -0400

    Cleaned up warnings in rmtab.c and xlog.c
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7ef076fb98233783843d6019b2edbb48e2d18914
Author: Oren Held <oren@held.org.il>
Date:   Thu May 8 05:23:10 2008 -0400

    Fixed smail typo in exportfs man page
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0930b25ee3a1eb28b957cdc70c9a1958812d895f
Author: NeilBrown <neilb@suse.de>
Date:   Thu May 8 05:18:25 2008 -0400

    If mount.nfs is not installed setuid, an attempt to perform a "user"
    or "users" mount will fail with a fairly obscure error message,
    typically about getting "permission denied" from the server.
    
    This patch gives a more helpful message in that case.
    
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 25cd5f9101b8969f9e1f9d7d486f11c215d0eeb4
Author: Vince Busam <vbusam@google.com>
Date:   Wed May 7 15:24:53 2008 -0400

    Kerberos credentials may be stored in multiple places.  Make it
    possible to search several directories for valid credentials when
    making NFS requests.
    
    Original patch from Vince Busam <vbusam@google.com>
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>.
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 73f9b4402ec6625618967f947c99e6e417322d36
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed May 7 14:38:47 2008 -0400

    Add a new function to retrieve the current verbosity level
    so that some messages that would otherwise always print may
    be silenced.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 313ab396c04afe160ee6764e28b5e61ce19c46d9
Author: Kevin Coffman <kwc@citi.umich.edu>
Date:   Wed May 7 14:32:45 2008 -0400

    Add the other two DES encryption types to the default list of
    Kerberos encryption types that may be negotiated.
    
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a04f8b5a3ea94b7a9d96d339b6ccde5f2e67a2d1
Author: Olga Kornievskaia <aglo@citi.umich.edu>
Date:   Wed May 7 10:54:51 2008 -0400

    Check the info file nfs/rpc_pipefs/nfs/clnt?/info to
    see if a port number was supplied. If so, use it rather
    than the default port number.
    
    Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
    Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5fb4042ce4eb4fd5e50e3fb0f78bbd20b4d46e78
Author: Jeff Layton <jlaton@redhat.com>
Date:   Wed May 7 10:37:40 2008 -0400

    The prev_bg_host stuff made sense when NFS didn't have its own mount
    handler. Now though, each mount.nfs invocation is really a one-shot
    affair, and this check no longer works. It also leaked memory. Remove
    it.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 281ca299724f24e7b19c1eca04bba03410e2a306
Author: Jeff Layton <jlaton@redhat.com>
Date:   Wed May 7 10:35:30 2008 -0400

    The bg option is essentially ignored with nfs4 currently. nfs4mount()
    will never exit with EX_BG, so the mount will never be backgrounded.
    Fix it so that when bg is specified that we error out with EX_BG as
    soon as possible after the first failed mount attempt.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5f7cc524008a7dc548a71f4c7b0d39759371a37a
Author: Jeff Layton <jlaton@redhat.com>
Date:   Wed May 7 10:27:53 2008 -0400

    Currently nfs4mount() sets the retry value to 10000 on both fg and bg
    mounts. It should be 2 for fg and 10000 for bg. nfsmount() sets it
    properly, but there is a potential corner case. If someone explicitly
    sets retry=10000 on a fg mount, then it will be reset to 2.
    
    Fix this by having retry default to -1 for both flavors, and then reset if
    needed after the mount options have been parsed.
    
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ad1fc3feae447685a8ec8c7db0ad913fe3c4de5c
Author: Sten Spans <sten@blinkenlights.nl>
Date:   Mon May 5 14:04:58 2008 -0400

    Fixed arguments to the hosts_ctl() call in the good_client() routine
    used in the tcpwrapper support.
    
    Signe-off-by: Steve Dickson <steved@redhat.com>

commit 697e28939b7d0a3e0ffe3b6bd516213a55f5a063
Author: Jeff Layton <jlaton@redhat.com>
Date:   Mon Apr 14 09:03:13 2008 -0400

    Change how mount.nfs handles EACCES errors. Currently,
    EACCES is a non-fatal error which means the mount will be
    retied. This caused mounts to hang for 2mins when the client
    does not have permission to access the export. In a strict
    interpretation, the error that should be returned is EPERM, but
    this is not always the case. So due to the fuzzy interpretation,
    of EPERM and EACCES, EACCESS is now a fatal error
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 7d9dcf303b30aeb8b3dc06616d42a8abbdc61b27
Author: Li Yewang <lyw@cn.fujitsu.com>
Date:   Wed Apr 9 13:39:20 2008 -0400

    Correct a spelling error in a mount.nfs error message
    
    Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3899db6d602901523d6db6e2280c3bffd6c9ed63
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Mar 18 09:34:58 2008 -0400

    Make sure showmount fails when rpc.mountd is not registered
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fa29d7a9a3d8a72b79924d28813eef7e55a25bc9
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Mar 18 09:33:44 2008 -0400

    Updated exportfs man to talk about /var/lib/nfs/etab
    instead of /var/lib/nfs/xtab
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3c1bb23c0379864722e79d19f74c180edcf2c36e
Author: bc Wong <bcwong@cisco.com>
Date:   Tue Mar 18 09:30:44 2008 -0400

    There were 2 things wrong with auth flavour ordering:
    - Mountd used to advertise AUTH_NULL as the first flavour on
      the list, which means that it prefers AUTH_NULL to anything
      else (as per RFC 2623 section 2.7).
    - Mount.nfs used to scan the returned list in reverse order,
      and stopping at the first AUTH_NULL or AUTH_SYS encountered.
      If a server advertises (AUTH_SYS, AUTH_NULL), it will by
      default choose AUTH_NULL and have degraded access.
    
    I've fixed mount.nfs to scan from the beginning. For mountd,
    it does not advertise AUTH_NULL anymore. This is necessary
    to avoid backward compatibility issue. If AUTH_NULL appears
    in the list, either the new or the old client will choose
    that over AUTH_SYS.
    
    Tested the server/client combination against the previous
    versions, as well as Solaris and FreeBSD.
    
    Signed-off-by: bc Wong <bcwong@cisco.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>



steved.

     
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
