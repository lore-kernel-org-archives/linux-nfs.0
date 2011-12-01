Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 5350504D.static.ziggozakelijk.nl ([83.80.80.77]:26035 "EHLO
	ns2.tasking.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755708Ab1LARlE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 12:41:04 -0500
Received: from leonino.tasking.nl (nl-fg300a-1-dmz.tasking.nl [172.16.1.8])
	by ns2.tasking.nl (8.14.5/8.14.5) with ESMTP id pB1HXBtS027072
	for <linux-nfs@vger.kernel.org>; Thu, 1 Dec 2011 18:33:12 +0100 (MET)
Received: from lahti.tasking.nl (lahti.tasking.nl [172.17.2.45])
	by leonino.tasking.nl (8.14.3/8.14.3) with ESMTP id pB1HX8LR014975
	for <linux-nfs@vger.kernel.org>; Thu, 1 Dec 2011 18:33:08 +0100 (MET)
To: linux-nfs@vger.kernel.org
Mime-Version: 1.0
Reply-To: dick@streefland.net (Dick Streefland)
From: dick@streefland.net (Dick Streefland)
Subject: [PATCH] retry for NFS v3 mounts
Content-Type: text/plain; charset=us-ascii
Message-ID: <37c5.4ed7ba54.3cfb1@altium.nl>
Date: Thu, 01 Dec 2011 17:33:08 -0000
From: rnews@altium.nl
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mounting an NFS v3 volume from a server that is currently down,
immediately fails with a timeout error, instead of retrying:

# mount -t nfs -v -overs=3,proto=udp,bg server:/foo /mnt
mount.nfs: trying text-based options 'vers=3,proto=udp,bg,addr=172.17.2.94'
mount.nfs: prog 100003, trying vers=3, prot=17
mount.nfs: portmap query failed: RPC: Timed out

mount.nfs: mount to NFS server 'server:/foo' failed: timed out, giving up

# mount -t nfs -v -overs=3,proto=tcp,bg server:/foo /mnt
mount.nfs: trying text-based options 'vers=3,proto=tcp,bg,addr=172.17.2.94'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: portmap query failed: RPC: Remote system error - No route to host

mount.nfs: No route to host

As a result, NFS mounts may not come up after a power failure when the
client boots faster than the server. The attached patch for nfs-utils
adds ESPIPE to the list of errors considered temporary, so that the
mount will be retried:

# mount -t nfs -v -overs=3,proto=udp,bg server:/foo /mnt
mount.nfs: trying text-based options 'vers=3,proto=udp,bg,addr=172.17.2.94'
mount.nfs: prog 100003, trying vers=3, prot=17
mount.nfs: portmap query failed: RPC: Timed out

mount.nfs: backgrounding "server:/foo"
mount.nfs: mount options: "vers=3,proto=udp,bg,addr=172.17.2.94"

# mount -t nfs -v -overs=3,proto=tcp,bg server:/foo /mnt
mount.nfs: trying text-based options 'vers=3,proto=tcp,bg,addr=172.17.2.94'
mount.nfs: prog 100003, trying vers=3, prot=6
mount.nfs: portmap query failed: RPC: Remote system error - No route to host

mount.nfs: backgrounding "server:/foo"
mount.nfs: mount options: "vers=3,proto=tcp,bg,addr=172.17.2.94"

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 4032bf3..7ca0b3e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -663,6 +663,7 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		case ECONNREFUSED:
 		case EOPNOTSUPP:
 		case EHOSTUNREACH:
+		case ESPIPE:
 			continue;
 		default:
 			goto out;
@@ -848,6 +849,7 @@ static int nfs_is_permanent_error(int error)
 	case ETIMEDOUT:
 	case ECONNREFUSED:
 	case EHOSTUNREACH:
+	case ESPIPE:
 		return 0;	/* temporary */
 	default:
 		return 1;	/* permanent */

-- 
Dick

