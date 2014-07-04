Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:57461 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031184AbaGDWVI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jul 2014 18:21:08 -0400
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
        Mateusz Guzik <mguzik@redhat.com>, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 3.14 35/59] NFS: populate ->net in mount data when remounting
Date: Fri,  4 Jul 2014 15:19:24 -0700
Message-Id: <20140704221541.230625184@linuxfoundation.org>
In-Reply-To: <20140704221539.544876024@linuxfoundation.org>
References: <20140704221539.544876024@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

3.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Mateusz Guzik <mguzik@redhat.com>

commit a914722f333b3359d2f4f12919380a334176bb89 upstream.

Otherwise the kernel oopses when remounting with IPv6 server because
net is dereferenced in dev_get_by_name.

Use net ns of current thread so that dev_get_by_name does not operate on
foreign ns. Changing the address is prohibited anyway so this should not
affect anything.

Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 fs/nfs/super.c |    1 +
 1 file changed, 1 insertion(+)

--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2246,6 +2246,7 @@ nfs_remount(struct super_block *sb, int
 	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
 	data->version = nfsvers;
 	data->minorversion = nfss->nfs_client->cl_minorversion;
+	data->net = current->nsproxy->net_ns;
 	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		data->nfs_server.addrlen);
 


