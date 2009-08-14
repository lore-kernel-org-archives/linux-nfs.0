From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 5/6] nfsd: add support for NFSv4 callbacks over IPv6
Date: Fri, 14 Aug 2009 12:57:58 -0400
Message-ID: <1250269079-14629-6-git-send-email-jlayton@redhat.com>
References: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: bfields@fieldses.org, chuck.lever@oracle.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1250269079-14629-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

The framework to add this is all in place. Now, add the code to allow
support for establishing a callback channel on an IPv6 socket.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4state.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 96a7423..9ec0ca1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -901,9 +901,16 @@ static void
 gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 {
 	struct nfs4_cb_conn *cb = &clp->cl_cb_conn;
-
-	/* Currently, we only support tcp for the callback channel */
-	if ((se->se_callback_netid_len != 3) || memcmp((char *)se->se_callback_netid_val, "tcp", 3))
+	unsigned short expected_family;
+
+	/* Currently, we only support tcp and tcp6 for the callback channel */
+	if (se->se_callback_netid_len == 3 &&
+	    !memcmp(se->se_callback_netid_val, "tcp", 3))
+		expected_family = AF_INET;
+	else if (se->se_callback_netid_len == 4 &&
+		 !memcmp(se->se_callback_netid_val, "tcp6", 4))
+		expected_family = AF_INET6;
+	else
 		goto out_err;
 
 	cb->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
@@ -911,7 +918,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se)
 					    (struct sockaddr *) &cb->cb_addr,
 					    sizeof(cb->cb_addr));
 
-	if (!cb->cb_addrlen || cb->cb_addr.ss_family != AF_INET)
+	if (!cb->cb_addrlen || cb->cb_addr.ss_family != expected_family)
 		goto out_err;
 
 	cb->cb_minorversion = 0;
-- 
1.6.0.6
