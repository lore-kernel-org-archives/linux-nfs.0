Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <4AF17E79.3020502@RedHat.com>
Date: Wed, 04 Nov 2009 08:15:37 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
Subject: nfs-utils-1.2.1 released.
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="iso-8859-1"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

New Features in this release:

   * NFS version 4 will be the first version to be tried on client mounts.=
=20
     If the server does not support version 4, the mounts will roll=20
     back to version 3 and then version 2.

   * The mount options v4, nfsvers=3D4 and vers=3D4 are added.

   * With the --enable-mountconfig set during configuration time
     a mount configuration file can be used to set mount options
     per mount point, per server or globally. See nfsmount.conf(5)


The tarball can be found at:

  http://www.kernel.org/pub/linux/utils/nfs/
  http://sourceforge.net/projects/nfs

The git tree is at:
   git://linux-nfs.org/nfs-utils

The change log:

commit 67e6d2d8a96e98d7f21693a9d034da81d3f90084
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Nov 4 06:13:56 2009 -0500

    Release 1.2.1
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5df68929ceef7742f7669ba5925ea31b7b5a699c
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Nov 3 15:11:09 2009 -0500

    Fixed configuration error when --disable-mount was used.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 97731f394c6b83ed7e5c3923278bbe98ee130bee
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 3 11:19:08 2009 -0500

    mount: Fix po_join() call site in nfs_try_mount_v4()
   =20
    Make sure the copied options string is freed in case po_join() fails.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e4328bb8d13ae6dda33308557e6bbb352d5674bb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Nov 3 11:16:30 2009 -0500

    mount.nfs: Assume v2/v3 if mount-related options are	present
   =20
    Don't try NFSv4 if any MNT protocol related options were presented by
    the user.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 57af0cce3ed6f555bb40132d667e8b10d41855ca
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Nov 3 10:37:36 2009 -0500

    Made some aesthetic changes to the code that sets
    the defaults that were a result of the code review.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e1eccc5fc317f73801522b3b498c6dab67b048d2
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Nov 3 09:49:03 2009 -0500

    Retry v4 mounts with a v3 mount when the version
    is not explicitly specified and the mount fails
    with ENOENT. The will help deal with Linux servers
    that do not automatically export a pseudo root
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1af166179c3f28fa9943f7844e03032f3bdae7ea
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Oct 27 15:47:27 2009 -0400

    Added wrappers around the setting of default values
    from the config file which will be compiled out
    when the config file is not enabled.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 37122505cab9a3370e06a147efde36262371e664
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Oct 22 15:35:54 2009 -0400

    Added the defaultproto and defaultvers variable to the mount
    configuration file.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a8b90e8f64a7d53b20c0980f2a6d9a8d5945bcc4
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Oct 17 09:26:18 2009 -0400

    Use the default protocol and version values, when they
    are set in the configuration file, to start the negation
    with the server
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2f61f62ac777cc03e30513f6fd3699f9e2f04e27
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Oct 17 09:16:18 2009 -0400

    Introducing the parsing of both 'defaultvers' and 'defaultproto'
    config variables which will be used to set the the default
    version and network protocol.
   =20
    A global variable will be set for each option with the
    corresponding value. The value will be used as the
    initial value in the server negation.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f87ae8235ae6042c0e514ba03e4eee7782d5bc6e
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Oct 9 13:22:27 2009 -0400

    Make sure all protocol version options are checked in check_vers()
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f312676ca61f826efa5d0eb39433c5aa075711ab
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Oct 9 13:14:52 2009 -0400

    Make the network transports value in the mount
    config file case sensitive, since they are in the
    mount command's parsing code.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2091bc67253d6dc1f68dba2218593701bfc729c0
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Oct 9 09:19:39 2009 -0400

    There are a number of different mount options that can be
    used to set the protocol version on the command line. The
    config file code needs to know about each option so the
    command line value will override the config file value.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0e0526cce8127f1c18063ff700f5e4d5c77dc108
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 29 10:38:52 2009 -0400

    mount: Support negotiation between v4, v3, and v2
   =20
    When negotiating between v3 and v2, mount.nfs first tries v3, then v2.
    Take the same approach for v4: try v4 first, then v3, then v2, in
    order to get the highest NFS version both the client and server
    support.
   =20
    No MNT request is needed for v4.  Since we want to avoid an rpcbind
    query for the v4 attempt, just go straight for mount(2) without a MNT
    request or rpcbind negotiation first.  If the server reports that v4
    is not supported, try lower versions.
   =20
    The decisions made by the fg/bg retry loop have nothing to do with
    version negotation.  To avoid a layering violation, mount.nfs's
    multi-version negotiation strategy is wholly encapsulated within
    nfs_try_mount().  Thus, code duplication between nfsmount_fg(),
    nfsmount_parent(), and nfsmount_child() is avoided.
   =20
    For now, negotiating version 4 is supported only on kernels that can
    handle the vers=3D4 option on type "nfs" file systems.  At some point
    we could also allow mount.nfs to switch to an "nfs4" file system in
    this case.
   =20
    Since mi->version =3D=3D 0 can now mean v2, v3, or v4, limit the versio=
