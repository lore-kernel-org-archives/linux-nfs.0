Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:53534 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932916AbaLDRwX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2014 12:52:23 -0500
From: Pieter Smith <pieter@boesman.nl>
To: linux-kernel@vger.kernel.org
Cc: Josh Triplett <josh@joshtriplett.org>, Pieter Smith <pieter@boesman.nl>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bertrand Jacquin <beber@meleeweb.net>,
        Catalina Mocanu <catalina.mocanu@gmail.com>,
        Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Fabian Frederick <fabf@skynet.be>,
        fuse-devel@lists.sourceforge.net (open list:FUSE: FILESYSTEM...),
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Hugh Dickins <hughd@google.com>, Iulia Manda <iulia.manda21@gmail.com>,
        Jan Beulich <JBeulich@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-api@vger.kernel.org (open list:ABI/API),
        linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org (open list:KERNEL NFSD, SUNR...),
        "Luis R. Rodriguez" <mcgrof@suse.com>,
        Matt Turner <mattst88@gmail.com>, Mel Gorman <mgorman@suse.de>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        Oleg Nesterov <oleg@redhat.com>,
        Paul Durrant <Paul.Durrant@citrix.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Peter Foley <pefoley2@pefoley.com>, Thomas Graf <tgraf@suug.ch>,
        Tom Herbert <therbert@google.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Willem de Bruijn <willemb@google.com>,
        Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>,
        =?UTF-8?q?=E8=94=A1=E6=AD=A3=E9=BE=99?= <zhenglong.cai@cs2c.com.cn>
Subject: [PATCH v6 6/7] fs/nfsd: support compiling out splice
Date: Thu,  4 Dec 2014 18:50:54 +0100
Message-Id: <1417715473-24110-7-git-send-email-pieter@boesman.nl>
In-Reply-To: <1417715473-24110-1-git-send-email-pieter@boesman.nl>
References: <1417715473-24110-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The goal of the larger patch set is to completely compile out fs/splice, and
as a result, splice support for all file-systems. This patch ensures that
fs/nfsd falls back to non-splice fs support when CONFIG_SYSCALL_SPLICE is
undefined.

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 net/sunrpc/svc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ca8a795..6cacc37 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1084,7 +1084,7 @@ svc_process_common(struct svc_rqst *rqstp, struct kvec *argv, struct kvec *resv)
 		goto err_short_len;
 
 	/* Will be turned off only in gss privacy case: */
-	rqstp->rq_splice_ok = true;
+	rqstp->rq_splice_ok = IS_ENABLED(CONFIG_SPLICE_SYSCALL);
 	/* Will be turned off only when NFSv4 Sessions are used */
 	rqstp->rq_usedeferral = true;
 	rqstp->rq_dropme = false;
-- 
2.1.0

