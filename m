From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 35/38] knfsd: Support adding transports by writing portlist file
Date: Thu, 29 Nov 2007 16:41:07 -0600
Message-ID: <20071129224107.14563.99017.stgit@dell3.ogc.int>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields-ag9A2Eb6PFsgsBAKwltoeQ@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:48890 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934188AbXK2XDn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:03:43 -0500
In-Reply-To: <20071129223917.14563.77633.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Update the write handler for the portlist file to allow creating new
listening endpoints on a transport. The general form of the string is:

<transport_name><space><port number>

For example:

tcp 2049

This is intended to support the creation of a listening endpoint for
RDMA transports without adding #ifdef code to the nfssvc.c file.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 77dc989..1f998c0 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -554,6 +554,22 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 		kfree(toclose);
 		return len;
 	}
+	/*
+	 * Add a transport listener by writing it's transport name
+	 */
+	if (isalnum(buf[0])) {
+		int err;
+		char transport[16];
+		int port;
+		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
+			err = nfsd_create_serv();
+			if (!err)
+				err = svc_create_xprt(nfsd_serv,
+						      transport, port,
+						      SVC_SOCK_ANONYMOUS);
+			return err < 0 ? err : 0;
+		}
+	}
 	return -EINVAL;
 }
 