ns
    tried for RDMA mounts.  Today, only version 3 supports RDMA.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0de3189d32a183f5e91a6d27a9e8f159216d9473
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 29 10:38:05 2009 -0400

    The user's mount options and the set of versions to try should not
    change over the course of mount retries.
   =20
    With this patch, each version-specific mount attempt is compartment-
    alized, and starts from the user's original mount options each time.
    Thus these attempts can now be safely performed in any order,
    depending on what the user has requested, what the server advertises,
    and what is up and running at any given point.
   =20
    Don't regress the fix in commit 23c1a452.  For v2/v3 negotation, only
    the user's mount options are written to /etc/mtab, and not any options
    that were negotiated by mount.nfs.  There's no way to guarantee that
    the server configuration will be the same at umount time as it was at
    mount time.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3faa54e8a17411de28c7b707207d49b4466ae873
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 29 10:37:12 2009 -0400

    mount.nfs: Keep server's address in nfsmount_info
   =20
    We want to pass the server's address around.  Put it in the mount
    context structure.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 88c4f664f869d7450b84f0262fd87fbda4f1f61b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Sep 29 10:36:19 2009 -0400

    mount.nfs: Add API to duplicate a mount option list
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5f06c2b5e18990a2d62987ea06bdf5afb8306a2d
Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
Date:   Tue Sep 15 14:42:47 2009 -0400

    nfs-utils: nfs-iostat.py autofs cleanup and option to sort by ops/s
   =20
    Adds --sort option to display mount point stats sorted by ops/s
    Adds --list=3D<n> option to only display stats for first <n> mount poin=
ts
    E.g. the use of "--sort --list=3D1" should be useful in seeing stats fo=
r
    only the mountpoint with the highest ops/s.
   =20
    Signed-off-by: Lans Carstensen <Lans.Carstensen@dreamworks.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c3203ff9a940e1e2270e06673eca77066aabd77c
Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
Date:   Tue Sep 15 14:41:46 2009 -0400

    nfs-utils: nfs-iostat.py autofs cleanup and option to sort by ops/s
   =20
    Introduce optparse for managing command usage/help and the statistics
    options. This change helps more cleanly add new options such as --sort
    while preserving the iostat-like interval, count, and mount point
    positional arguments.
   =20
    Signed-off-by: Lans Carstensen <Lans.Carstensen@dreamworks.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 88deba4a8db06d371659aa85b668460b85900d48
Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
Date:   Tue Sep 15 14:31:35 2009 -0400

    nfs-utils: nfs-iostat.py autofs cleanup and option to sort by ops/s
   =20
    Update list of mount points at each interval and check for differences
    when producing comparative stats.  This ensures proper stats collection
    for autofs mountpoints.
   =20
    Signed-off-by: Lans Carstensen <Lans.Carstensen@dreamworks.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8e0ca8f2b6152efe58fbf78648bb889ab76a3d43
Author: Lans Carstensen <Lans.Carstensen@dreamworks.com>
Date:   Tue Sep 15 14:30:50 2009 -0400

    nfs-utils: nfs-iostat.py autofs cleanup and option to sort by ops/s
   =20
    Conforms Python path to the LSB 3.2+ standard of /usr/bin/python
    http://refspecs.freestandards.org/LSB_3.2.0/LSB-Languages/LSB-Languages=
/pylocation.html
    Per SteveD this is also required for proper rpm dep resolution during
    builds
   =20
    Signed-off-by: Lans Carstensen <Lans.Carstensen@dreamworks.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b25c022e58c53cedfd6bd9592f082364d002821b
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Sep 14 14:06:53 2009 -0400

    idmapd: rearm event handler after error in nfsdcb()
   =20
    A couple of years ago, Bruce committed a patch to make knfsd send
    unsigned uid's and gid's to idmapd, rather than signed values. Part
    of that earlier discussion is here:
   =20
    http://linux-nfs.org/pipermail/nfsv4/2007-December/007321.html
   =20
    While this fixed the immediate problem, it doesn't appear that anything
    was ever done to make idmapd continue working when it gets a bogus
    upcall.
   =20
    idmapd uses libevent for its main event handling loop. When idmapd gets
    an upcall from knfsd it will service the request and then rearm the
    event by calling event_add on the event structure again.
   =20
    When it hits an error though, it returns in most cases w/o rearming the
    event. That prevents idmapd from servicing any further requests from
    knfsd.
   =20
    I've made another change too. If an error is encountered while reading
    the channel file, this patch has it close and reopen the file prior to
    rearming the event.
   =20
    I've not been able to test this patch directly, but I have tested a
    backport of it to earlier idmapd code and verified that it did prevent
    idmapd from hanging when it got a badly formatted upcall from knfsd.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 74badf6f30f7aea95e9d784244488084dbadcb55
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Mon Sep 14 13:55:36 2009 -0400

    mount.nfs: Support "-t nfs,vers=3D4" mounts in the kernel
        Support "vers=3D4" in nfs_nfs_version()
   =20
        Skip UMNT call for "-t nfs -o vers=3D4" mounts
   =20
    	For "-t nfs -o vers=3D4" mounts, we want to skip v2/v3
    	version/transport negotiation, but be sure to append
    	the "clientaddr" option.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>
    Tested-by: Steve Dickson <steved@redhat.com>

commit b2a3cd590442309d40e9dd6d43213445df250694
Author: Jeff Layton <jlayton@redhat.com>
Date:   Mon Sep 14 13:24:00 2009 -0400

    IPv6 support for nfsd was finished before some of the other daemons
    (mountd and statd in particular). That could be a problem in the future
    if someone were to boot a kernel that supports IPv6 serving with an
    older nfs-utils. For now, hardcode the IPv6 switch into the off positio=
