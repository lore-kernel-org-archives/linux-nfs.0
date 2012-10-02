Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45410 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754310Ab2JBKSy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 06:18:54 -0400
Subject: [PATCH 4/5] nfs: include nfs4_fh.h in nfs4sysctl.c
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 02 Oct 2012 14:19:09 +0400
Message-ID: <20121002101909.15507.13942.stgit@localhost.localdomain>
In-Reply-To: <20121002101649.15507.50466.stgit@localhost.localdomain>
References: <20121002101649.15507.50466.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sparse warnings:
fs/nfs/nfs4sysctl.c:56:5: warning: symbol 'nfs4_register_sysctl' was not
declared. Should it be static?
fs/nfs/nfs4sysctl.c:64:6: warning: symbol 'nfs4_unregister_sysctl' was not
declared. Should it be static?

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/nfs4sysctl.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4sysctl.c b/fs/nfs/nfs4sysctl.c
index 5729bc8..2628d92 100644
--- a/fs/nfs/nfs4sysctl.c
+++ b/fs/nfs/nfs4sysctl.c
@@ -9,6 +9,7 @@
 #include <linux/nfs_idmap.h>
 #include <linux/nfs_fs.h>
 
+#include "nfs4_fs.h"
 #include "callback.h"
 
 static const int nfs_set_port_min = 0;

