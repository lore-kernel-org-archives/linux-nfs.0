Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:23540 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757359Ab1LWOyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Dec 2011 09:54:09 -0500
Subject: [PATCH 2/3] Lockd: don't mark freshly created sockets with XPT_CHNGBUF
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 23 Dec 2011 18:53:41 +0300
Message-ID: <20111223145341.847.84279.stgit@localhost6.localdomain6>
In-Reply-To: <20111223145145.847.46221.stgit@localhost6.localdomain6>
References: <20111223145145.847.46221.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch. XPT_CHNGBUF bit is set on UDP socket creation. Calling
svc_sock_update_bufs from lockd after is redundant.
Below is Lockd UDP sockets creating call trace:

lockd_up {

make_socks
create_lockd_family
create_lockd_listener
svc_create_xprt
__svc_xpo_create
svc_udp_create
svc_create_socket
svc_setup_socket
svc_udp_init (raise XPT_CHNGBUF)

....

svc_sock_update_bufs (raise XPT_CHNGBUF again)

....

}

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index ff379ff..55fea92 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -292,7 +292,6 @@ int lockd_up(void)
 		goto destroy_and_out;
 	}
 
-	svc_sock_update_bufs(serv);
 	serv->sv_maxconn = nlm_max_connections;
 
 	nlmsvc_task = kthread_run(lockd, nlmsvc_rqst, serv->sv_name);

