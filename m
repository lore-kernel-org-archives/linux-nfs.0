Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:5218 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab2LJJTC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 04:19:02 -0500
Subject: [PATCH 7/7] nfsd: pass net to __write_ports() and down
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 10 Dec 2012 12:19:35 +0300
Message-ID: <20121210091935.8855.16169.stgit@localhost.localdomain>
In-Reply-To: <20121210091832.8855.26672.stgit@localhost.localdomain>
References: <20121210091832.8855.26672.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfsctl.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 58f0ae4..8536100 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -657,11 +657,10 @@ static ssize_t __write_ports_names(char *buf)
  * a socket of a supported family/protocol, and we use it as an
  * nfsd listener.
  */
-static ssize_t __write_ports_addfd(char *buf)
+static ssize_t __write_ports_addfd(char *buf, struct net *net)
 {
 	char *mesg = buf;
 	int fd, err;
-	struct net *net = &init_net;
 
 	err = get_int(&mesg, &fd);
 	if (err != 0 || fd < 0)
@@ -686,12 +685,11 @@ static ssize_t __write_ports_addfd(char *buf)
  * A transport listener is added by writing it's transport name and
  * a port number.
  */
-static ssize_t __write_ports_addxprt(char *buf)
+static ssize_t __write_ports_addxprt(char *buf, struct net *net)
 {
 	char transport[16];
 	struct svc_xprt *xprt;
 	int port, err;
-	struct net *net = &init_net;
 
 	if (sscanf(buf, "%15s %5u", transport, &port) != 2)
 		return -EINVAL;
@@ -727,16 +725,17 @@ out_err:
 	return err;
 }
 
-static ssize_t __write_ports(struct file *file, char *buf, size_t size)
+static ssize_t __write_ports(struct file *file, char *buf, size_t size,
+			     struct net *net)
 {
 	if (size == 0)
 		return __write_ports_names(buf);
 
 	if (isdigit(buf[0]))
-		return __write_ports_addfd(buf);
+		return __write_ports_addfd(buf, net);
 
 	if (isalpha(buf[0]))
-		return __write_ports_addxprt(buf);
+		return __write_ports_addxprt(buf, net);
 
 	return -EINVAL;
 }
@@ -787,9 +786,10 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 static ssize_t write_ports(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
+	struct net *net = &init_net;
 
 	mutex_lock(&nfsd_mutex);
-	rv = __write_ports(file, buf, size);
+	rv = __write_ports(file, buf, size, net);
 	mutex_unlock(&nfsd_mutex);
 	return rv;
 }