n
    until the other daemons are functional.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bd947185cfc7978c562fddf2f14f602c44a5cac9
Author: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Date:   Thu Aug 27 11:42:24 2009 -0400

    Gssd blindly caches machine credentials
   =20
    We have a problem with rpc.gssd which blindly caches machine credential=
s.
    E.g., if someone deletes /tmp/krb5cc_machine_REALM, rpc.gss does not cr=
eate
    new one until the old one expires. Also, it has problems with clock ske=
w, if
    time goes back and gssd thinks that machine credentials are not expired=
 yet.
   =20
    The following patch tries to use cache but in case of failure, it tries=
 it
    again without cache. Any comments?
   =20
    Signed-off-by: Lukas Hejtmanek <xhejtman@ics.muni.cz>
    Acked-by: Kevin Coffman <kwc@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1d2951b518dd5df4fc0a637880d204f0f4e949c5
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Aug 27 11:31:08 2009 -0400

    Cleaned up some warnings in the mount config file code.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9999c036952eced407162c394ea69145752ea5c4
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Aug 24 08:20:10 2009 -0400

    Don't give client an empty flavor list
   =20
    In the absence of an explicit sec=3D option on an export, rpc.mountd
    is returning a zero-length flavor list to clients in the MOUNT results.
   =20
    The linux client doesn't seem to mind, but the Solaris client
    (reasonably enough) is giving up; the symptom is a "security mode
    does not match" error on mount.
   =20
    We could modify the export-parsing code to ensure the secinfo array
    is nonzero.  But I think it's slightly simpler to handle this default
    case in the implementation of the MOUNT call.  This is more-or-less the
    same thing the kernel does when mountd passes it an export without any
    security flavors specified.
   =20
    Thanks to Tom Haynes for bug report and diagnosis.
   =20
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fd51c0c39017f44ceec4229f86eaa7c8e193ebdc
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Aug 17 08:50:04 2009 -0400

    Cleaned up parsing errors to hopeful be more precise
   =20
    Also had mount_config_init() call xlog_open() so
    the program name is set on xlog() calls.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4d0175ad400ec56456765a15829557f1d541866a
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Mon Aug 17 07:12:03 2009 -0400

    Added support for line comments parsing which should
    help with readability with in the configuration file.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8414d150cee62ba0554cfd645956a88dba02a7eb
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Aug 7 14:34:42 2009 -0400

    Now that only the Section names are case-insensitive
    the mount code has to make sure the the mount options
    given to the kernel are in the correct case.
   =20
    Fixed a couple of warnings on #ifndefs
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a0caba9887474cdc9b9ba8b113a869ff7954ab84
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 17:07:21 2009 -0400

    The example nfsmount.conf file
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4d18845fee7c6f5fc3d987fd9d3b5c5215c9e68b
Author: Steve Dickson <steved@redhat.com>
Date:   Sun Aug 16 17:05:56 2009 -0400

    The new nfsmount.conf(5) man page and the update to
    the nfs(5) man page
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9082582d6675e45067838805a65b6fcc07164557
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Aug 7 14:29:07 2009 -0400

    Added hooks to the mount command that allow
    mount options to be set in a configuration file
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0cdb36e69a51eabc119de314e43d40daf6ee49ab
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 16:17:38 2009 -0400

    Support routines used to read sections from the configuration file
    and parse them into comma separated mount options.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1d1f701656f86c54b07e7fd9481d1f45018cfddb
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 16:10:01 2009 -0400

    Adds '--enable-mountconfig' configuration flag that will
    enabled mount to read from a configuration file.
    The default value is disabled (or no)
   =20
    Adds '--with-mountfile' configuration flag that is used when
    mountconf is enabled to define the configuration file name.
    The default is /etc/nfsmount.conf.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9350a97a266ada8d8b3282cf4248e3b9ffdc0058
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 16:02:33 2009 -0400

    Added an conditional argument to the Section names
    with the format being:
       [ Section <"argument"> ]
    This will help group similar functioning Section
    together. The argument is conditional but must be
    surrounded by the '"' characters.
   =20
    The new conf_get_section() interface can used
    to locate a Section by its Section name and/or
    argument.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c6a270ea8ab6ad299e6a43445420f22e0c617e3e
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 15:53:36 2009 -0400

    Make Section names case-insensitive which should
    help in locating them resulting in make the config
    files a bit less error prone
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit a61e7ab6dbf7e3d6ad4e6377c96748dfaf353542
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 13:55:25 2009 -0400

    Taught conf_parse_line() to ignore spaces in the
     '[section]' parsing and before the assignment statements
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1a9010602442f466d700fbc4d64fe82ac69b1dd3
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Aug 5 15:47:05 2009 -0400

    Move idmapd's configuration file parsing routines into
    the shared libnfs.a library, making them available to\
    other daemons and programs.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b7a68e47bb869f3c4895a176018c4ee054214fc2
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Sun Aug 16 16:39:07 2009 -0400

    Augment nfs4 stats to cover new nfs41 client and
    server operations' stats.
   =20
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit cd6d0c9258ed96f4e7721987061969394426810d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 16 16:31:31 2009 -0400

    nfs(5): Remove trailing blanks
   =20
    Clean up: eliminate trailing blanks in utils/mount/nfs.man.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1b5aeac23eea499db3bdc02857070f12e258609c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Sun Aug 16 16:23:36 2009 -0400

    nfs(5): Add description of lookupcache mount option
   =20
    See kernel commit 7973c1f1.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit bc0a6ab03089fc1ea4fea26ed9635c2cc918b01b
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sun Aug 16 16:18:17 2009 -0400

    Since
   =20
    	2d77e3a27b7b211f303f.. "Fix bug when both crossmnt and fsid are set"
   =20
    Subexports automatically created by "crossmnt" get the NFSEXP_FSID flag
    cleared.  That flag should also be cleared in the
    security-flavor-specific flag fields.  Otherwise the kernel detects the
    inconsistent flags and rejects the export.
   =20
    The symptoms are clients hanging the first time they export a filesyste=
