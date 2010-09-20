Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59639 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab0ITQd2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:33:28 -0400
Received: by mail-gy0-f174.google.com with SMTP id 8so1351673gyd.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:33:27 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] mountd: Update mountd/exportfs man pages to reflect IPv6
	changes
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:33:24 -0400
Message-ID: <20100920163323.3170.5462.stgit@ellison.1015granger.net>
In-Reply-To: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Document IPv6 support in rpc.mountd and exportfs, and clarify existing
language in the man page.

Clean up: Use bold consistently for program names, and italics
consistently for file names.  Use "rpc.mountd" consistently as the
name of the mountd daemon.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/exportfs/exportfs.man |  287 ++++++++++++++++++++++---------------------
 utils/exportfs/exports.man  |   88 ++++++++-----
 utils/mountd/mountd.man     |  240 +++++++++++++++++++++++-------------
 3 files changed, 354 insertions(+), 261 deletions(-)

diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index c7b230a..089f75b 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -1,11 +1,11 @@
+.\"@(#)exportfs.8"
 .\"
-.\" exportfs(8)
-.\" 
 .\" Copyright (C) 1995 Olaf Kirch <okir@monad.swb.de>
 .\" Modifications 1999-2003 Neil Brown <neilb@cse.unsw.edu.au>
-.TH exportfs 8 "18 July 2003"
+.\"
+.TH exportfs 8 "31 December 2009"
 .SH NAME
-exportfs \- maintain list of NFS exported file systems
+exportfs \- maintain table of exported NFS file systems
 .SH SYNOPSIS
 .BI "/usr/sbin/exportfs [-avi] [-o " "options,.." "] [" "client:/path" " ..]
 .br
@@ -18,229 +18,236 @@ exportfs \- maintain list of NFS exported file systems
 .BI "/usr/sbin/exportfs -f"
 .br
 .SH DESCRIPTION
+An NFS server maintains a table of local physical file systems
+that are accessible to NFS clients.
+Each file system in this table is  referred to as an
+.IR "exported file system" ,
+or
+.IR export ,
+for short.
+.PP
 The
 .B exportfs
-command is used to maintain the current table of exported file systems for
-NFS. This list is kept in a separate file named
-.BR /var/lib/nfs/etab
-which is read by
-.B mountd
-when a remote host requests access to mount a file tree, and parts of
-the list which are active are kept in the kernel's export table.
-.P
-Normally this 
-.B etab
-file is initialized with the list of all file systems named in
-.B /etc/exports 
+command maintains the current table of exports for the NFS server.
+The master export table is kept in a file named
+.IR /var/lib/nfs/etab .
+This file is read by
+.B rpc.mountd
+when a client sends an NFS MOUNT request.
+.PP
+Normally the master export table is initialized with the contents of
+.I /etc/exports
 by invoking
 .BR "exportfs -a" .
-.P
-However, administrators can choose to add and delete individual file systems
-without modifying
-.B /etc/exports
-using
-.BR exportfs .
-.P
+However, a system administrator can choose to add or delete
+exports without modifying
+.I /etc/exports
+by using the
+.B exportfs
+command.
+.PP
 .B exportfs
-and it's partner program
-.B mountd
-work in one of two modes, a legacy mode which applies to 2.4 and
+and its partner program
+.B rpc.mountd
+work in one of two modes: a legacy mode which applies to 2.4 and
 earlier versions of the Linux kernel, and a new mode which applies to
-2.6 and later versions providing the
+2.6 and later versions, providing the
 .B nfsd
 virtual filesystem has been mounted at
-.B /proc/fs/nfsd
+.I /proc/fs/nfsd
 or
-.BR /proc/fs/nfs .
-If this filesystem is not mounted in 2.6, the legacy mode is used.
-.P
+.IR /proc/fs/nfs .
+On 2.6 kernels, if this filesystem is not mounted, the legacy mode is used.
+.PP
 In the new mode,
 .B exportfs
-does not give any information to the kernel but only provides it to
-.B mountd
+does not give any information to the kernel, but provides it only to
+.B rpc.mountd
 through the
-.B /var/lib/nfs/etab
+.I /var/lib/nfs/etab
 file.
-.B mountd
-will listen to requests from the kernel and will provide information
-as needed.
-.P
+.B rpc.mountd
+then manages kernel requests for information about exports, as needed.
+.PP
 In the legacy mode,
