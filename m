Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34554 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756650Ab1FIXF5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:05:57 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 11/11] nfs: Support srcaddr= to bind to specific IP address.
Date: Thu,  9 Jun 2011 16:02:55 -0700
Message-Id: <1307660575-6994-12-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
References: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

In order to have more control on multi-homed machines, it is
nice to be able to bind to a specific IP address.  This can aid
with interface selection, policy based routing, multiple unique
mounts to the same server, and similar things.

This patch allows srcaddr= option for NFS.  The key 'srcaddr'
was chosen to match the similar patch for cifs.

For NFSv4, if one is specifying clientaddr, it must be the same as
srcaddr or things may not work properly.

NFSv3, NFSv4 over TCP/IPv4 and TCP/IPv6 has been successfully tested.

Usage:
  mount -t nfs4 [2002::1]:/rpool/ben /mnt/foo/ben-1 -o srcaddr=2002::2,clientaddr=2002::2
  mount -t nfs4 192.168.100.3:/foo /mnt/foo/ben-2 -o srcaddr=192.168.100.174

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 e45f616... 5d88e7b... M	fs/nfs/super.c
 fs/nfs/super.c |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e45f616..5d88e7b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -103,7 +103,7 @@ enum {
 
 	/* Mount options that take string arguments */
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
-	Opt_addr, Opt_mountaddr, Opt_clientaddr,
+	Opt_addr, Opt_mountaddr, Opt_clientaddr, Opt_srcaddr,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
 	Opt_local_lock,
@@ -173,6 +173,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountproto, "mountproto=%s" },
 	{ Opt_addr, "addr=%s" },
 	{ Opt_clientaddr, "clientaddr=%s" },
+	{ Opt_srcaddr, "srcaddr=%s" },
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
@@ -695,6 +696,15 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	else
 		nfs_show_nfsv4_options(m, nfss, showdefaults);
 
+	if (clp->srcaddr.ss_family == AF_INET6) {
+		struct sockaddr_in6 *sin6;
+		sin6 = (struct sockaddr_in6 *)(&clp->srcaddr);
+		seq_printf(m, ",srcaddr=%pI6c", &sin6->sin6_addr);
+	} else if (clp->srcaddr.ss_family == AF_INET) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)&clp->srcaddr;
+		seq_printf(m, ",srcaddr=%pI4", &sin->sin_addr.s_addr);
+	}
+
 	if (nfss->options & NFS_OPTION_FSCACHE)
 		seq_printf(m, ",fsc");
 
@@ -1448,6 +1458,23 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_nomem;
 			mnt->options |= NFS_OPTION_FSCACHE;
 			break;
+		case Opt_srcaddr:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			mnt->srcaddr.addrlen =
+				rpc_pton(string, strlen(string),
+					 (struct sockaddr *)
+					 &mnt->srcaddr.address,
+					 sizeof(mnt->srcaddr.address));
+			kfree(string);
+			if (mnt->srcaddr.addrlen == 0) {
+				printk(KERN_WARNING
+				       "nfs: Could not parse srcaddr: %s\n",
+				       string);
+				goto out_invalid_address;
+			}
+			break;
 		case Opt_local_lock:
 			string = match_strdup(args);
 			if (string == NULL)
-- 
1.7.3.4