m
    mounted under a filesystem that was exported with something like:
   =20
    	/exports *(crossmnt,fsid=3D0,sec=3Dkrb5)
   =20
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ceb090c16e3a9f0509b3eb5e703c91a89d5a25f0
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Aug 14 13:42:22 2009 -0400

    Add some clarification about the purpose of the program, info about the
    --debug and --syslog options, and a note about how it behaves when
    TI-RPC support is built in.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 542b5ba9e68a6bbabe9b29b5d29b5b793b3e8d4f
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Aug 14 13:37:12 2009 -0400

    nfs-utils: add IPv6 support to nfsd
   =20
    Add support for handing off IPv6 sockets to the kernel for nfsd. One of
    the main goals here is to not change the behavior of options and not to
    add any new ones, so this patch attempts to do that.
   =20
    We also don't want to break anything in the event that someone has an
    rpc.nfsd program built with IPv6 capability, but the knfsd doesn't
    support IPv6. Ditto for the cases where IPv6 is either not compiled in
    or is compiled in and blacklisted.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 513acad321c325207a9d8f7f0129253b0e2b6d11
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Aug 14 13:33:02 2009 -0400

    Allow nfssvc_setfds to properly deal with AF_INET6.
   =20
    IPv6 sockets for knfsd can't be allowed to accept IPv4 packets. Set the
    correct option to prevent that from occurring on IPv6 sockets.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 094b26031a376050d8610d055eb01c7949ad6547
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Aug 14 13:30:04 2009 -0400

    nfs-utils: convert nfssvc_setfds to use getaddrinfo
   =20
    Convert nfssvc_setfds to use getaddrinfo. Change the args that it takes
    and fix up nfssvc function to pass in the proper args. The things that
    nfssvc has to do to call the new nfssvc_setfds is a little cumbersome
    for now, but that will eventually be cleaned up in a later patch.
   =20
    nfs-utils: break up the nfssvc interface
   =20
    Currently, the only public interface to the routines in nfssvc.c is
    nfssvc(). This means that we do an awful lot of work after closing
    stderr that could be done while it's still available.
   =20
    Add prototypes to the header so that more functions in nfssvc.c can be
    called individually, and change the nfsd program to call those routines
    individually.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4c477855cd025a18ac9decaf1bc9002aaae75689
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sat Aug 1 07:31:36 2009 -0400

    nfs-utils: move check for active knfsd to helper function
   =20
    nfssvc_setfds checks to see if knfsd is already running. Move this
    check to a helper function. Eventually the nfsd code will call this
    directly.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 775dea70ccc7556ac613def7896b3d3c1ff85ab5
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sat Aug 1 07:21:26 2009 -0400

    nfs-utils: declare a static common buffer for nfssvc.c routines
   =20
    Several of the routines in nfssvc.c declare a buffer for strings. Use a
    shared static buffer instead to keep it off of the stack. Also, the
    buffer allocated in some places is *really* large. BUFSIZ is generally
    8k. These routines don't need nearly that much.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 0d53a1d0ff5635d3af2f0d10e1f00f5de1353490
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sat Aug 1 07:20:38 2009 -0400

    nfs-utils: clean up NFSCTL_* macros for handling protocol bits
   =20
    They are a little hard to follow currently. Clean them up and add new
    macros that can set these bits in addition to the ones that unset them.
   =20
    Also add a new macro that reports when any valid protocol bit is set.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6f25394cb5651e7e44cc3fc0b2b4b2ccba8c3625
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sat Aug 1 06:27:40 2009 -0400

    nfs-utils: convert rpc.nfsd to use xlog()
   =20
    ...and add --debug and --syslog options.
   =20
    With the switch to xlog(), it becomes trivial to add debug messages, so
    add an option to turn them on when requested.
   =20
    Also, rpc.nfsd isn't a proper daemon per-se, so it makes more sense to
    log errors to stderr where possible. Usually init scripts take care of
    redirecting stderr output to syslog anyway.
   =20
    For those that don't, add a --syslog option that forces all output to g=
o
    to syslog instead. Note that even with this option, errors encountered
    during option processing will still go to stderr.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5d37055061e92df07c4bf483ce06551d82ae9338
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sat Aug 1 06:26:40 2009 -0400

    nfs-utils: clean up option parsing in nfsd.c
   =20
    Minor formatting nits.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f8dd0b70ecf5a02eda29af4acead86f3359c3081
