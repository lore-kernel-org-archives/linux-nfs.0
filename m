From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 27/29] statd: update rpc.statd(8) and sm-notify(8) to reflect
	IPv6 support
Date: Tue, 10 Nov 2009 17:00:47 -0500
Message-ID: <20091110220047.23822.14481.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:25579 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636AbZKJWBY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:01:24 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Expand and clarify the explanation of NSM operation on Linux, and
provide the same text in both man pages.

Update descriptions of the command line options to match the operation
of the current implementation.

Introduce sections discussing security and operational issues, and
IPv6 operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.man |  407 +++++++++++++++++++++++++-----------
 utils/statd/statd.man     |  504 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 638 insertions(+), 273 deletions(-)

diff --git a/utils/statd/sm-notify.man b/utils/statd/sm-notify.man
index a5c1cc5..163713e 100644
--- a/utils/statd/sm-notify.man
+++ b/utils/statd/sm-notify.man
@@ -1,162 +1,315 @@
-.\"
-.\" sm-notify(8)
+.\"@(#)sm-notify.8"
 .\"
 .\" Copyright (C) 2004 Olaf Kirch <okir@suse.de>
-.TH sm-notify 8 "19 Mar 2007
+.\"
+.\" Rewritten by Chuck Lever <chuck.lever@oracle.com>, 2009.
+.\" Copyright 2009 Oracle.  All rights reserved.
+.\"
+.TH SM-NOTIFY 8 "1 November 2009
 .SH NAME
-sm-notify \- Send out NSM reboot notifications
+sm-notify \- send reboot notifications to NFS peers
 .SH SYNOPSIS
-.BI "/sbin/sm-notify [-df] [-m " time "] [-p " port "] [-P " path "] [-v " my_name " ]
+.BI "/usr/sbin/sm-notify [-dfn] [-m " minutes "] [-v " name "] [-p " notify-port "] [-P " path "]
 .SH DESCRIPTION
-File locking over NFS (v2 and v3) requires a facility to notify peers in
-case of a reboot, so that clients can reclaim locks after
-a server crash, and/or
-servers can release locks held by the rebooted client.
+File locks are not part of persistent file system state.
+Lock state is thus lost when a host reboots.
+.PP
+Network file systems must also detect when lock state is lost
+because a remote host has rebooted.
+After an NFS client reboots, an NFS server must release all file locks
+held by applications that were running on that client.
+After a server reboots, a client must remind the
+server of file locks held by applications running on that client.
 .PP
-This is a two-step process: during normal
-operations, a mechanism is required to keep track of which
-hosts need to be informed of a reboot. And of course,
-notifications need to be sent out during reboot.
-The protocol used for this is called NSM, for
-.IR "Network Status Monitor" .
+For NFS version 2 and version 3, the
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
 .PP
-This implementation separates these into separate program.
+The local NFS lock manager alerts its local
 .B rpc.statd
-tracks hosts which need to be notified and this
+of each remote peer that should be monitored.
+When the local system reboots, the
 .B sm-notify
-performs the notification.  When
+command notifies the NSM service on monitored peers of the reboot.
+When a remote reboots, that peer notifies the local
+.BR rpc.statd ,
+which in turn passes the reboot notification
+back to the local NFS lock manager.
+.SH NSM OPERATION IN DETAIL
+The first file locking interaction between an NFS client and server causes
+the NFS lock managers on both peers to contact their local NSM service to
+store information about the opposite peer.
+On Linux, the local lock manager contacts
+.BR rpc.statd .
+.PP
+.B rpc.statd
+records information about each monitored NFS peer on persistent storage.
+This information describes how to contact a remote peer
+in case the local system reboots,
+how to recognize which monitored peer is reporting a reboot,
+and how to notify the local lock manager when a monitored peer
+indicates it has rebooted.
+.PP
+An NFS client sends a hostname, known as the client's
+.IR caller_name ,
+in each file lock request.
+An NFS server can use this hostname to send asynchronous GRANT
+calls to a client, or to notify the client it has rebooted.
+.PP
+The Linux NFS server can provide the client's
+.I caller_name
+or the client's network address to
+.BR rpc.statd .
+For the purposes of the NSM protocol,
+this name or address is known as the monitored peer's
+.IR mon_name .
+In addition, the local lock manager tells
 .B rpc.statd
