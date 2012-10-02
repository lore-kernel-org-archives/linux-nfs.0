Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4961 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588Ab2JBKSo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 06:18:44 -0400
Subject: [PATCH 1/5] nfs: include NFSv4 header in netns.h
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 02 Oct 2012 14:18:54 +0400
Message-ID: <20121002101854.15507.84959.stgit@localhost.localdomain>
In-Reply-To: <20121002101649.15507.50466.stgit@localhost.localdomain>
References: <20121002101649.15507.50466.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Build error:
fs/nfs/netns.h:27:15: error: 'NFS4_MAX_MINOR_VERSION' undeclared here (not in
a function)

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/netns.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index b9c7f9b..8ee1fab 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -5,6 +5,7 @@
 #ifndef __NFS_NETNS_H__
 #define __NFS_NETNS_H__
 
+#include <linux/nfs4.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 