Author: Jeff Layton <jlayton@redhat.com>
Date:   Sat Aug 1 06:26:15 2009 -0400

    nfs-utils: move nfssvc.c to nfsd dir and clean up linking of nfsd
   =20
    rpc.nfsd is the only user of nfssvc.c, so we might as well move it
    out of libnfs.a.
   =20
    Also, don't link in libexport.a and libmisc.a, they aren't needed.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3339c1f73c05fc9b5cf51e14a2033ec38f671334
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jul 15 07:58:22 2009 -0400

    errno not be set on RPC errors
   =20
    Changed both nfs_advise_umount() and nfs_gp_ping() to
    set the errno by calling CLNT_GETERR() after a CLNT_CALL()
    error. Also added code to rpc_strerror() that will log
    the errno value, when set, via strerror().
   =20
    These changes added essential information to the error message
    making it much easier to detect errorsuch as "Connection refused"
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit b46dc42505da799a05a3a5e8f004b308f6b9eef7
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Jul 15 06:21:54 2009 -0400

    Don't use initialized garbage for address lengths
   =20
    Make sure address lengths are initialized before
    call calling nfs_extract_server_addresses() from
    nfs_rewrite_pmap_mount_options(). Otherwise the
    length check in nfs_string_to_sockaddr() can fail
    since its will be using garbage from the stack.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 906f0b27730b0506a24ed43029983b4d6819dd12
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 17:00:47 2009 -0400

    mount.nfs: Squelch compiler warnings in nfs_strerror()
   =20
    Address compiler warnings:
   =20
        error.c: In function nfs_strerror:
        error.c:341: warning: comparison between signed and unsigned
        error.c:342: warning: comparison between signed and unsigned
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d976ec69f0df3f19a3be9351f07086de54af42b9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:59:31 2009 -0400

    mount.nfs: Squelch unused parameter warnings on empty functions
   =20
    Address compiler warnings:
   =20
        fstab.c:288: warning: unused parameter sig
   =20
        parse_dev.c:186: warning: unused parameter dev
        parse_dev.c:187: warning: unused parameter hostname
        parse_dev.c:187: warning: unused parameter pathname
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ae548c2d55e442c96ad51e90c1e00ce3eb0b718b
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:58:38 2009 -0400

    mount.nfs: Fix compiler warning in stropts.c
   =20
    Address compiler warning:
   =20
        stropts.c: In function =BFnfs_append_generic_address_option=BF:
        stropts.c:138: warning: comparison between signed and unsigned
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 6e3fa0e103a494a37cf3a4f9199516923928ab31
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:57:07 2009 -0400

    umount.nfs: Use correct data type in nfsumount()
   =20
    Address compiler warning:
   =20
        nfsumount.c: In function nfsumount:
        nfsumount.c:347: warning: comparison between signed and unsigned
   =20
    The result type of pointer arithmetic and the return type of strlen(3)
    are both size_t.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c27bf85f0bd41015352468f35dfbf0d431d1e4c5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:56:01 2009 -0400

    mount.nfs: remove unused @addrlen argument from	nfs_string_to_sockaddr(=
)
   =20
    Address compiler warning:
   =20
        network.c: In function nfs_string_to_sockaddr:
        network.c:272: warning: unused parameter addrlen
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c51c20dfa8a81a5d512defcbbf1b7adec3adc591
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:53:29 2009 -0400

    mount.nfs: Remove unused @salen parameter from	nfs_ca_gai()
   =20
    Address compiler warning:
   =20
        network.c:1124: warning: unused parameter salen
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1767d5f5c9c26aa33b602a33ece83c2bfe55259f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:51:27 2009 -0400

    mount.nfs: Fix some nfs_error() nits in network.c
   =20
    Fix a couple of nfs_error() call sites in utils/mount/network.c.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d47f9baba71e92730e94d3361fa1098dc31b7627
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:50:00 2009 -0400

    mount.nfs: Remove unused parameter in try_mount()
   =20
    Address compiler warning:
   =20
        mount.c: At top level:
        mount.c:420: warning: unused parameter nomtab
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 4fc8cacd748d59dd3f463148994700bdd7610908
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:48:50 2009 -0400

    mount.nfs: Use correct data type in	discover_nfs_mount_data_version()
   =20
    Address compiler warning:
   =20
        mount.c: In function discover_nfs_mount_data_version=BF:
        mount.c:162: warning: comparison between signed and unsigned
        mount.c:164: warning: comparison between signed and unsigned
        mount.c:166: warning: comparison between signed and unsigned
        mount.c:168: warning: comparison between signed and unsigned
        mount.c:170: warning: comparison between signed and unsigned
        mount.c:178: warning: comparison between signed and unsigned
   =20
    linux_version_code() and MAKE_VERSION() both return an unsigned int.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5600327322a78a3a803368c0fe4f923cf14a4cf7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:47:09 2009 -0400

    support: Introduce sockaddr helpers to get and set IP port numbers
   =20
    Introduce address family-agnostic functions that get and set IP port
    numbers in socket addresses.  We can already replace a few similar
    functions in the mount command, and a few more will come up with
    statd and sm-notify.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 23c1a452afce5726cfe661a4d7ac14a1883ecb55
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:45:07 2009 -0400

    mount.nfs: Don't update extra_opts after text-based	negotiation
   =20
    The umount.nfs command will negotiate the mount options again, so all
    that is needed in /etc/mnttab is the original set of options used for
    the mount, plus the additional mandatory options like addr=3D''.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 134ea8cb64885fb587d038f80a1924f4c26470b9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:39:17 2009 -0400

    mount.nfs: Clean up after restructuring	version/protocol negotiation
   =20
    Fix up comments and function names to reflect the new version/protocol
    negotiation scheme.  We can now remove a bunch of mount processing
    that is specific to v2/v3, removing about 100 lines of logic from
    stropts.c.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 987ee0e340a413c3bf3187084df9834eefb37bb9
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:37:02 2009 -0400

    mount.nfs: Clean up nfs_is_permanent_error()
   =20
    Clean up: Move nfs_is_permanent_error() closer to the functions that
    call it, and update a documenting comment to reflect recent
    restructuring in this area.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit ca4e817b083553b6244e81ac91d9db86c09948b1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:35:26 2009 -0400

    mount.nfs: rearchitect mount version/protocol	negotiation logic
   =20
    Text-based mounts try a mount operation first with default settings,
    then negotiate via rpcbind queries and retry the mount, if the default
    settings don't work.  This method introduces long delays in certain
    common scenarios, and makes it difficult to tell when it is
    appropriate to fail immediately or negotiate and retry.
   =20
    To address these behavioral regressions, make text-based mounts
    operate the same way that legacy mounts work.  Perform rpcbind queries
    with short timeouts first, then use the results to determine
    transport, version, and port number settings for the mount.
   =20
    This allows the mount.nfs command to detect server settings, or
    whether negotiation is even possible, quickly.  It also makes it
    simple to determine when to fail vs. when to retry.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 19ba81f64447dca205362a119f1e72701438aecc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:34:20 2009 -0400

    mount.nfs: make nfs_options2pmap return errors
   =20
    Up until now, nfs_options2pmap() has been passed mount options that
    have already gone through the kernel's parser successfully.  So, it
    never had to check for invalid mount option values.
   =20
    However, we are about to pass it options that come right from the
    user.  So nfs_options2pmap() will now need to report an error and
    fail if it encounters a bogus value for any of the options it cares
    about.
   =20
     =3D=3D=3D=3D=3D
   =20
    Note that nfs_options2pmap() will allow a bogus value for an option
    if the same option is specified farther to the right with a useable
    value.
   =20
    For example, if a user specifies "proto=3Dfoo,...,tcp" then
    nfs_options2pmap() uses "tcp" and ignores "proto=3Dfoo".
   =20
    However, if the options are specified in the other order:
    "tcp,...,proto=3Dfoo" then nfs_options2pmap() will fail.  This is a sim=