-is started it will typically started
+what it thinks its own hostname is.
+For the purposes of the NSM protocol,
+this hostname is known as
+.IR my_name .
+.PP
+There is no equivalent interaction between an NFS server and a client
+to inform the client of the server's
+.IR caller_name .
+Therefore NFS clients do not actually know what
+.I mon_name
+an NFS server might use in an SM_NOTIFY request.
+The Linux NFS client records the server's hostname used on the mount command
+to identify rebooting NFS servers.
+.SS Reboot notification
+When the local system reboots, the
+.B sm-notify
+command reads the list of monitored peers from persistent storage and
+sends an SM_NOTIFY request to the NSM service on each listed remote peer.
+It uses the
+.I mon_name
+string as the destination.
+To identify which host has rebooted, the
 .B sm-notify
-but this is configurable.
-.SS Operation
-For each NFS client or server machine to be monitored,
+command normally sends the results of
+.BR gethostname (3)
+as the
+.I my_name
+string.
+The remote
 .B rpc.statd
-creates a file in
-.BR /var/lib/nfs/sm ", "
-and removes the file if monitoring is no longer required.
+matches incoming SM_NOTIFY requests using this string,
+or the caller's network address,
+to one or more peers on its own monitor list.
 .PP
-When the machine is rebooted,
+If
+.B rpc.statd
+does not find a peer on its monitor list that matches
+an incoming SM_NOTIFY request,
+the notification is not forwarded to the local lock manager.
+In addition, each peer has its own
+.IR "NSM state number" ,
+a 32-bit integer that is bumped after each reboot by the
 .B sm-notify
-iterates through these files and notifies the peer
-.B statd
-server on those machines.
+command.
+.B rpc.statd
+uses this number to distinguish between actual reboots
+and replayed notifications.
 .PP
-Each machine has an
-.I "NSM state" ,
-which is basically an integer counter that is incremented
-each time the machine reboots. This counter is stored
-in
-.BR /var/lib/nfs/state ,
-and updated by
-.BR sm-notify .
-.SS Security
-.B sm-notify
-has little need for root privileges and so drops them as soon as
-possible.
-It continues to need to make changes to the
-.B sm
-and
-.B sm.bak
-directories so to be able to drop privileges, these must be writable
-by a non-privileged user.  If these directories are owned by a
-non-root user,
-.B sm-notify
-will drop privilege to match that user once it has created sockets for
-sending out request (for which it needs privileged) but before it
-processes any reply (which is the most likely source of possible
-privilege abuse).
+Part of NFS lock recovery is rediscovering
+which peers need to be monitored again.
+The
+.B sm-notify
+command clears the monitor list on persistent storage after each reboot.
 .SH OPTIONS
 .TP
-.BI -m " failtime
-When notifying hosts,
+.B -d
+Keeps
+.B sm-notify
+attached to its controlling terminal and running in the foreground
+so that notification progress may be monitored directly.
+.TP
+.B -f
+Send notifications even if
 .B sm-notify
-will try to contact each host for up to 15 minutes,
-and will give up if unable to reach it within this time
-frame.
+has already run since the last system reboot.
+.TP
+.BI -m " retry-time
+Specifies the length of time, in minutes, to continue retrying
+notifications to unresponsive hosts.
+If this option is not specified,
+.B sm-notify
+attempts to send notifications for 15 minutes.
+Specifying a value of 0 causes
+.B sm-notify
+to continue sending notifications to unresponsive peers
+until it is manually killed.
 .IP
-Using the
-.B -m
-option, you can override this. A value of 0 tells
-sm-notify to retry indefinitely; any other value is
-interpreted as the maximum retry time in minutes.
+Notifications are retried if sending fails,
+the remote does not respond,
+the remote's NSM service is not registered,
+or if there is a DNS failure
+which prevents the remote's
+.I mon_name
+from being resolved to an address.
+.IP
+Hosts are not removed from the notification list until a valid
+reply has been received.
+However, the SM_NOTIFY procedure has a void result.
+There is no way for
+.B sm-notify
+to tell if the remote recognized the sender and has started
+appropriate lock recovery.
 .TP
