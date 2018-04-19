Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:42972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752666AbeDSNda (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:33:30 -0400
Subject: [PATCH 20/24] afs: Fix server record deletion [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:33:28 +0100
Message-ID: <152414480842.23902.4728171251942557710.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AFS server records get removed from the net->fs_servers tree when they're
deleted, but not from the net->fs_addresses{4,6} lists, which can lead to
an oops in afs_find_server() when a server record has been removed, for
instance during rmmod.

Fix this by deleting the record from the by-address lists before posting it
for RCU destruction.

The reason this hasn't been noticed before is that the fileserver keeps
probing the local cache manager, thereby keeping the service record alive,
so the oops would only happen when a fileserver eventually gets bored and
stops pinging or if the module gets rmmod'd and a call comes in from the
fileserver during the window between the server records being destroyed and
the socket being closed.

The oops looks something like:

BUG: unable to handle kernel NULL pointer dereference at 000000000000001c
...
Workqueue: kafsd afs_process_async_call [kafs]
RIP: 0010:afs_find_server+0x271/0x36f [kafs]
...
Call Trace:
 ? worker_thread+0x230/0x2ac
 ? worker_thread+0x230/0x2ac
 afs_deliver_cb_init_call_back_state3+0x1f2/0x21f [kafs]
 afs_deliver_to_call+0x1ee/0x5e8 [kafs]
 ? worker_thread+0x230/0x2ac
 afs_process_async_call+0x5b/0xd0 [kafs]
 process_one_work+0x2c2/0x504
 ? worker_thread+0x230/0x2ac
 worker_thread+0x1d4/0x2ac
 ? rescuer_thread+0x29b/0x29b
 kthread+0x11f/0x127
 ? kthread_create_on_node+0x3f/0x3f
 ret_from_fork+0x24/0x30

Fixes: d2ddc776a458 ("afs: Overhaul volume and server record caching and fileserver rotation")
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/server.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/afs/server.c b/fs/afs/server.c
index e23be63998a8..629c74986cff 100644
--- a/fs/afs/server.c
+++ b/fs/afs/server.c
@@ -428,8 +428,15 @@ static void afs_gc_servers(struct afs_net *net, struct afs_server *gc_list)
 		}
 		write_sequnlock(&net->fs_lock);
 
-		if (deleted)
+		if (deleted) {
+			write_seqlock(&net->fs_addr_lock);
+			if (!hlist_unhashed(&server->addr4_link))
+				hlist_del_rcu(&server->addr4_link);
+			if (!hlist_unhashed(&server->addr6_link))
+				hlist_del_rcu(&server->addr6_link);
+			write_sequnlock(&net->fs_addr_lock);
 			afs_destroy_server(net, server);
+		}
 	}
 }
 

