Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58067 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab0HZCGn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Aug 2010 22:06:43 -0400
Date: Thu, 26 Aug 2010 12:06:35 +1000
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: mount.nfs: protocol fallback when server doesn't support TCP
Message-ID: <20100826120635.4c3157bc@notabene>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Currently if the server doesn't support TCP (and so doesn't support NFSv4)
we don't fall-back to NFSv3.  This is because 'ECONNREFUSED' isn't deemed to
be a suitable error for falling back.  Rather we wait for about 2 minutes,
then give up.

There is some justification for this:  ECONNREFUSED could just mean that the
server isn't quite ready yet.

I'm not really sure what the best thing to do here would be.  We don't really
want to try v3 and have fail only because it was just enough later that nfsd
is now responding.

Maybe the ideal would be to do a portmap probe and only fall back to v3 if
portmap confirm that v3 is supported and v4 isn't.

For now I just present this patch which allows fallback to v3 providing tcp
wasn't explicitly requested.

Thoughts?

NeilBrown

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0241400..fb8c108 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -762,6 +762,25 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 			errno = 0;
 			result = nfs_try_mount_v4(mi);
 			if (errno != EPROTONOSUPPORT) {
+				/* If server only handles UDP, then v4 will have
+				 * received ECONNREFUSED for TCP, so fall through
+				 * to v3v2 which can try udp, but only if tcp
+				 * wasn't explicitly requested
+				 */
+				if (errno == ECONNREFUSED) {
+					static const char *nfs_proto_tbl[] = {
+						"udp",
+						"tcp",
+						NULL
+					};
+					char *p;
+
+					if (po_rightmost(mi->options, nfs_proto_tbl) == 1)
+						break;
+					p = po_get(mi->options, "proto");
+					if (p && strcmp(p, "tcp") == 0)
+						break;
+				} else
 				/* 
 				 * To deal with legacy Linux servers that don't
 				 * automatically export a pseudo root, retry