-any export requests which identify a specific host (rather than a
-subnet or netgroup etc) are entered directly into the kernel's export
-table as well as being written to
-.BR /var/lib/nfs/etab .
-Further, any mount points listed in
-.B /var/lib/nfs/rmtab
+exports which identify a specific host, rather than a subnet or netgroup,
+are entered directly into the kernel's export table,
+as well as being written to
+.IR /var/lib/nfs/etab .
+Further, exports listed in
+.I /var/lib/nfs/rmtab
 which match a non host-specific export request will cause an
 appropriate export entry for the host given in
-.B rmtab
-to be entered
-into the kernel's export table.
+.I rmtab
+to be added to the kernel's export table.
 .SH OPTIONS
-.TP 
+.TP
 .B -a
 Export or unexport all directories.
 .TP
 .BI "-o " options,...
 Specify a list of export options in the same manner as in
-.BR exports(5) .
+.BR exports (5).
 .TP
 .B -i
 Ignore the
-.B /etc/exports
-file, so that only default options and options given on the command
-line are used.
+.I /etc/exports
+file.  Only default options and options given on the command line are used.
 .TP
 .B -r
-Reexport all directories. It synchronizes /var/lib/nfs/etab
-with /etc/exports. It removes entries in /var/lib/nfs/etab
-which are deleted from /etc/exports, and remove any entries from the
+Reexport all directories, synchronizing
+.I /var/lib/nfs/etab
+with
+.IR /etc/exports .
+This option removes entries in
+.I /var/lib/nfs/etab
+which have been deleted from
+.I /etc/exports, and removes any entries from the
 kernel export table which are no longer valid.
 .TP
 .B -u
 Unexport one or more directories.
 .TP
 .B -f
-In 'new' mode, flush everything out of the kernels export table. Any
-clients that are active will get new entries added by
-.B mountd
-when they make their next request.
+If
+.I /proc/fs/nfsd
+or
+.I /proc/fs/nfs
+is mounted, flush everything out of the kernel's export table.
+Fresh entries for active clients are added to the kernel's export table by
+.B rpc.mountd
+when they make their next NFS mount request.
 .TP
 .B -v
 Be verbose. When exporting or unexporting, show what's going on. When
 displaying the current export list, also display the list of export
 options.
 .SH DISCUSSION
-.\" -------------------- Exporting Directories --------------------
 .SS Exporting Directories
-The first synopsis shows how to invoke the command when adding new
-entries to the export table.  When using 
+The first synopsis shows how to invoke
+.B exportfs
+when adding new entries to the export table.  When using
 .BR "exportfs -a" ,
-all directories in
-.B exports(5)
+all exports listed in
+.I /etc/exports
 are added to
-.B etab
-and the resulting list is pushed into the kernel.
-.P
+.IR /var/lib/nfs/etab .
+The kernel's export table is also updated as needed.
+.PP
 The
 .I host:/path
-argument specifies the directory to export along with the host or hosts to
-export it to. All formats described in
+argument specifies a local directory to export,
+along with the client or clients who are permitted to access it.
+See
 .B exports(5)
-are supported; to export a directory to the world, simply specify
+for a description of supported options and access list formats.
+To export a directory to the world, simply specify
 .IR :/path .
-.P
+.PP
 The export options for a particular host/directory pair derive from
-several sources.  There is a set of default options which can be overridden by
-entries in
-.B /etc/exports
-(unless the
-.B -i
-option is given).
-In addition, the administrator may override any options from these sources
-using the
+several sources.
+The default export options are
+.BR sync,ro,root_squash,wdelay .
+These can be overridden by entries in
+.IR /etc/exports .
+.PP
+A system administrator may override options from these sources using the
 .B -o
-argument which takes a comma-separated list of options in the same fashion
+command-line option on
+.BR exportfs .
+This option takes a comma-separated list of options in the same fashion
 as one would specify them in
-.BR exports(5) .
-Thus,
+.IR /etc/exports .
+In this way
 .B exportfs
-can also be used to modify the export options of an already exported
-directory.
-.P
-Modifications of the kernel export table used by
-.B nfsd(8)
-take place immediately after parsing the command line and updating the
-.B etab
-file.
-.P
-The default export options are
-.BR sync,ro,root_squash,wdelay .
-.\" -------------------- Unexporting Directories ------------------
+can be used to modify the export options of an already exported directory.
 .SS Unexporting Directories
 The third synopsis shows how to unexported a currently exported directory.
 When using
 .BR "exportfs -ua" ,
 all entries listed in
