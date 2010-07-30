From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 9/9] sunrpc: auth_gss: misused copy_to_user() return value
Date: Fri, 30 Jul 2010 15:10:34 +0400
Message-ID: <1280488234-21223-1-git-send-email-segooon@gmail.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Layton <jlayton@redhat.com>,
	Steve Dickson <steved@redhat.com>,
	Suresh Jayaraman <sjayaraman@suse.de>,
	Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

copy_to_user() returns nonzero value on error, this value may be any
value between 0 and requested count, not only requested count.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8da2a0e..232d7dc 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -610,7 +610,7 @@ gss_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
 	unsigned long left;
 
 	left = copy_to_user(dst, data, mlen);
-	if (left == mlen) {
+	if (left)
 		msg->errno = -EFAULT;
 		return -EFAULT;
 	}
-- 
1.7.0.4