-.BI -v " ipaddr-or-hostname
-This option tells
-.B sm-notify
-to bind to the specified
-.IR ipaddr ,
-(or the ipaddr of the given
-.IR hostname )
-so that all notification packets originate from this address.
-This is useful for NFS failover.  The given name is also used as the
-.I name
-of this host in the NSM request.
+.B -n
+Prevents
+.B sm-notify
+from updating the local system's NSM state number.
 .TP
 .BI -p " port
-instructs
+Specifies the source port number
 .B sm-notify
-to bind to the indicated IP
-.IR port
-number. If this option is not given, it will try to bind to
-a randomly chosen privileged port below 1024.
+should use when sending reboot notifications.
+If this option is not specified, a randomly chosen ephemeral port is used.
+.IP
+This option can be used to traverse a firewall between client and server.
 .TP
-.BI -P " /path/to/state/directory
-If
+.BI "\-P, " "" \-\-state\-directory\-path " pathname
+Specifies the pathname of the parent directory
+where NSM state information resides.
+If this option is not specified,
+.B sm-notify
+uses
+.I /var/lib/nfs
+by default.
+.IP
+After starting,
 .B sm-notify
-should look in a no-standard place of state file, the path can be
-given here.  The directories
-.B sm
-and
-.B sm.bak
-and the file
-.B state
-must exist in that directory with the standard names.
+attempts to set its effective UID and GID to the owner
+and group of this directory.
 .TP
-.B -f
-If the state path has not been reset with
-.BR -P ,
+.BI -v " ipaddr " | " hostname
+Specifies the network address from which to send reboot notifications,
+and the
+.I mon_name
+argument to use when sending SM_NOTIFY requests.
+If this option is not specified,
 .B sm-notify
-will normally create a file in
-.B /var/run
-to indicate that it has been
-run.  If this file is found when
+uses a wildcard address as the transport bind address,
+and uses the results of
+.BR gethostname (3)
+as the
+.I mon_name
+argument.
+.IP
+The
+.I ipaddr
+form can be expressed as either an IPv4 or an IPv6 presentation address.
+.IP
+This option can be useful in multi-homed configurations where
+the remote requires notification from a specific network address.
+.SH SECURITY
+The
 .B sm-notify
-starts, it will not run again (as it is normally only needed once per
-reboot).
-If
-.B -f
-(for
-.BR force )
-is given,
+command must be started as root to acquire privileges needed
+to access the state information database.
+It drops root privileges
+as soon as it starts up to reduce the risk of a privilege escalation attack.
+.PP
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
+.SH ADDITIONAL NOTES
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
+The UTS nodenames of your systems should always be fully qualified domain names
+.IP
+The forward and reverse DNS mapping of the UTS nodenames should be
+consistent
+.IP
+The hostname the client uses to mount the server should match the server's
+.I mon_name
+in SM_NOTIFY requests it sends
+.IP
+The use of network addresses as a
+.I mon_name
+or a
+.I my_name
+string should be avoided when
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
+TI-RPC is a pre-requisite for supporting NFS on IPv6.
+If TI-RPC support is built into the
 .B sm-notify
-will run even if the file in
-.B /var/run
-is present.
-.TP
-.B -n
-Do not update the NSM state. This is for testing only.  Setting this
-flag implies
-.BR -f .
-.TP
-.B -d
-Enables debugging.
-By default,
+command ,it will choose an appropriate IPv4 or IPv6 transport
+based on the network address returned by DNS for each remote peer.
+It should be fully compatible with remote systems
+that do not support TI-RPC or IPv6.
+.PP
+Currently, the
 .B sm-notify
-forks and puts itself in the background after obtaining the
-list of hosts from
-.BR /var/lib/nfs/sm .
+command supports sending notification only via datagram transport protocols.
 .SH FILES