-.B etab
+.I /var/lib/nfs/etab
 are removed from the kernel export tables, and the file is cleared. This
 effectively shuts down all NFS activity.
-.P
-To remove an export to a host, specify a
+.PP
+To remove an export, specify a
 .I host:/path
 pair. This deletes the specified entry from
-.B etab
+.I /var/lib/nfs/etab
 and removes the corresponding kernel entry (if any).
-To remove one or more exports to several hosts, use
-.BR "exportfs -ua" .
-.P
-.\" -------------------- Dumping the Export Table -----------------
-.SS Dumping the Export Table 
+.PP
+.SS Dumping the Export Table
 Invoking
 .B exportfs
-without further options shows the current list of exported file systems.
-When giving the
+without options shows the current list of exported file systems.
+Adding the
 .B -v
-option, the list of flags pertaining to each export are shown in addition.
-.\" -------------------- EXAMPLES ---------------------------------
+option causes
+.B exportfs
+to display the export options for each export.
 .SH EXAMPLES
 The following adds all directories listed in
-.B /etc/exports
+.I /etc/exports
 to
-.B /var/lib/nfs/etab
+.I /var/lib/nfs/etab
 and pushes the resulting export entries into the kernel:
-.P
+.PP
 .nf
 .B "# exportfs -a
 .fi
-.P
+.PP
 To export the
-.B /usr/tmp
-directory to host 
+.I /usr/tmp
+directory to host
 .BR django ,
-allowing asynchronous writes, one would do this:
-.P
+allowing insecure file locking requests from clients:
+.PP
 .nf
-.B "# exportfs -o async django:/usr/tmp
+.B "# exportfs -o insecure_locks django:/usr/tmp
 .fi
-.P
+.PP
 To unexport the
-.B /usr/tmp
+.I /usr/tmp
 directory:
-.P
+.PP
 .nf
 .B "# exportfs -u django:/usr/tmp
 .fi
-.P
-To unexport all the directories listed in
-.B /etc/exports:
-.P
+.PP
+To unexport all exports listed in
+.IR /etc/exports :
+.PP
 .nf
 .B "# exportfs -au
 .fi
-.\" -------------------- DEPENDENCIES -----------------------------
-.SH DEPENDENCIES
-Exporting to IP networks, DNS and NIS domains does not enable clients
-from these groups to access NFS immediately; rather, these sorts of
-exports are hints to
-.B mountd(8)
+.SH USAGE NOTES
+Exporting to IP networks or DNS and NIS domains does not enable clients
+from these groups to access NFS immediately.
+Rather, these sorts of exports are hints to
+.BR rpc.mountd (8)
 to grant any mount requests from these clients.
-This is usually not a big problem, because any existing mounts are preserved
-in
-.B rmtab
+This is usually not a problem, because any existing mounts are preserved in
+.I rmtab
 across reboots.
-.P
+.PP
 When unexporting a network or domain entry, any current exports to members
 of this group will be checked against the remaining valid exports and
 if they themselves are no longer valid they will be removed.
-.P
-.\" -------------------- SEE ALSO --------------------------------
+.SH FILES
+.TP 2.5i
+.I /etc/exports
+input file listing exports, export options, and access control lists
+.TP 2.5i
+.I /var/lib/nfs/etab
+master table of exports
+.TP 2.5i
+.I /var/lib/nfs/rmtab
+table of clients accessing server's exports
 .SH SEE ALSO
-.BR exports(5) ", " mountd(8)
-.\" -------------------- AUTHOR ----------------------------------
+.BR exports (5),
+.BR rpc.mountd (8),
+.BR netgroup (5)
 .SH AUTHORS
-Olaf Kirch, <okir@monad.swb.de>
+Olaf Kirch <okir@monad.swb.de>
 .br
-Neil Brown, <neilb@cse.unsw.edu.au>
-
+Neil Brown <neilb@cse.unsw.edu.au>
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index ea28ca8..c726dd9 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -1,18 +1,22 @@
-.TH EXPORTS 5 "4 March 2005" "Linux" "Linux File Formats Manual"
+.\"@(#)exports.5"
+.\"
+.TH exports 5 "31 December 2009"
 .SH NAME
