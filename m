From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] nfs-utils: introduce new statd implementation (4th part)
Date: Wed, 05 Aug 2009 10:46:15 -0400
Message-ID: <20090805144615.12866.43803.stgit@matisse.1015granger.net>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26264 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934303AbZHEOqm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 10:46:42 -0400
In-Reply-To: <20090805143550.12866.8377.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce new man pages for new statd and sm-notify.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/new-statd/sm-notify.man |  286 ++++++++++++++++++++++++++++++
 utils/new-statd/statd.man     |  388 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 674 insertions(+), 0 deletions(-)
 create mode 100644 utils/new-statd/sm-notify.man
 create mode 100644 utils/new-statd/statd.man

diff --git a/utils/new-statd/sm-notify.man b/utils/new-statd/sm-notify.man
new file mode 100644
index 0000000..b38acf8
--- /dev/null
+++ b/utils/new-statd/sm-notify.man
@@ -0,0 +1,286 @@
+.\"@(#)sm-notify.8"
+.\"
+.\" Copyright 2009 Oracle.  All rights reserved.
+.\"
+.TH SM-NOTIFY 8 "1 July 2009
+.SH NAME
+sm-notify \- send reboot notification to NFS peers
+.SH SYNOPSIS
+.BI "/usr/sbin/sm-notify [-dfh] [-m " minutes "] [-n " name "] [-o " port "] [-P " path "]
+.SH DESCRIPTION
+Locks held on files are not part of persistent file system state.
+Lock state is thus lost when a host reboots.
+.PP
+NFS file locking must also detect when lock state is lost because a remote
+host has rebooted.
+After an NFS client reboots, an NFS server must release all locks held by
+applications that were running on that client.
+After a server reboots, a client must remind the
+server of locks held by applications running on that client.
+.PP
+For NFS version 2 and version 3, a network protocol known as the
+.I Network Status Monitor
+protocol (or NSM for short)
+is used to notify NFS peers of reboots.
+On Linux, two separate user-space components constitute the NSM service:
+.TP
+.B sm-notify
+A helper program that notifies NFS peers after the local system reboots
+.TP
+.B rpc.statd
+A daemon that listens for reboot notifications from other hosts, and
+manages the list of hosts to be notified when the local system reboots
+.PP
+When a system reboots, system initialization starts
+.BR rpc.statd ,
+which then typically invokes
+.B sm-notify
+automatically.
+The local NFS lock manager indicates to
+.B rpc.statd
+which remote hosts to monitor.
+.SS NSM operation
+The first file locking interaction between an NFS client and server causes
+the NFS lock managers on both peers to contact their local NSM service to
+store information about their respective remote peers.
+.PP
+On Linux,
+the lock manager contacts
+.BR rpc.statd ,
+which records on persistent storage information about each monitored NFS peer.
+This information describes how to contact a remote peer
+in case the local system reboots, and how to notify the local
+lockd when a monitored peer indicates to
+.B rpc.statd
+it has rebooted.
+.PP
+An NFS client sends a hostname in each file lock request to NFS servers
+that can be used to call the client back.
+This hostname is known as the client's
+.IR caller_name .
+An NFS server can use this hostname to send asynchronous GRANT
+calls to a client, and
+it can also use this hostname when notifying clients of reboots.
+An NFS server may use this hostname,
+or it may simply scrape the client's network address
+from the underlying transport and use that instead,
+when calling a client back.
+.PP
+The hostname or network address of the client is handed to
+.B rpc.statd
+during the first locking interaction between an NFS client and server.
+This is known as the monitored peer's
+.IR mon_name .
+In addition, the local lockd tells
+.B rpc.statd
+what it thinks its own hostname is.
+This hostname is known as
+.IR my_name .
+.PP
+NFS clients do not actually know what an NFS server's
+.I mon_name
+might be, so they usually record the hostname and/or
+network address used to mount the server.
+.SS Reboot notification
+After a reboot,
+.B sm-notify
+reads the list of monitored peers from persistent storage and
+sends an SM_NOTIFY request
+to the NSM service on each listed remote peer,
+using each
+.I mon_name
+as the destination, and the
+.I my_name
+string to identify which host has rebooted.
+.PP
+After receiving an SM_NOTIFY request from a remote peer,
+.B rpc.statd
+contacts its local lock manager,
+which initiates appropriate lock recovery.
+.B rpc.statd
+does not forward all reboot notifications it receives to the local lockd,
+however.
+It matches incoming SM_NOTIFY requests by their
+.I mon_name
+or network address to one or more peers on its own monitor list.
+If
+.B rpc.statd
+does not find a peer on its monitor list that matches
+an incoming SM_NOTIFY request, the request is ignored.
+.PP
+In addition, each peer has its own
+.IR "state number" ,
+which is a 32-bit integer that is bumped after each reboot.
+This state number is communicated between two peers so that they
+can distinguish between actual reboots and replayed notifications.
+.PP
+The value of state number is managed on Linux by
+.BR rpc.statd " and " sm-notify .
+The NSM state number is sent by NFS clients in each NLM LOCK request.
+The client does not discover the server's state number until the
+server sends an SM_NOTIFY request.
+.PP
+After reboot notifications have been
+sent to each peer on the list of monitored hosts,
+.B rpc.statd
+clears the monitor list, since, as noted above,
+lock state does not persist across reboots.
+Part of NFS lock recovery is rediscovering
+which peers need to be monitored again.
+.SH OPTIONS
+.TP
+.BR -d , " --debug
+Keeps
+.B sm-notify
+in the foreground while sending reboot notifications,
+and causes it to generate extra messages
+so that notification progress may be observed directly.
+.TP
+.BR -h , " --help
+Displays version and usage information on
+.IR stderr .
+.TP
+.BR -f , " --force
+Disables detection of system reboots, forcing notification to occur.
+If this option is not specified,
+.B sm-notify
+bumps the NSM state number, clears
+.BR rpc.statd 's
+monitor list, and
+sends reboot notifications only once after each system reboot;
+subsequent invocations of
+.B sm-notify
+become no-ops until the system is rebooted.
+.TP
+.BI "\-m, " "" "\-\-max-retry " retry-time
+Specifies the length of time, in minutes, to continue retrying
+notifications to unresponsive hosts.
+If this option is not specified,
+.B sm-notify
+tries to send notifications for 15 minutes.
+.IP
+Specifying a value of 0 causes
+.B sm-notify
+to continue sending notifications to unresponsive peers
+until it is manually killed.
+.TP
+.BI "\-n, " "" "\-\-name " ipaddr " | " hostname
+Specifies the source network address or hostname from which
+to send reboot notification requests.
+If this option is not specified,
+.B sm-notify
+uses an appropriate ANYADDR as the transport bind address,
+and sends the local lockd's
+.I caller_name
+as the
+.I mon_name
+argument to SM_NOTIFY.
+.IP
+This option can be useful in multi-homed configurations where
+the remote requires notification from a specific network address.
+.TP
+.BI "\-o, " "" "\-\-notify\-port " port
+Specifies the source port number for the network socket used to
+send reboot notifications.
+If this option is not specified, a randomly chosen ephemeral port is used.
+.IP
+This option can be used to traverse a firewall between client and server.
+.TP
+.BI "\-P, " "" \-\-state\-directory\-path " pathname
+Specifies a pathname to the parent directory
+on the local system where NSM state information is kept.
+If this option is not specified,
+.B sm-notify
+uses
+.I /var/lib/nfs/statd
+by default.
+.IP
+After starting,
+.B sm-notify
+attempts to set its effective UID and GID to the owner
+and group of this directory.
+.SH SECURITY
+The
+.B sm-notify
+program must be started as root to acquire privileges needed
+to access the state information database.
+It drops root privileges
+as soon as it starts up to reduce the risk of a privilege escalation attack.
+During normal operation,
+the effective user ID it chooses is the owner of the state directory.
+This allows it to continue to access files in that directory after it
+has dropped its root privileges.
+To control which user ID
+.B rpc.statd
+chooses, simply use
+.BR chown (1)
+to set the owner of
+the state directory.
+.SH NOTES
+Lock recovery after a reboot is critical to maintaining data integrity
+and preventing unnecessary application hangs.
+.PP
+To help
+.B rpc.statd
+match SM_NOTIFY requests to NLM requests, a number of best practices
+should be observed, including:
+.IP
+The UTS nodename of your systems should match the DNS names that NFS
+peers use to contact them
+.IP
+The nodenames should all be fully qualified domain names
+.IP
+The forward and reverse DNS mapping of the nodenames should be
+consistent
+.IP
+The hostname the client uses to contact the server should match the
+server's mon_name in SM_NOTIFY requests it sends
+.PP
+The use of network addresses for either argument should be avoided when
+interoperating with non-Linux NFS implementations.
+.PP
+Unmounting an NFS file system does not necessarily stop
+either the NFS client or server from monitoring each other.
+Both may continue monitoring each other for a time in case subsequent
+NFS traffic between the two results in fresh mounts and additional
+file locking.
+.PP
+On Linux, if the
+.B lockd
+kernel module is unloaded during normal operation,
+all remote NFS peers are unmonitored.
+This can happen on an NFS client, for example,
+if an automounter removes all NFS mount
+points due to inactivity.
+.SS IPv6 and TI-RPC support
+This version of
+.B sm-notify
+supports IPv6 networking.
+RPC over IPv6 requires TI-RPC, implemented on Linux via
+.BR libtirpc .
+.B libtirpc
+is required to be available on the local system for this version of
+.BR sm-notify .
+.PP
+.B sm-notify
+will choose an appropriate IPv4 or IPv6 transport
+based on the network address returned by DNS for each remote peer.
+It should be fully compatible with remote systems that do not support TI-RPC
+or IPv6.
+.SH FILES
+.TP 2.5i
+.I /var/lib/nfs/statd/statdb
+default NSM state information database
+.SH SEE ALSO
+.BR rpc.statd (8),
+.BR nfs (5),
+.BR uname (2),
+.BR hostname (7)
+.PP
+RFC 1094 - "NFS: Network File System Protocol Specification"
+.br
+RFC 1813 - "NFS Version 3 Protocol Specification"
+.br
+OpenGroup Protocols for Interworking: XNFS, Version 3W - Chapter 11
+.SH AUTHORS
+Chuck Lever <chuck.lever@oracle.com>
diff --git a/utils/new-statd/statd.man b/utils/new-statd/statd.man
new file mode 100644
index 0000000..66508db
--- /dev/null
+++ b/utils/new-statd/statd.man
@@ -0,0 +1,388 @@
+.\"@(#)rpc.statd.8"
+.\"
+.\" Copyright 2009 Oracle.  All rights reserved.
+.\"
+.TH RPC.STATD 8 "1 July 2009
+.SH NAME
+rpc.statd \- NSM service daemon
+.SH SYNOPSIS
+.BI "rpc.statd [-dhfw] [-H " prog "] [-n " my-name "] [-o " notify-port "] [-p " port "] [-P " path " ]
+.SH DESCRIPTION
+Locks held on files are not part of persistent file system state.
+Lock state is thus lost when a host reboots.
+.PP
+NFS file locking must also detect when lock state is lost because a remote
+host has rebooted.
+After an NFS client reboots, an NFS server must release all locks held by
+applications that were running on that client.
+After a server reboots, a client must remind the
+server of locks held by applications running on that client.
+.PP
+For NFS version 2 and version 3, a network protocol known as the
+.I Network Status Monitor
+protocol (or NSM for short)
+is used to notify NFS peers of reboots.
+On Linux, two separate user-space components constitute the NSM service:
+.TP
+.B rpc.statd
+A daemon that listens for reboot notifications from other hosts, and
+manages the list of hosts to be notified when the local system reboots
+.TP
+.B sm-notify
+A helper program that notifies NFS peers after the local system reboots
+.PP
+When a system reboots, system initialization starts
+.BR rpc.statd ,
+which then typically invokes
+.B sm-notify
+automatically.
+The local NFS lock manager indicates to
+.B rpc.statd
+which remote hosts to monitor.
+.SS NSM operation
+The first file locking interaction between an NFS client and server causes
+the NFS lock managers on both peers to contact their local NSM service to
+store information about their respective remote peers.
+.PP
+On Linux,
+the lock manager contacts
+.BR rpc.statd ,
+which records on persistent storage information about each monitored NFS peer.
+This information describes how to contact a remote peer
+in case the local system reboots, and how to notify the local
+lockd when a monitored peer indicates to
+.B rpc.statd
+it has rebooted.
+.PP
+An NFS client sends a hostname in each file lock request to NFS servers
+that can be used to call the client back.
+This hostname is known as the client's
+.IR caller_name .
+An NFS server can use this hostname to send asynchronous GRANT
+calls to a client, and
+it can also use this hostname when notifying clients of reboots.
+An NFS server may use this hostname,
+or it may simply scrape the client's network address
+from the underlying transport and use that instead,
+when calling a client back.
+.PP
+The hostname or network address of the client is handed to
+.B rpc.statd
+during the first locking interaction between an NFS client and server.
+This is known as the monitored peer's
+.IR mon_name .
+In addition, the local lockd tells
+.B rpc.statd
+what it thinks its own hostname is.
+This hostname is known as
+.IR my_name .
+.PP
+NFS clients do not actually know what an NFS server's
+.I mon_name
+might be, so they usually record the hostname and/or
+network address used to mount the server.
+.SS Reboot notification
+After a reboot,
+.B sm-notify
+reads the list of monitored peers from persistent storage and
+sends an SM_NOTIFY request
+to the NSM service on each listed remote peer,
+using each
+.I mon_name
+as the destination, and the
+.I my_name
+string to identify which host has rebooted.
+.PP
+After receiving an SM_NOTIFY request from a remote peer,
+.B rpc.statd
+contacts its local lock manager,
+which initiates appropriate lock recovery.
+.B rpc.statd
+does not forward all reboot notifications it receives to the local lockd,
+however.
+It matches incoming SM_NOTIFY requests by their
+.I mon_name
+or network address to one or more peers on its own monitor list.
+If
+.B rpc.statd
+does not find a peer on its monitor list that matches
+an incoming SM_NOTIFY request, the request is ignored.
+.PP
+In addition, each peer has its own
+.IR "state number" ,
+which is a 32-bit integer that is bumped after each reboot.
+This state number is communicated between two peers so that they
+can distinguish between actual reboots and replayed notifications.
+.PP
+The value of state number is managed on Linux by
+.BR rpc.statd " and " sm-notify .
+The NSM state number is sent by NFS clients in each NLM LOCK request.
+The client does not discover the server's state number until the
+server sends an SM_NOTIFY request.
+.PP
+After reboot notifications have been
+sent to each peer on the list of monitored hosts,
+.B rpc.statd
+clears the monitor list, since, as noted above,
+lock state does not persist across reboots.
+Part of NFS lock recovery is rediscovering
+which peers need to be monitored again.
+.SH OPTIONS
+.TP
+.BR -d , " --debug
+Causes
+.B rpc.statd
+to generate extra log messages so that NSM operation can be monitored directly.
+If this option is not specified,
+.B rpc.statd
+reports only significant errors.
+.TP
+.BR -h , " --help
+Displays version and usage information on
+.IR stderr .
+.TP
+.BR -F , " --foreground
+Keeps
+.B rpc.statd
+in attached to a controlling terminal so that NSM
+operation can be monitored directly or run under a debugger.
+If this option is not specified,
+.B rpc.statd
+backgrounds itself as soon as it starts.
+.TP
+.BR -w , " --warm-start
+Disables detection of system reboots.
+If this option is not specified,
+.B rpc.statd
+bumps the NSM state number and
+sends reboot notifications automatically once after each system reboot.
+.IP
+Specifying this option prevents
+.B rpc.statd
+from sending notifications automatically after a reboot,
+preserving the existing NSM state number and monitor list.
+This option can be used, for example, in configurations where
+some other program, such as
+.BR sm-notify ,
+is always used to send reboot notifications.
+.IP
+Note that
+.B --warm-start
+does not prevent
+.B rpc.statd
+from sending notifications and bumping the NSM state number
+after receiving an SM_SIMU_CRASH request
+from a privileged port on the local host.
+.TP
+.BI "\-H," "" " \-\-ha-callout " prog
+Specifies a high availability callout program.
+If this option is not specified, all callouts are skipped.
+.IP
+.B rpc.statd
+execs a callout program during processing of
+successful SM_MON, SM_UNMON, and SM_UNMON_ALL requests.
+Such a program may be used in a High Availability NFS (HA-NFS)
+environment to track lock state that may need to be migrated after
+a system restart.
+.IP
+The program is run with 3 arguments:
+The first is either
+.B add-client
+or
+.B del-client
+depending on the reason for the callout.
+The second is the
+.I mon_name
+of the monitored peer.
+The third is the
+.I caller_name
+of the requesting lock manager.
+.TP
+.BI "\-n, " "" "\-\-name " ipaddr " | " hostname
+Specifies the source network address or hostname from which
+to send reboot notification requests.
+If this option is not specified,
+.B rpc.statd
+uses an appropriate ANYADDR as the transport bind address,
+and sends the local lockd's
+.I caller_name
+as the
+.I mon_name
+argument to SM_NOTIFY.
+.IP
+This option can be useful in multi-homed configurations where
+the remote requires notification from a specific network address.
+.TP
+.BI "\-o," "" " \-\-notify\-port "  port
+Specifies a local port number that
+.B rpc.statd
+passes to the
+.B sm-notify
+program when sending reboot notifications.
+See
+.BR sm-notify (8)
+for details.
+.TP
+.BI "\-p," "" " \-\-port " port
+Specifies a port that
+.B rpc.statd
+should use when listening for incoming NSM requests.
+If this option is not specified,
+.B rpc.statd
+choses random ephemeral ports.
+.IP
+This option can be used to fix the port value of its listeners when
+SM_NOTIFY requests must traverse a firewall between clients and servers.
+.TP
+.BI "\-P, " "" \-\-state\-directory\-path " pathname
+Specifies a pathname to the parent directory
+on the local system where NSM state information is kept.
+If this option is not specified,
+.B rpc.statd
+uses
+.I /var/lib/nfs/statd
+by default.
+.IP
+After starting,
+.B rpc.statd
+attempts to set its effective UID and GID to the owner
+and group of this directory.
+.SH SECURITY
+The
+.B rpc.statd
+program must be started as root to acquire privileges needed
+to create sockets with privileged source ports, and to access the
+state information database.
+Because
+.B rpc.statd
+maintains a long-running network service, however, it drops root privileges
+as soon as it starts up to reduce the risk of a privilege escalation attack.
+During normal operation,
+the effective user ID it chooses is the owner of the state directory.
+This allows it to continue to access files in that directory after it
+has dropped its root privileges.
+To control which user ID
+.B rpc.statd
+chooses, simply use
+.BR chown (1)
+to set the owner of
+the state directory.
+.PP
+You can also protect your
+.B rpc.statd
+listeners using the
+.B tcp_wrapper
+library or
+.BR ip_tables .
+Note that the
+.B tcp_wrapper
+library supports only IPv4 networking.
+To use the
+.B tcp_wrapper
+library, list systems that should be allowed access in
+.IR /etc/hosts.allow .
+Use the daemon name
+.B statd
+even if the
+.B rpc.statd
+binary has a different name.
+For further information see the
+.BR tcpd (8)
+and
+.BR hosts_access (5)
+manual pages.
+.SH NOTES
+Lock recovery after a reboot is critical to maintaining data integrity
+and preventing unnecessary application hangs.
+.PP
+To help
+.B rpc.statd
+match SM_NOTIFY requests to NLM requests, a number of best practices
+should be observed, including:
+.IP
+The UTS nodename of your systems should match the DNS names that NFS
+peers use to contact them
+.IP
+The nodenames should all be fully qualified domain names
+.IP
+The forward and reverse DNS mapping of the nodenames should be
+consistent
+.IP
+The hostname the client uses to contact the server should match the
+server's mon_name in SM_NOTIFY requests it sends
+.PP
+The use of network addresses for either argument should be avoided when
+interoperating with non-Linux NFS implementations.
+.PP
+Unmounting an NFS file system does not necessarily stop
+either the NFS client or server from monitoring each other.
+Both may continue monitoring each other for a time in case subsequent
+NFS traffic between the two results in fresh mounts and additional
+file locking.
+.PP
+On Linux, if the
+.B lockd
+kernel module is unloaded during normal operation,
+all remote NFS peers are unmonitored.
+This can happen on an NFS client, for example,
+if an automounter removes all NFS mount
+points due to inactivity.
+.SS IPv6 and TI-RPC support
+This version of
+.B rpc.statd
+supports IPv6 networking.
+RPC over IPv6 requires TI-RPC, implemented on Linux via
+.BR libtirpc .
+.B libtirpc
+is required to be available on the local system for this version of
+.BR rpc.statd .
+.PP
+.B rpc.statd
+consults the local
+.I /etc/netconfig
+database to determine what protocol families and transport protocols
+to use for its listeners.
+It attempts to start listeners on network transports marked
+'visible' in
+.IR /etc/netconfig .
+As long as at least one listener can be started,
+.B rpc.statd
+will operate.
+Marking the "udp6" and "tcp6" netids non-visible in
+.IR /etc/netconfig ,
+for example, will prevent
+.B rpc.statd
+from listening on IPv6 transports.
+.PP
+.B rpc.statd
+resolves the hostname
+.I localhost
+to determine what network address to use when performing NLM callbacks.
+.I localhost
+must resolve to a valid loopback address.
+.SH FILES
+.TP 2.5i
+.I /var/lib/nfs/statd/statdb
+default NSM state information database
+.TP 2.5i
+.I /var/run/run.statd.pid
+pid file
+.TP 2.5i
+.I /etc/netconfig
+network transport capability database
+.SH SEE ALSO
+.BR sm-notify (8),
+.BR nfs (5),
+.BR rpc.nfsd (8),
+.BR rpcbind (8),
+.BR tcpd (8),
+.BR hosts_access (5)
+.BR netconfig (5)
+.sp
+RFC 1094 - "NFS: Network File System Protocol Specification"
+.br
+RFC 1813 - "NFS Version 3 Protocol Specification"
+.br
+OpenGroup Protocols for Interworking: XNFS, Version 3W - Chapter 11
+.SH AUTHORS
+Chuck Lever <chuck.lever@oracle.com>