ple
    and unambiguous extension of the "rightmost wins" rule.
   =20
    Since mount.nfs strips out these options out and replaces them with
    the rpcbind-negotiated options before invoking mount(2), the kernel
    should never receive bogus values for these options from mount.nfs in
    such cases.
   =20
    This is probably slightly more flexible behavior than the legacy
    mount implementation, but should be harmless.  All mount options
    unrelated to pmap are ignored by nfs_options2pmap().
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 3fc80f43ffb272036188d070a01090bbf243b7b5
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:31:15 2009 -0400

    mount.nfs: force rpcbind queries if options aren't	specified
   =20
    nfs_options2pmap() fills in default values if the passed-in mount
    options don't specify values.  This short-circuits the version, port,
    and transport negotiation logic in nfs_probe_bothports().
   =20
    Instead, nfs_options2pmap() should plant zeros in these pmap fields
    to force nfs_probe_bothports() and nfs_advise_mount() to discover, via
    rpcbind queries, what the server supports.
   =20
    This fixes some scenarios where umount.nfs fails to connect to servers
    that don't have all rpcbind ports open, in addition to fixing other
    corner cases during mount.nfs version/protocol negotiation.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 5f7313a10b63da796d5cd79c01db1e097d4a6bf1
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:29:11 2009 -0400

    mount.nfs: If port=3D specifies an unregistered port,	retry, then fail
   =20
    Suppose a port=3D option is specified on the mount command line, but no=
