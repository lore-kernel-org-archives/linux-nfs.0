From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/23] NFSD: If port value written to /proc/fs/nfsd/portlist
	is invalid, return EINVAL
Date: Wed, 18 Mar 2009 20:45:51 -0400
Message-ID: <20090319004550.32404.61472.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:65487 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348AbZCSAqZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:46:25 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure port value read from user space by write_ports is valid before
passing it to svc_find_xprt().  If it wasn't, the writer would get ENOENT
instead of EINVAL.

Noticed-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 3d93b20..5a936c1 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -938,6 +938,8 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 		char transport[16];
 		int port;
 		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
+			if (port < 1 || port > 65535)
+				return -EINVAL;
 			err = nfsd_create_serv();
 			if (!err) {
 				err = svc_create_xprt(nfsd_serv,
@@ -960,7 +962,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 		char transport[16];
 		int port;
 		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
-			if (port == 0)
+			if (port < 1 || port > 65535)
 				return -EINVAL;
 			if (nfsd_serv) {
 				xprt = svc_find_xprt(nfsd_serv, transport,

