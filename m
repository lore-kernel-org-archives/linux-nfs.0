From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/23] NFSD: Note an additional requirement when passing TCP
	sockets to portlist
Date: Thu, 05 Mar 2009 16:32:23 -0500
Message-ID: <20090305213223.21342.83475.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:35750 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754043AbZCEVc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:32:57 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

User space must call listen(3) on SOCK_STREAM sockets passed into
/proc/fs/nfsd/portlist, otherwise that listener is ignored.  Document
this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0d3efa4..441fbfd 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1025,7 +1025,9 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
  *			buf:		C string containing an unsigned
  *					integer value representing a bound
  *					but unconnected socket that is to be
- *					used as an NFSD listener
+ *					used as an NFSD listener; listen(3)
+ *					must be called for a SOCK_STREAM
+ *					socket, otherwise it is ignored
  *			size:		non-zero length of C string in @buf
  * Output:
  *	On success:	NFS service is started;

