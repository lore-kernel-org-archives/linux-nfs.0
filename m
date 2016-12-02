Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36395 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751164AbcLBD7N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 22:59:13 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 14:58:28 +1100
Subject: [PATCH 04/15] Add /etc/nfs.conf support for mountd.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148065110853.28046.8252065251436176296.stgit@noble>
In-Reply-To: <148065078775.28046.5506130555300891075.stgit@noble>
References: <148065078775.28046.5506130555300891075.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some values are taken from the [nfsd] section
to ensure consistency.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/nfs.conf.man    |   22 +++++++++++++++++++++-
 utils/mountd/mountd.c   |   36 ++++++++++++++++++++++++++++++++++++
 utils/mountd/mountd.man |   34 ++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 1 deletion(-)

diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 6ac6c65a81d9..9fe9d0eff1fc 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -92,16 +92,36 @@ Recognized values:
 .BR vers4.2 ,
 .BR rdma .
 
-Version and protocol values are Boolean values as described above.
+Version and protocol values are Boolean values as described above,
+and are also used by
+.BR rpc.mountd .
 Threads and the two times are integers.
 .B rdma
 is a service name or number.  See
 .BR rpc.nfsd (8)
 for details.
 
+.TP
+.B mountd
+Recognized values:
+.BR manage-gids ,
+.BR descriptors ,
+.BR port ,
+.BR threads ,
+.BR reverse-lookup ,
+.BR state-directory-path ,
+.BR ha-callout .
+
+These, together with the protocol and version values in the
+.B [nfsd]
+section, are used to configure mountd.  See
+.BR rpc.mountd (8)
+for details.
+
 .SH FILES
 .I /etc/nfs.conf
 .SH SEE ALSO
 .BR nfsdcltrack (8),
 .BR rpc.nfsd (8),
+.BR rpc.mountd (8),
 .BR nfsmount.conf (5).
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index d6cebbbd3920..2048fce92b8e 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -22,6 +22,8 @@
 #include <fcntl.h>
 #include <sys/resource.h>
 #include <sys/wait.h>
+
+#include "conffile.h"
 #include "xmalloc.h"
 #include "misc.h"
 #include "mountd.h"
@@ -38,6 +40,8 @@ int reverse_resolve = 0;
 int manage_gids;
 int use_ipaddr = -1;
 
+char *conf_path = NFS_CONFFILE;
+
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
  * send mount or unmount requests -- the callout is not needed for 2.6 kernel */
@@ -654,6 +658,7 @@ main(int argc, char **argv)
 {
 	char    *state_dir = NFS_STATEDIR;
 	char	*progname;
+	char	*s;
 	unsigned int listeners = 0;
 	int	foreground = 0;
 	int	port = 0;
@@ -669,6 +674,37 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
+	conf_init();
+	manage_gids = conf_get_bool("mountd", "manage-gids", manage_gids);
+	descriptors = conf_get_num("mountd", "descriptors", descriptors);
+	port = conf_get_num("mountd", "port", port);
+	num_threads = conf_get_num("mountd", "threads", num_threads);
+	reverse_resolve = conf_get_bool("mountd", "reverse-lookup", reverse_resolve);
+	ha_callout_prog = conf_get_str("mountd", "ha-callout");
+
+	s = conf_get_str("mountd", "state-directory-path");
+	if (s)
+		state_dir = s;
+
+	/* NOTE: following uses "nfsd" section of nfs.conf !!!! */
+	if (conf_get_bool("nfsd", "udp", NFSCTL_UDPISSET(_rpcprotobits)))
+		NFSCTL_UDPSET(_rpcprotobits);
+	else
+		NFSCTL_UDPUNSET(_rpcprotobits);
+	if (conf_get_bool("nfsd", "tcp", NFSCTL_TCPISSET(_rpcprotobits)))
+		NFSCTL_TCPSET(_rpcprotobits);
+	else
+		NFSCTL_TCPUNSET(_rpcprotobits);
+	for (vers = 2; vers <= 4; vers++) {
+		char tag[10];
+		sprintf(tag, "vers%d", vers);
+		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(nfs_version, vers)))
+			NFSCTL_VERSET(nfs_version, vers);
+		else
+			NFSCTL_VERUNSET(nfs_version, vers);
+	}
+
+
 	/* Parse the command line options and arguments. */
 	opterr = 0;
 	while ((c = getopt_long(argc, argv, "o:nFd:p:P:hH:N:V:vurs:t:g", longopts, NULL)) != EOF)
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index e0d1a0acba3a..9f0a51f2016e 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -199,6 +199,39 @@ the server. Note that the 'primary' group id is not affected so a
 .B newgroup
 command on the client will still be effective.  This function requires
 a Linux Kernel with version at least 2.6.21.
+
+.SH CONFIGURATION FILE
+Many of the options that can be set on the command line can also be
+controlled through values set in the
+.B [mountd]
+or, in some cases, the
+.B [nfsd]
+sections of the
+.I /etc/nfs.conf
+configuration file.
+Values recognized in the
+.B [mountd]
+section include
+.BR manage-gids ,
+.BR descriptors ,
+.BR port ,
+.BR threads ,
+.BR reverse-lookup ", and"
+.BR state-directory-path ,
+.B ha-callout
+which each have the same effect as the option with the same name.
+
+The values recognized in the
+.B [nfsd]
+section include
+.BR TCP ,
+.BR UDP ,
+.BR vers2 ,
+.BR vers3 ", and"
+.B vers4
+which each have same same meaning as given by
+.BR rpc.nfsd (8).
+
 .SH TCP_WRAPPERS SUPPORT
 You can protect your
 .B rpc.mountd
@@ -253,6 +286,7 @@ table of clients accessing server's exports
 .BR rpc.nfsd (8),
 .BR rpc.rquotad (8),
 .BR nfs (5),
+.BR nfs.conf (5),
 .BR tcpd (8),
 .BR hosts_access (5),
 .BR iptables (8),


