Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:60367 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755012Ab0DAWss (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 18:48:48 -0400
Message-ID: <4BB522CF.60503@opengridcomputing.com>
Date: Thu, 01 Apr 2010 17:48:47 -0500
From: Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Subject: [PATCH,RFC] nfsd: Make INET6 transport creation failure an informational
 message
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce/Chuck,

RDMA Transports are currently broken in 2.6.34 because they don't have a 
V4ONLY setsockopt. So what happens is that when write_ports attempts to 
create the PF_INET6 transport it fails because the port is already in 
use. There is discussion on linux-rdma about how to fix this, but in the 
interim and perhaps indefinitely, I propose the following:

Tom

nfsd: Make INET6 transport creation failure an informational message

The write_ports code will fail both the INET4 and INET6 transport creation if
the transport returns an error when PF_INET6 is specified. Some transports
that do not support INET6 return an error other than EAFNOSUPPORT. We should
allow communication on INET4 even if INET6 is not yet supported or fails
for some reason.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 fs/nfsd/nfsctl.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0f0e77f..934b624 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1008,8 +1008,10 @@ static ssize_t __write_ports_addxprt(char *buf)
 
 	err = svc_create_xprt(nfsd_serv, transport,
 				PF_INET6, port, SVC_SOCK_ANONYMOUS);
-	if (err < 0 && err != -EAFNOSUPPORT)
-		goto out_close;
+	if (err < 0)
+		printk(KERN_INFO "nfsd: Error creating PF_INET6 listener "
+		       "for transport '%s'\n", transport);
+
 	return 0;
 out_close:
 	xprt = svc_find_xprt(nfsd_serv, transport, PF_INET, port);