t
    enough other mount options are specified to avoid an rpcbind query to
    discover the NFS service.
   =20
    If the NFS service isn't registered on [100003, 3, "tcp", port] (even
    if the server is listening on the specified port), the legacy mount.nfs
    command fails immediately with:
   =20
     mount.nfs: mount to NFS server 'server' failed: RPC Error: Success
   =20
    What's more, this mount request should succeeded if an NFS service is
    registered on the specified port for another version and/or protocol.
   =20
    So instead, let's retry the rpcbind query with the other versions and
    transport protocols to be absolutely sure that port won't work with
    either version or transport.  Then, if all fails, report:
   =20
     mount.nfs: mount to NFS server 'server' failed:
    				RPC Error: Program not registered
   =20
    This change also affects text-based mounts that require negotiation
    by the mount.nfs command.
   =20
    Note that if the mount options specify all four pmap parameters for
    NFS, the rpcbind query for the NFS service is skipped entirely.  The
    mount command then hangs and times out later if NFS service is not
    listening on the requested tuple.  This is unchanged from previous
    behavior.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 682a9855b93a7d3545a26eea39a0895b9757cdcb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:27:54 2009 -0400

    getport: Convert TCP connection refused to RPC_CANTRECV
   =20
    In a similar vein to the timeout logic we just restored, a refused
    TCP connection should be mapped to an equivalent UDP error code:
    RPC_CANTRECV.
   =20
    This is new behavior for TCP connections; the legacy mount command
    appears to have simply failed immediately if a TCP connection was
    refused during an rpcbind query.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit aa633adcbe63b7539d23d7e0fb1342659cf22953
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:26:42 2009 -0400

    getport: Restore historical TCP connect timeout error code
   =20
    The latest versions of mount.nfs appear not to fall back to
    UDP if TCP isn't available on the server.
   =20
    Our new nfs_getport() implementation is missing a bit of logic
    from the original mount getport() implementation.  Without it,
    nfs_probe_port() sees a TCP connect timeout as a permanent error,
    so it fails immediately instead of attempting to try again with
    UDP.
   =20
    Similar changes for our new ping API (see the old clnt_ping()
    function, which is still in utils/mount/network.c).
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit dd0761b4852d9946efa86c7403e45b937462503f
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:25:43 2009 -0400

    mount.nfs: Add more debugging output around	nfs_getport()
   =20
    So we can see how rpcbind queries are failing during mount processing,
    add some debugging messages (enabled with "mount.nfs -v") around the
    nfs_getport() calls.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit c7fa61e76f072d97a9bdb4a551aa2ba28e5818cc
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:24:11 2009 -0400

    getport: Clear shared error fields before trying rpcbind queries
   =20
    Some RPC errors set fields in rpc_createerr.cf_error in addition
    to cf_stat.  Be sure to clear _all_ error fields in rpc_createerr
    each time through the rpcbind API.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit e188c214f487c9783ab3ae3e987d9a98b9298dfb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:21:01 2009 -0400

    getport: RPC_PROGNOTREGISTERED is a permanent error
   =20
    rpcbind returns RPC_PROGNOTREGISTERED if it knows for certain that an
    RPC program is not supported for a given transport.  This is a
    permanent and authoritative error, so the library's rpcbind query API
    should never retry the query -- it will only get the same answer.
   =20
    A similar change was submitted for libtirpc.  Unlike rpcb_getaddr(3t),
    mount.nfs's rpcbind client only retries once (with RPCB3PROC_GETADDR),
    but an extra TCP socket in this case would leave another port in
    TIME_WAIT.  It's infrequent enough, but might as well get rid of it.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d0280c201a47cce4aadcfa610b8e03865cce5c5e
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:18:37 2009 -0400

    support: Set proper retransmit timeout for datagram	transports
   =20
    Instead of setting the total timeout and the retransmit timeout to the
    same value for datagram transports, use a 1 second retransmit timeout,
    so we actually get a retransmit or two before failing.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 56a1b590d2f60e62feb3589a7b5b6fab2fed75f7
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:17:28 2009 -0400

    support: Don't return RPC_UNKNOWNHOST from rpc_socket.c
   =20
    RPC_UNKNOWNHOST means a hostname isn't known -- basically it's
    EAI_NONAME from getaddrinfo(3).  Since the functions in rpc_socket.c
    don't take a hostname argument, RPC_UNKNOWNHOST is not an appropriate
    return code from these functions.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 965b4cf6398bed2a2c722b9d632b9674c228e36c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:16:46 2009 -0400

    support: Use HAVE_LIBTIRPC to switch in	bindresvport_sa(3t)
   =20
    commit 383a026d99624c88c0e802103ef4c4865db8eb71, which fixed an
    earlier commit, is still not quite correct.
   =20
    bindresvport_sa(3t) is available whenever libtirpc is linked.
    There's no need to use IPV6_SUPPORTED here.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1f9c144db7be4c7e5eb07325a752c3306e13bfeb
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:14:19 2009 -0400

    New versions of libtool add extra aclocal scripts
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit fb5b52806c58b1b295d1a9aa1fc178a69765321d
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:13:39 2009 -0400

    getport: Remove unneeded @salen arguments
   =20
    Clean up: Now that getnameinfo(3) is no longer used, the @salen
    argument to nfs_sockaddr2universal() is no longer needed.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit df5e6316f040f49065d2821c05d4673994d48d4c
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:12:23 2009 -0400

    getport: replace getnameinfo(NI_NUMERICHOST) with	inet_ntop(3)
   =20
    getnameinfo(3) with the NI_NUMERICHOST flag is used in
    support/nfs/getport.c to convert socket addresses to universal address
    strings.
   =20
    Older versions of glibc do not have getnameinfo(3), however.  In order
    for nfs-utils to build on older systems we switch in legacy code via
    HAVE_GETNAMEINFO and use inet_ntoa(3).
   =20
    A problem with this is that we have to double our test matrix to be
    sure that both versions of these routines build and operate correctly.
    Another minor problem is that inet_ntoa(3) is officially deprecated.
   =20
    So let's always use a single implementation based on inet_ntop(3).
    Universal address strings do not support link-local / scope IDs, so we
    don't lose any functionality by using inet_ntop(3) here.
   =20
    This means we open code a bit of logic that is available in most
    modern versions of glibc, but in return we can use exactly the same
    code for all builds (on systems with getnameinfo(3) and without).
   =20
    An additional benefit is we can avoid using NI_MAXHOST for character
    buffers that live on the stack: it's 1025 bytes.  Instead,
    INET6_ADDRSTRLEN is used, which is just 46 bytes, plus an additional
    eight bytes for the port information.  We add beefier buffer overflow
    detection logic as well.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 2fcfd397bc555a6c31082c09e6fee7750e41fdb0
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:11:08 2009 -0400

    getport: Remove AI_ADDRCONFIG from	nfs_gp_loopback_address()
   =20
    AI_ADDRCONFIG was used ostensibly to figure out if the local system
    had IPv6 available when generating a loopback address.
   =20
    A legacy version of nfs_gp_loopback_address() was created to handle
    ANYADDR address generation for old versions of glibc where
    AI_ADDRCONFIG doesn't exist.  This means we have to be careful to
    test both the normal and legacy versions when committing changes in
    this area.
   =20
    But it turns out that even contemporary versions of glibc ignore
    AI_ADDRCONFIG when the hostname string is NULL.  getaddrinfo(3)
    always returns an AF_INET and an AF_INET6 loopback address in this
    case, no matter how the system is configured.
   =20
    Change nfs_gp_loopback_address() to have one version that simply looks
    up "localhost" instead of doing anything fancy.  If "localhost" is an
    IPv6 address, we'll use that.  Otherwise, it should nearly always be
    an AF_INET loopback address.
   =20
    This eliminates the need for AI_ADDRCONFIG, and removes the duplicate
    version of nfs_gp_loopback_address().  Note that callers never used
    the port number in the returned socket address, so get rid of the
    "sunrpc" service string too.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 93b7d1f16db674827fc85e70bff1745f57fb6a60
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:09:03 2009 -0400

    getport: RPCB_GETADDR's r_addr should contain rpcbind port, not zero
   =20
    Similar to a change made to the kernel's rpcbind client.  See
    kernel commit 143b6c4008a7928de7e139c3a77a90e4cad8db2c.
   =20
    The r_addr argument of RPCB_GETADDR procedures contains the
    rpcbind server's address and port number.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8f859912e786859d21c341bb8a9b4effbdadb941
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Jul 14 16:07:35 2009 -0400

    getport: RPCB_GETADDR r_owner should be an empty string
   =20
    Some servers reject RPCB_GETADDR requests with a non-empty r_owner
    field.  "RPC: Server can't decode arguments"
   =20
    An empty string is already used by libtirpc and the kernel
    for RPCB_GETADDR requests.
   =20
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 1aa4121ba599de836702d7b2d38cad63e6a09044
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jun 29 10:44:20 2009 -0400

    mydaemon: remove closeall() calls from mydaemon()
   =20
    idmapd and svcgssd have a mydaemon() routine that uses closeall() to
    close file descriptors. Unfortunately, they aren't using it correctly
    and it ends up closing the pipe that the child process uses to talk to
    its parent.
   =20
    Fix this by not using closeall() in this routine and instead, just clos=