-.BR /var/lib/nfs/state
-.br
-.BR /var/lib/nfs/sm/*
+.TP 2.5i
+.I /var/lib/nfs/sm
+directory containing monitor list
+.TP 2.5i
+.I /var/lib/nfs/sm.bak
+directory containing notify list
+.TP 2.5i
+.I /var/lib/nfs/state
+NSM state number for this host
+.TP 2.5i
+.I /proc/sys/fs/nfs/nsm_local_state
+kernel's copy of the NSM state number
+.SH SEE ALSO
+.BR rpc.statd (8),
+.BR nfs (5),
+.BR uname (2),
+.BR hostname (7)
+.PP
+RFC 1094 - "NFS: Network File System Protocol Specification"
 .br
-.BR /var/lib/nfs/sm.bak/*
+RFC 1813 - "NFS Version 3 Protocol Specification"
 .br
-.BR /var/run/sm-notify.pid
-.SH SEE ALSO
-.BR rpc.nfsd(8),
-.BR portmap(8)
+OpenGroup Protocols for Interworking: XNFS, Version 3W - Chapter 11
 .SH AUTHORS
-.br
 Olaf Kirch <okir@suse.de>
+.br
+Chuck Lever <chuck.lever@oracle.com>
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index e8be9f3..d5ab081 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -1,191 +1,401 @@
-.\"
-.\" statd(8)
+.\"@(#)rpc.statd.8"
 .\"
 .\" Copyright (C) 1999 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
 .\" Modified by Jeffrey A. Uphoff, 1999, 2002, 2005.
 .\" Modified by Lon Hohberger, 2000.
 .\" Modified by Paul Clements, 2004.
-.TH rpc.statd 8 "31 Aug 2004"
+.\"
+.\" Rewritten by Chuck Lever <chuck.lever@oracle.com>, 2009.
+.\" Copyright 2009 Oracle.  All rights reserved.
+.\"
+.TH RPC.STATD 8 "1 November 2009
 .SH NAME
-rpc.statd \- NSM status monitor
+rpc.statd \- NSM service daemon
 .SH SYNOPSIS
-.B "rpc.statd [-FNL] [-d] [-?] [-n " name "] [-o " port "] [-p " port "] [-H " prog "] [-V]"
+.BI "rpc.statd [-dh?FLNvVw] [-H " prog "] [-n " my-name "] [-o " outgoing-port "] [-p " listener-port "] [-P " path " ]
 .SH DESCRIPTION
-The
+File locks are not part of persistent file system state.
+Lock state is thus lost when a host reboots.
+.PP
+Network file systems must also detect when lock state is lost
+because a remote host has rebooted.
+After an NFS client reboots, an NFS server must release all file locks
+held by applications that were running on that client.
+After a server reboots, a client must remind the
+server of file locks held by applications running on that client.
+.PP
+For NFS version 2 and version 3, the
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
+The local NFS lock manager alerts its local
+.B rpc.statd
+of each remote peer that should be monitored.
+When the local system reboots, the
+.B sm-notify
+command notifies the NSM service on monitored peers of the reboot.
+When a remote reboots, that peer notifies the local
+.BR rpc.statd ,
+which in turn passes the reboot notification
+back to the local NFS lock manager.
+.SH NSM OPERATION IN DETAIL
+The first file locking interaction between an NFS client and server causes
+the NFS lock managers on both peers to contact their local NSM service to
+store information about the opposite peer.
+On Linux, the local lock manager contacts
+.BR rpc.statd .
+.PP
+.B rpc.statd
+records information about each monitored NFS peer on persistent storage.
+This information describes how to contact a remote peer
+in case the local system reboots,
+how to recognize which monitored peer is reporting a reboot,
+and how to notify the local lock manager when a monitored peer
+indicates it has rebooted.
+.PP
+An NFS client sends a hostname, known as the client's
+.IR caller_name ,
+in each file lock request.
+An NFS server can use this hostname to send asynchronous GRANT
+calls to a client, or to notify the client it has rebooted.
+.PP
+The Linux NFS server can provide the client's
+.I caller_name
+or the client's network address to
+.BR rpc.statd .
+For the purposes of the NSM protocol,
+this name or address is known as the monitored peer's
+.IR mon_name .
+In addition, the local lock manager tells
 .B rpc.statd
-server implements the NSM (Network Status Monitor) RPC protocol.
-This service is somewhat misnamed, since it doesn't actually provide
-active monitoring as one might suspect; instead, NSM implements a
-reboot notification service. It is used by the NFS file locking service,
-.BR rpc.lockd ,
-to implement lock recovery when the NFS server machine crashes and
-reboots.
-.SS Operation
-For each NFS client or server machine to be monitored,
-.B rpc.statd
-creates a file in
-.BR /var/lib/nfs/sm .
-When starting, it normally runs
+what it thinks its own hostname is.
+For the purposes of the NSM protocol,
+this hostname is known as
+.IR my_name .
+.PP
+There is no equivalent interaction between an NFS server and a client
+to inform the client of the server's
+.IR caller_name .
+Therefore NFS clients do not actually know what
+.I mon_name
+an NFS server might use in an SM_NOTIFY request.
+The Linux NFS client uses the server hostname from the mount command
+to identify rebooting NFS servers.
+.SS Reboot notification
+When the local system reboots, the
+.B sm-notify
+command reads the list of monitored peers from persistent storage and
+sends an SM_NOTIFY request to the NSM service on each listed remote peer.
+It uses the
+.I mon_name
+string as the destination.
+To identify which host has rebooted, the
 .B sm-notify
-to iterate through these files and notify the
-peer
+command normally sends the results of
+.BR gethostname (3)
+as the
+.I my_name
+string.
+The remote
+.B rpc.statd
+matches incoming SM_NOTIFY requests using this string,
+or the caller's network address,
+to one or more peers on its own monitor list.
+.PP
+If
 .B rpc.statd
-on those machines.
+does not find a peer on its monitor list that matches
+an incoming SM_NOTIFY request,
+the notification is not forwarded to the local lock manager.
+In addition, each peer has its own
+.IR "NSM state number" ,
+a 32-bit integer that is bumped after each reboot by the
+.B sm-notify
+command.
+.B rpc.statd
+uses this number to distinguish between actual reboots
+and replayed notifications.
+.PP
+Part of NFS lock recovery is rediscovering
+which peers need to be monitored again.
+The
+.B sm-notify
+command clears the monitor list on persistent storage after each reboot.
 .SH OPTIONS
 .TP
-.B -F
-By default,
+.BR -d , " --no-syslog
+Causes
 .B rpc.statd
-forks and puts itself in the background when started. The
+to write log messages on
+.I stderr
+instead of to the system log,
+if the
 .B -F
-argument tells it to remain in the foreground. This option is
-mainly for debugging purposes.
+option was also specified.
 .TP
-.B -d
-By default,
-.B rpc.statd
-sends logging messages via
-.BR syslog (3)
-to system log.  The
-.B -d
-argument forces it to log verbose output to
-.B stderr
-instead. This option is mainly for debugging purposes, and may only
-be used in conjunction with the
-.B -F
-parameter.
+.BR -F , " --foreground
+Keeps
+.B rpc.statd
+attached to its controlling terminal so that NSM
+operation can be monitored directly or run under a debugger.
+If this option is not specified,
+.B rpc.statd
+backgrounds itself soon after it starts.
 .TP
-.BI "\-n," "" " \-\-name " name 
-specify a name for
-.B rpc.statd
-to use as the local hostname. By default,
-.BR rpc.statd
-will call
-.BR gethostname (2)
-to get the local hostname. Specifying
-a local hostname may be useful for machines with more than one
-interfaces.
+.BR -h , " -?" , " --help
+Causes
+.B rpc.statd
+to display usage information on
+.I stderr
+and then exit.
 .TP
-.BI "\-o," "" " \-\-outgoing\-port "  port
-specify a port for
-.B rpc.statd
-to send outgoing status requests from.  By default,
-.BR rpc.statd
-will ask
-.BR portmap (8)
-to assign it a port number.  As of this writing, there is not
-a standard port number that
-.BR portmap
-always or usually assigns.  Specifying
-a port may be useful when implementing a firewall.
+.BI "\-H," "" " \-\-ha-callout " prog
+Specifies a high availability callout program.
+If this option is not specified, no callouts are performed.
+See the
+.B High-availability callouts
+section below for details.
 .TP
-.BI "\-p," "" " \-\-port " port
-specify a port for
-.B rpc.statd
-to listen on.  By default,
-.BR rpc.statd
-will ask
-.BR portmap (8)
-to assign it a port number.  As of this writing, there is not
-a standard port number that
-.BR portmap
-always or usually assigns.  Specifying
-a port may be useful when implementing a firewall.
-.TP
-.BI "\-P," "" " \-\-state\-directory\-path "  directory
-specify a directory in which to place statd state information.
-If this option is not specified the default of 
-.BR /var/lib/nfs
-is used.
+.BR -L , " --no-notify
+Prevents
+.B rpc.statd
+from running the
+.B sm-notify
+command when it starts up,
+preserving the existing NSM state number and monitor list.
+.IP
+Note: the
+.B sm-notify
+command contains a check to ensure it runs only once after each system reboot.
+This prevents spurious reboot notification if
+.B rpc.statd
+restarts without the
+.B -L
+option.
 .TP
-.B -N
-Causes statd to run in the notify-only mode. When started in this mode, the
-statd program will check its state directory, send notifications to any
-monitored nodes, and exit once the notifications have been sent. This mode is
-used to enable Highly Available NFS implementations (i.e. HA-NFS).
-This mode is deprecated \-
+.BI "\-n, " "" "\-\-name " ipaddr " | " hostname
+Specifies the statd listener's bind address or hostname.
+The
+.I ipaddr
+form can be expressed as either an IPv4 or an IPv6 presentation address.
+If this option is not specified,
+.B rpc.statd
+uses a wildcard address as the transport bind address.
+.IP
+This string is also passed to the
 .B sm-notify
-should be used directly instead.
+command to be used as the source address from which
+to send reboot notification requests.
+See 
+.BR sm-notify (8)
+for details.
 .TP
-.BR -L , " --no-notify
-Inhibits the running of
-.BR sm-notify .
-If
+.BR -N
+Causes
+.B rpc.statd
+to run the
 .B sm-notify
-is run by some other script at boot time, there is no need for
-.B statd
-to start sm-notify itself.  This can be appropriate if starting of
-statd needs to be delayed until it is actually need.  In such cases
+command, and then exit.
+Since the
 .B sm-notify
-should still be run at boot time.
+command can also be run directly, this option is deprecated.
 .TP
-.BI "\-H, " "" " \-\-ha-callout " prog
-Specify a high availability callout program, which will receive callouts
-for all client monitor and unmonitor requests. This allows
+.BI "\-o," "" " \-\-outgoing\-port "  port
+Specifies the source port number the
+.B sm-notify
+command should use when sending reboot notifications.
+See
+.BR sm-notify (8)
+for details.
+.TP
+.BI "\-p," "" " \-\-port " port
+Specifies the statd listener's port number.
+If this option is not specified,
 .B rpc.statd
-to be used in a High Availability NFS (HA-NFS) environment. The
-program will be run with 3 arguments:  The first is either
-.B add-client
-or
-.B del-client
-depending on the reason for the callout.
-The second will be the name of the client.
-The third will be the name of the server as known to the client.
+choses a random ephemeral port.
+.IP
+This option can be used to fix the port value of its listeners when
+SM_NOTIFY requests must traverse a firewall between clients and servers.
 .TP
-.B -?
-Causes
+.BI "\-P, " "" \-\-state\-directory\-path " pathname
+Specifies the pathname of the parent directory
+where NSM state information resides.
+If this option is not specified,
+.B rpc.statd
+uses
+.I /var/lib/nfs
+by default.
+.IP
+After starting,
 .B rpc.statd
-to print out command-line help and exit.
+attempts to set its effective UID and GID to the owner
+and group of this directory.
 .TP
-.B -V
+.BR -v ", " -V ", " --version
 Causes
 .B rpc.statd
-to print out version information and exit.
-
-
-
-.SH TCP_WRAPPERS SUPPORT
-This
+to display version information on
+.I stderr
+and then exit.
+.SH SECURITY
+The
+.B rpc.statd
+daemon must be started as root to acquire privileges needed
+to create sockets with privileged source ports, and to access the
+state information database.
+Because
 .B rpc.statd
-version is protected by the
+maintains a long-running network service, however, it drops root privileges
+as soon as it starts up to reduce the risk of a privilege escalation attack.
+.PP
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
 .B tcp_wrapper
-library. You have to give the clients access to
-.B rpc.statd
-if they should be allowed to use it. To allow connects from clients of
-the .bar.com domain you could use the following line in /etc/hosts.allow:
-
-statd: .bar.com
-
-You have to use the daemon name 
+library supports only IPv4 networking.
+To use the
+.B tcp_wrapper
+library, add the hostnames of peers that should be allowed access to
+.IR /etc/hosts.allow .
+Use the daemon name
 .B statd
-for the daemon name (even if the binary has a different name).
-
-For further information please have a look at the
+even if the
+.B rpc.statd
+binary has a different name.
+For further information see the
 .BR tcpd (8)
 and
 .BR hosts_access (5)
 manual pages.
-
-.SH SIGNALS
-.BR SIGUSR1
-causes
-.B rpc.statd
-to re-read the notify list from disk
-and send notifications to clients. This can be used in High Availability NFS
-(HA-NFS) environments to notify clients to reacquire file locks upon takeover
-of an NFS export from another server.
-
+.SH ADDITIONAL NOTES
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
+The UTS nodenames of your systems should always be fully qualified domain names
+.IP
+The forward and reverse DNS mapping of the UTS nodenames should be
+consistent
+.IP
+The hostname the client uses to mount the server should match the server's
+.I mon_name
+in SM_NOTIFY requests it sends
+.IP
+The use of network addresses as a
+.I mon_name
+or a
+.I my_name
+string should be avoided when
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
+.SS High-availability callouts
+.B rpc.statd
+can exec a special callout program during processing of
+successful SM_MON, SM_UNMON, and SM_UNMON_ALL requests.
+Such a program may be used in High Availability NFS (HA-NFS)
+environments to track lock state that may need to be migrated after
+a system reboot.
+.PP
+The name of the callout program is specified with the
+.B -H
+option.
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
+.SS IPv6 and TI-RPC support
+TI-RPC is a pre-requisite for supporting NFS on IPv6.
+If TI-RPC support is built into
+.BR rpc.statd ,
+it attempts to start listeners on network transports marked
+'visible' in
+.IR /etc/netconfig .
+As long as at least one network transport listener starts successfully,
+.B rpc.statd
+will operate.
 .SH FILES
-.BR /var/lib/nfs/state
+.TP 2.5i
+.I /var/lib/nfs/sm
+directory containing monitor list
+.TP 2.5i
+.I /var/lib/nfs/sm.bak
+directory containing notify list
+.TP 2.5i
+.I /var/lib/nfs/state
+NSM state number for this host
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
 .br
-.BR /var/lib/nfs/sm/*
+RFC 1813 - "NFS Version 3 Protocol Specification"
 .br
-.BR /var/lib/nfs/sm.bak/*
-.SH SEE ALSO
-.BR rpc.nfsd(8),
-.BR portmap(8)
+OpenGroup Protocols for Interworking: XNFS, Version 3W - Chapter 11
 .SH AUTHORS
-.br
 Jeff Uphoff <juphoff@users.sourceforge.net>
 .br
 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
@@ -195,3 +405,5 @@ H.J. Lu <hjl-mXXj517/zsQ@public.gmane.org>
 Lon Hohberger <hohberger-djc/iPCCuDZegjQ2I56v3Dti40yvJfI7@public.gmane.org>
 .br
 Paul Clements <paul.clements-G8/ITkJZaeZWk0Htik3J/w@public.gmane.org>
+.br
+Chuck Lever <chuck.lever@oracle.com>

