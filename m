From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/19] NFSD: Note an additional requirement when passing TCP
	sockets to portlist
Date: Thu, 23 Apr 2009 19:32:03 -0400
Message-ID: <20090423233202.17283.89678.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64816 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287AbZDWXc1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:27 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index b6a847f..d491fa9 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1061,7 +1061,9 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
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