e
    the file descriptors that we know need to be closed. If /dev/null can't
    be opened for some reason, then just have the child exit with a non-zer=
o
    error.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 097128d72d1ab4be299bf5fdc0b8e83667fc159b
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jun 22 10:05:44 2009 -0400

    The closeall function is broken in such a way that it almost never
    closes any file descriptors. It's calling strtol on the text
    representation of the file descriptor, and then checking to see if the
    value of *endptr is not '\0' before trying to close the file. This chec=
k
    is wrong.
   =20
    When strtol returns an endptr that points to a NULL byte, that indicate=
s
    that the conversion was completely successful. I believe this check
    should instead be requiring that endptr is pointing to '\0' before
    closing the fd.
   =20
    Also, fix up the function to check for conversion errors from strtol. I=
f
    one occurs, just skip the close on that entry.
   =20
    Finally, as Trond pointed out, it's unlikely that readdir will return a
    blank string in d_name but that situation wouldn't be detected by the
    current code. This patch adds such a check and skips the close if it
    occurs.
   =20
    Reported-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 148503a575534a4050d709045a6c0dcddd565445
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jun 22 09:49:17 2009 -0400

    Make --enable-tirpc the default. If --enable-tirpc wasn't explicitly
    specified, but TIRPC libs or headers aren't present then just throw a
    warning and disable it. If it was explicitly specified, then throw an
    error and exit if they aren't present.
   =20
    Signed-off-by: Jeff Layton <jlayton@redhat.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit f91afa8eaee1d7ba390918d00d4f7d3f338d18d3
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Jun 22 09:17:27 2009 -0400

    Set the verbosity level in both the librpcsecgss and
    libnfsidmapd libraries when verbosity level is set
    by the '-v' flag it on either daemon.
   =20
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit abf92485ae52bd637d544e2ac73147271b310a14
Author: NeilBrown <neilb@suse.de>
Date:   Wed Jun 3 15:48:08 2009 -0400

    Retry export if getfh fails.
   =20
    mountd tries to avoid telling the kernel to export something
    when the kernel already knows to do that.
    However sometimes (exportfs -r) the kernel can be told
    to forget something without mountd realising.
    So if mountd finds that it cannot get a  valid filehandle,
    make sure it really has been exported to the kernel.
   =20
    This only applies if the nfsd filesystem is not mounted.
   =20
    Signed-off-by: NeilBrown <neilb@suse.de>
    Signed-off-by: Steve Dickson <steved@redhat.com>

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
