Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:45475 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbaD3Cqr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:46:47 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 6/9] nfsd: pass net to __write_ports() and down
Date: Wed, 30 Apr 2014 10:43:41 +0800
Message-ID: <1398825824-6360-7-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit 081603520b25f7b35ef63a363376a17c36ef74ed upstream.

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4:
 - adjust context
 - add net_ns parameter to __write_ports_delxprt()]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfsctl.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f58e0f9..1d74af2 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -650,11 +650,10 @@ static ssize_t __write_ports_names(char *buf)
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
@@ -698,12 +697,11 @@ static ssize_t __write_ports_delfd(char *buf)
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
 
 	if (sscanf(buf, "%15s %4u", transport, &port) != 2)
 		return -EINVAL;
@@ -743,7 +741,7 @@ out_err:
  * A transport listener is removed by writing a "-", it's transport
  * name, and it's port number.
  */
-static ssize_t __write_ports_delxprt(char *buf)
+static ssize_t __write_ports_delxprt(char *buf, struct net *net)
 {
 	struct svc_xprt *xprt;
 	char transport[16];
@@ -755,7 +753,7 @@ static ssize_t __write_ports_delxprt(char *buf)
 	if (port < 1 || port > USHRT_MAX || nfsd_serv == NULL)
 		return -EINVAL;
 
-	xprt = svc_find_xprt(nfsd_serv, transport, &init_net, AF_UNSPEC, port);
+	xprt = svc_find_xprt(nfsd_serv, transport, net, AF_UNSPEC, port);
 	if (xprt == NULL)
 		return -ENOTCONN;
 
@@ -764,22 +762,23 @@ static ssize_t __write_ports_delxprt(char *buf)
 	return 0;
 }
 
-static ssize_t __write_ports(struct file *file, char *buf, size_t size)
+static ssize_t __write_ports(struct file *file, char *buf, size_t size,
+				struct net *net)
 {
 	if (size == 0)
 		return __write_ports_names(buf);
 
 	if (isdigit(buf[0]))
-		return __write_ports_addfd(buf);
+		return __write_ports_addfd(buf, net);
 
 	if (buf[0] == '-' && isdigit(buf[1]))
 		return __write_ports_delfd(buf);
 
 	if (isalpha(buf[0]))
-		return __write_ports_addxprt(buf);
+		return __write_ports_addxprt(buf, net);
 
 	if (buf[0] == '-' && isalpha(buf[1]))
-		return __write_ports_delxprt(buf);
+		return __write_ports_delxprt(buf, net);
 
 	return -EINVAL;
 }
@@ -858,9 +857,10 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
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
-- 
1.8.2.2


