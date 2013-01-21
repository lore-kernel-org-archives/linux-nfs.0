Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39874 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753973Ab3AUUrH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:47:07 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 10/13] nfs: Support srcaddr= to bind to specific IP address.
Date: Mon, 21 Jan 2013 12:45:56 -0800
Message-Id: <1358801159-18829-11-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
 fs/nfs/super.c |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 57f0da3..cf3d207 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -106,7 +106,7 @@ enum {
 	/* Mount options that take string arguments */
 	Opt_nfsvers,
 	Opt_sec, Opt_proto, Opt_mountproto, Opt_mounthost,
-	Opt_addr, Opt_mountaddr, Opt_clientaddr,
+	Opt_addr, Opt_mountaddr, Opt_clientaddr, Opt_srcaddr,
 	Opt_lookupcache,
 	Opt_fscache_uniq,
 	Opt_local_lock,
@@ -176,6 +176,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountproto, "mountproto=%s" },
 	{ Opt_addr, "addr=%s" },
 	{ Opt_clientaddr, "clientaddr=%s" },
+	{ Opt_srcaddr, "srcaddr=%s" },
 	{ Opt_mounthost, "mounthost=%s" },
 	{ Opt_mountaddr, "mountaddr=%s" },
 
@@ -725,6 +726,15 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
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
 
@@ -1543,6 +1553,23 @@ static int nfs_parse_mount_options(char *raw,
 				goto out_nomem;
 			mnt->options |= NFS_OPTION_FSCACHE;
 			break;
+		case Opt_srcaddr:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			mnt->srcaddr.addrlen =
+				rpc_pton(mnt->net, string, strlen(string),
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

