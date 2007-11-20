From: Joe Perches <joe@perches.com>
Subject: [NFS] [PATCH 56/59] net/sunrpc: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:43 -0800
Message-ID: <4a6aeee33cf9dc9a3e329e73b6bc584b7650ed51.1195454436.git.joe__29991.7693868794$1195523857$gmane$org@perches.com>
References: 1234567 <1195523627-15389-1-git-send-email-joe@perches.com>
	<1195523627-15389-2-git-send-email-joe@perches.com>
	<1195523627-15389-3-git-send-email-joe@perches.com>
	<1195523627-15389-4-git-send-email-joe@perches.com>
	<1195523627-15389-5-git-send-email-joe@perches.com>
	<1195523627-15389-6-git-send-email-joe@perches.com>
	<1195523627-15389-7-git-send-email-joe@perches.com>
	<1195523627-15389-8-git-send-email-joe@perches.com>
	<1195523627-15389-9-git-send-email-joe@perches.com>
	<1195523627-15389-10-git-send-email-joe@perches.com>
	<1195523627-15389-11-git-send-email-joe@perches.com>
	<1195523627-15389-12-git-send-email-joe@perches.com>
	<1195523627-15389-13-git-send-email-joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Networking Team <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuIJn-0002IN-T0
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 17:54:28 -0800
Received: from dsl022.labridge.com ([206.117.136.22] helo=perches.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuIJs-0003EA-J6
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 17:54:34 -0800
In-Reply-To: <1195523627-15389-13-git-send-email-joe@perches.com>
Message-Id: <4a6aeee33cf9dc9a3e329e73b6bc584b7650ed51.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 53995af..22906b8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -967,7 +967,7 @@ gss_validate(struct rpc_task *task, __be32 *p)
 	if (maj_stat == GSS_S_CONTEXT_EXPIRED)
 		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	if (maj_stat) {
-		dprintk("RPC: %5u gss_validate: gss_verify_mic returned"
+		dprintk("RPC: %5u gss_validate: gss_verify_mic returned "
 				"error 0x%08x\n", task->tk_pid, maj_stat);
 		goto out_bad;
 	}
-- 
1.5.3.5.652.gf192c


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