-exports \- NFS file systems being exported (for Kernel based NFS)
-.SH SYNOPSIS
-.B /etc/exports
+exports \- NFS server export table
 .SH DESCRIPTION
 The file
 .I /etc/exports
-serves as the access control list for file systems which may be
-exported to NFS clients.  It is used by
-.IR exportfs (8)
+contains a table of local physical file systems on an NFS server
+that are accessible to NFS clients.
+The contents of the file are maintained by the server's system
+administrator.
+.PP
+Each file system in this table has a list of options and an
+access control list.
+The table is used by
+.BR exportfs (8)
 to give information to
-.IR mountd (8)
-and to the kernel based NFS file server daemon
-.IR nfsd (8).
+.BR mountd (8).
 .PP
 The file format is similar to the SunOS
 .I exports
@@ -34,7 +38,9 @@ double quotes. You can also specify spaces or other unusual character in
 the export name using a backslash followed by the character code as three
 octal digits.
 .PP
-To apply changes to this file, run exportfs \-ra or restart the NFS server.
+To apply changes to this file, run
+.BR exportfs \-ra
+or restart the NFS server.
 .PP
 .SS Machine Name Formats
 NFS clients may be specified in a number of ways:
@@ -61,9 +67,10 @@ simultaneously. This is done by specifying an IP address and netmask pair
 as
 .IR address/netmask
 where the netmask can be specified in dotted-decimal format, or as a
-contiguous mask length (for example, either `/255.255.252.0' or `/22' appended
-to the network base address result in identical subnetworks with 10 bits of
-host). Wildcard characters generally do not work on IP addresses, though they
+contiguous mask length.
+For example, either `/255.255.252.0' or `/22' appended
+to the network base IPv4 address results in identical subnetworks with 10 bits of
+host. Wildcard characters generally do not work on IP addresses, though they
 may work by accident when reverse DNS lookups fail.
 '''.TP
 '''.B =public
@@ -106,7 +113,7 @@ preceding sec= option.  The only options that are permitted to vary in
 this way are ro, rw, no_root_squash, root_squash, and all_squash.
 .PP
 .SS General Options
-.IR exportfs
+.BR exportfs
 understands the following export options:
 .TP
 .IR secure "\*d
@@ -144,7 +151,8 @@ default.  In all releases after 1.0.0,
 is the default, and
 .I async
 must be explicitly requested if needed.
-To help make system administrators aware of this change, 'exportfs'
+To help make system administrators aware of this change,
+.B exportfs
 will issue a warning if neither
 .I sync
 nor
@@ -188,7 +196,7 @@ The
 option is currently only effective on
 .I "single host
 exports.  It does not work reliably with netgroup, subnet, or wildcard
-exports. 
+exports.
 
 This option can be very useful in some situations, but it should be
 used with due care, and only after confirming that the client system
@@ -246,7 +254,7 @@ If you genuinely require subtree checking, you should explicitly put
 that option in the
 .B exports
 file.  If you put neither option,
-.I exportfs
+.B exportfs
 will warn you that the change is pending.
 
 .TP
@@ -272,7 +280,9 @@ or
 .TP
 .IR no_acl
 On some specially patched kernels, and when exporting filesystems that
-support ACLs, this option tells nfsd not to reveal ACLs to clients, so
+support ACLs, this option tells
+.B nfsd
+not to reveal ACLs to clients, so
 they will see only a subset of actual permissions on the given file
 system.  This option is safe for filesystems used by NFSv2 clients and
 old NFSv3 clients that perform access decisions locally.  Current
@@ -381,7 +391,7 @@ of the filesystem must be handled elsewhere.)
 
 .SS User ID Mapping
 .PP
-.I nfsd
+.B nfsd
 bases its access control to files on the server machine on the uid and
 gid provided in each NFS RPC request. The normal behavior a user would
 expect is that she can access her files on the server just as she would
@@ -399,19 +409,19 @@ and can be turned off with
 .IR no_root_squash .
 .PP
 By default,
-'''.I nfsd
+'''.B nfsd
 '''tries to obtain the anonymous uid and gid by looking up user
 '''.I nobody
 '''in the password file at startup time. If it isn't found, a uid and gid
-.I exportfs
+.B exportfs
 chooses a uid and gid
 of 65534 for squashed access. These values can also be overridden by
 the
 .IR anonuid " and " anongid
 options.
 '''.PP
