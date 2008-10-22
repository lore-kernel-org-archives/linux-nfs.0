From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: Fix BUG during NFSD shutdown processing
Date: Wed, 22 Oct 2008 13:12:36 -0400
Message-ID: <20081022171235.5152.7645.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:28333 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbYJVRNQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2008 13:13:16 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Linux NFS server can be started via a user-space write to
/proc/fs/nfs/threads or to /proc/fs/nfs/portlist.  In the first case,
all default listeners are started (both UDP and TCP).  In the second,
a listener is started only for one specified transport.

The NFS server has to make sure lockd stays up until the last listener
transport goes away.  To support both start-up interfaces, it should
do one lockd_up() for each NFSD listener.

The nfsd_init_socks() function used to do one lockd_up() call for each
svc_create_xprt().  Recently commit
26a414092353590ceaa5955bcb53f863d6ea7549 mistakenly changed
nfsd_init_socks() to do only one lockd_up() call even though it still
does two svc_create_xprt() calls.

The end result is a lockd_down() BUG during NFSD shutdown processing
because nfsd_last_threads() does a lockd_down() call for each entry
on the sv_permsocks list, but the start-up code doesn't do a matching
number of lockd_up() calls.

Add a second lockd_up() in nfsd_init_socks() to make sure the number
of lockd_up() calls matches the number of entries on the NFS servers's
sv_permsocks list.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfssvc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 59eeb46..07e4f5d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -249,6 +249,10 @@ static int nfsd_init_socks(int port)
 	if (error < 0)
 		return error;
 
+	error = lockd_up();
+	if (error < 0)
+		return error;
+
 	error = svc_create_xprt(nfsd_serv, "tcp", port,
 					SVC_SOCK_DEFAULTS);
 	if (error < 0)