-'''In addition to this, 
-'''.I nfsd
+'''In addition to this,
+'''.B nfsd
 '''lets you specify arbitrary uids and gids that should be mapped to user
 '''nobody as well.
 Finally, you can map all user requests to the
@@ -424,7 +434,7 @@ Here's the complete list of mapping options:
 Map requests from uid/gid 0 to the anonymous uid/gid. Note that this does
 not apply to any other uids or gids that might be equally sensitive, such as
 user
-.IR bin 
+.IR bin
 or group
 .IR staff .
 .TP
@@ -434,7 +444,7 @@ Turn off root squashing. This option is mainly useful for diskless clients.
 .IR all_squash
 Map all uids and gids to the anonymous user. Useful for NFS-exported
 public FTP directories, news spool directories, etc. The opposite option
-is 
+is
 .IR no_all_squash ,
 which is the default setting.
 .TP
@@ -468,7 +478,7 @@ and netgroups (this is the entry `@trusted'). The fourth line shows the
 entry for the PC/NFS client discussed above. Line 5 exports the
 public FTP directory to every host in the world, executing all requests
 under the nobody account. The
-.I insecure 
+.I insecure
 option in this entry also allows clients with NFS implementations that
 don't use a reserved port for NFS.
 The sixth line exports a directory read-write to the machine 'server'
@@ -478,15 +488,15 @@ all three mounts with the `sync' option enabled.
 '''access to the private directory.
 '''.SH CAVEATS
 '''Unlike other NFS server implementations, this
-'''.I nfsd
+'''.B nfsd
 '''allows you to export both a directory and a subdirectory thereof to
-'''the same host, for instance 
+'''the same host, for instance
 '''.IR /usr " and " /usr/X11R6 .
 '''In this case, the mount options of the most specific entry apply. For
-'''instance, when a user on the client host accesses a file in 
+'''instance, when a user on the client host accesses a file in
 '''.IR /usr/X11R6 ,
-'''the mount options given in the 
-'''.I /usr/X11R6 
+'''the mount options given in the
+'''.I /usr/X11R6
 '''entry apply. This is also true when the latter is a wildcard or netgroup
 '''entry.
 .SH FILES
@@ -499,7 +509,15 @@ all three mounts with the `sync' option enabled.
 .BR showmount (8).
 '''.SH DIAGNOSTICS
 '''An error parsing the file is reported using syslogd(8) as level NOTICE from
-'''a DAEMON whenever nfsd(8) or mountd(8) is started up.  Any unknown
+'''a DAEMON whenever
+'''.BR nfsd (8)
+'''or
+'''.BR mountd (8)
+'''is started up.  Any unknown
 '''host is reported at that time, but often not all hosts are not yet known
-'''to named(8) at boot time, thus as hosts are found they are reported
-'''with the same syslogd(8) parameters.
+'''to
+'''.BR named (8)
+'''at boot time, thus as hosts are found they are reported
+'''with the same
+'''.BR syslogd (8)
+'''parameters.
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index bfa06e0..4bb96e8 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -1,9 +1,9 @@
-.\"
-.\" mountd(8)
+.\"@(#)rpc.mountd.8"
 .\"
 .\" Copyright (C) 1999 Olaf Kirch <okir@monad.swb.de>
 .\" Modified by Paul Clements, 2004.
-.TH rpc.mountd 8 "31 Aug 2004"
+.\"
+.TH rpc.mountd 8 "31 Dec 2009"
 .SH NAME
 rpc.mountd \- NFS mount daemon
 .SH SYNOPSIS
@@ -11,48 +11,73 @@ rpc.mountd \- NFS mount daemon
 .SH DESCRIPTION
 The
 .B rpc.mountd
-program implements the NFS mount protocol. When receiving a MOUNT
-request from an NFS client, it checks the request against the list of
-currently exported file systems. If the client is permitted to mount
-the file system,
-.B rpc.mountd
-obtains a file handle for requested directory and returns it to
-the client.
-.SS Exporting NFS File Systems
-Making file systems available to NFS clients is called
-.IR exporting .
-.P
-Usually, a file system and the hosts it should be made available to
-are listed in the
-.B /etc/exports
-file, and invoking
-.B exportfs -a
-whenever the system is booted. The
+daemon implements the server side of the NFS MOUNT protocol,
+an NFS side protocol used by NFS version 2 [RFC1094] and NFS version 3 [RFC1813].
+.PP
+An NFS server maintains a table of local physical file systems
+that are accessible to NFS clients.
+Each file system in this table is referred to as an
+.IR "exported file system" ,
+or
+.IR export ,
+for short.
+.PP
+Each file system in the export table has an access control list.
+.B rpc.mountd
+uses these access control lists to determine
+whether an NFS client is permitted to access a given file system.
+For details on how to manage your NFS server's export table, see the
+.BR exports (5)
+and
 .BR exportfs (8)
-command makes export information available to both the kernel NFS
-server module and the
-.B rpc.mountd
-daemon.
-.P
-Alternatively, you can export individual directories temporarily 
-using
-.BR exportfs 's
-.IB host : /directory
-syntax.
+man pages.
+.SS Mounting exported NFS File Systems
+The NFS MOUNT protocol has several procedures.
+The most important of these are
+MNT (mount an export) and
+UMNT (unmount an export).
+.PP
+A MNT request has two arguments: an explicit argument that
+contains the pathname of the root directory of the export to be mounted,
+and an implicit argument that is the sender's IP address.
+.PP
+When receiving a MNT request from an NFS client,
+.B rpc.mountd
+checks both the pathname and the sender's IP address against its export table.
+If the sender is permitted to access the requested export,
+.B rpc.mountd
+returns an NFS file handle for the export's root directory to the client.
+The client can then use the root file handle and NFS LOOKUP requests
+to navigate the directory structure of the export.
 .SS The rmtab File
-For every mount request received from an NFS client,
-.B rpc.mountd
-adds an entry to the
-.B /var/lib/nfs/rmtab
-file. When receiving an unmount request, that entry is removed.
-.P
-However, this file is mostly ornamental. One, the client can continue
-to use the file handle even after calling
-.B rpc.mountd 's
-UMOUNT procedure. And two, if a client reboots without notifying
-.B rpc.mountd ,
-a stale entry will remain in
-.BR rmtab .
+The
+.B rpc.mountd
+daemon registers every successful MNT request by adding an entry to the
+.I /var/lib/nfs/rmtab
+file.
+When receivng a UMNT request from an NFS client,
+.B rpc.mountd
+simply removes the matching entry from
+.IR /var/lib/nfs/rmtab ,
+as long as the access control list for that export allows that sender
+to access the export.
+.PP
+Clients can discover the list of file systems an NFS server is
+currently exporting, or the list of other clients that have mounted
+its exports, by using the
+.BR showmount (8)
+command.
+.BR showmount (8)
+uses other procedures in the NFS MOUNT protocol to report information
+about the server's exported file systems.
+.PP
+Note, however, that there is little to guarantee that the contents of
+.I /var/lib/nfs/rmtab
+are accurate.
+A client may continue accessing an export even after invoking UMNT.
+If the client reboots without sending a UMNT request, stale entries
+remain for that client in
+.IR /var/lib/nfs/rmtab .
 .SH OPTIONS
 .TP
 .B \-d kind " or " \-\-debug kind
@@ -94,22 +119,25 @@ Don't advertise TCP for mount.
 Ignored (compatibility with unfsd??).
 .TP
 .B \-p " or " \-\-port num
-Force
+Specifies the port number used for RPC listener sockets.
+If this option is not specified,
 .B rpc.mountd
-to bind to the specified port num, instead of using the random port
-number assigned by the portmapper.
+chooses a random ephemeral port for each listener socket.
+.IP
+This option can be used to fix the port value of
+.BR rpc.mountd 's
+listeners when NFS MOUNT requests must traverse a firewall
+between clients and servers.
 .TP
 .B \-H " or " \-\-ha-callout prog
-Specify a high availability callout program, which will receive callouts
-for all client mount and unmount requests. This allows 
-.B rpc.mountd
-to be used in a High Availability NFS (HA-NFS) environment. This callout is not
-needed (and should not be used) with 2.6 and later kernels (instead,
-mount the nfsd filesystem on
-.B /proc/fs/nfsd
-).
-The program will be called with 4 arguments.
-The first will be
+Specify a high availability callout program.
+This program receives callouts for all MOUNT and UNMOUNT requests.
+This allows
+.B rpc.mountd
+to be used in a High Availability NFS (HA-NFS) environment.
+.IP
+The callout program is run with 4 arguments.
+The first is
 .B mount
 or
 .B unmount
@@ -118,19 +146,30 @@ The second will be the name of the client performing the mount.
 The third will be the path that the client is mounting.
 The last is the number of concurrent mounts that we believe the client
 has of that path.
+.IP
+This callout is not needed with 2.6 and later kernels.
+Instead, mount the nfsd filesystem on
+.IR /proc/fs/nfsd .
 .TP
 .BI "\-s," "" " \-\-state\-directory\-path "  directory
-specify a directory in which to place statd state information.
+Specify a directory in which to place statd state information.
 If this option is not specified the default of
-.BR /var/lib/nfs
+.I /var/lib/nfs
 is used.
 .TP
 .BI "\-r," "" " \-\-reverse\-lookup"
-mountd tracks IP addresses in the rmtab, and when a DUMP request is made (by
-someone running showmount -a, for instance), it returns IP addresses instead
-of hostnames by default. This option causes mountd to do a reverse
-lookup on each IP address and return that hostname instead. Enabling this can
-have a substantial negative effect on performance in some situations.
+.B rpc.mountd
+tracks IP addresses in the
+.I rmtab
+file.  When a DUMP request is made (by
+someone running
+.BR "showmount -a" ,
+for instance), it returns IP addresses instead
+of hostnames by default. This option causes
+.B rpc.mountd
+to perform a reverse lookup on each IP address and return that hostname instead.
+Enabling this can have a substantial negative effect on performance
+in some situations.
 .TP
 .BR "\-t N" " or " "\-\-num\-threads=N"
 This option specifies the number of worker threads that rpc.mountd
@@ -162,41 +201,70 @@ If you use the
 flag, then the list of group ids received from the client will be
 replaced by a list of group ids determined by an appropriate lookup on
 the server. Note that the 'primary' group id is not affected so a
-.I newgroup
+.B newgroup
 command on the client will still be effective.  This function requires
 a Linux Kernel with version at least 2.6.21.
-
 .SH TCP_WRAPPERS SUPPORT
-This
+You can protect your
 .B rpc.mountd
-version is protected by the
+listeners using the
+.B tcp_wrapper
+library or
+.BR iptables (8).
+.PP
+Note that the
 .B tcp_wrapper
-library. You have to give the clients access to
-.B rpc.mountd
-if they should be allowed to use it. To allow connects from clients of
-the .bar.com domain you could use the following line in /etc/hosts.allow:
-
-mountd: .bar.com
-
-You have to use the daemon name 
+library supports only IPv4 networking.
+.PP
+Add the hostnames of NFS peers that are allowed to access
+.B rpc.mountd
+to
+.IR /etc/hosts.allow .
+Use the daemon name
 .B mountd
-for the daemon name (even if the binary has a different name).
-.B Note:
-hostnames used in either access file will be ignored when
+even if the
+.B rpc.mountd
+binary has a different name.
+.PP
+Hostnames used in either access file will be ignored when
 they can not be resolved into IP addresses.
-
-For further information please have a look at the
+For further information see the
 .BR tcpd (8)
 and
 .BR hosts_access (5)
-manual pages.
+man pages.
+.SS IPv6 and TI-RPC support
+TI-RPC is a pre-requisite for supporting NFS on IPv6.
+If TI-RPC support is built into
+.BR rpc.mountd ,
+it attempts to start listeners on network transports marked 'visible' in
+.IR /etc/netconfig .
+As long as at least one network transport listener starts successfully,
+.B rpc.mountd
+will operate.
+.SH FILES
+.TP 2.5i
+.I /etc/exports
+input file for
+.BR exportfs ,
+listing exports, export options, and access control lists
+.TP 2.5i
+.I /var/lib/nfs/rmtab
+table of clients accessing server's exports
 .SH SEE ALSO
-.BR rpc.nfsd (8),
 .BR exportfs (8),
 .BR exports (5),
-.BR rpc.rquotad (8).
-.SH FILES
-.BR /etc/exports ,
-.BR /var/lib/nfs/xtab .
+.BR showmount (8),
+.BR rpc.nfsd (8),
+.BR rpc.rquotad (8),
+.BR nfs (5),
+.BR tcpd (8),
+.BR hosts_access (5),
+.BR iptables (8),
+.BR netconfig (5)
+.sp
+RFC 1094 - "NFS: Network File System Protocol Specification"
+.br
+RFC 1813 - "NFS Version 3 Protocol Specification"
 .SH AUTHOR
 Olaf Kirch, H. J. Lu, G. Allan Morris III, and a host of others.

