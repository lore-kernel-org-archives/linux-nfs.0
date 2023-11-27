Authentication-Results: smtp.subspace.kernel.org; dkim=none
X-Greylist: delayed 145 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Mon, 27 Nov 2023 07:42:41 PST
Received: from r3-25.sinamail.sina.com.cn (r3-25.sinamail.sina.com.cn [202.108.3.25])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5FE2992
	for <linux-nfs@vger.kernel.org>; Mon, 27 Nov 2023 07:42:41 -0800 (PST)
X-SMAIL-HELO: localhost.localdomain
Received: from unknown (HELO localhost.localdomain)([120.245.112.246])
	by sina.cn (172.16.97.23) with ESMTP
	id 6564B85B000094F0; Mon, 27 Nov 2023 23:40:13 +0800 (CST)
X-Sender: thfeathers@sina.cn
X-Auth-ID: thfeathers@sina.cn
Authentication-Results: sina.cn;
	 spf=none smtp.mailfrom=thfeathers@sina.cn;
	 dkim=none header.i=none;
	 dmarc=none action=none header.from=thfeathers@sina.cn
X-SMAIL-MID: 11568731457678
X-SMAIL-UIID: 3FA53262185F4214A4EBD3FD776C25B1-20231127-234013-1
From: jsq <thfeathers@sina.cn>
To: chuck.lever@oracle.com,
	jlayton@kernel.org
Cc: neilb@suse.de,
	kolga@netapp.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org,
	jsq <thfeathers@sina.cn>
Subject: [PATCH] SUNRPC: _xprt_switch_find_current_entry return xprt with condition find_active
Date: Mon, 27 Nov 2023 23:39:59 +0800
Message-ID: <20231127153959.2067-1-thfeathers@sina.cn>
X-Mailer: git-send-email 2.43.0.windows.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

current function always return a active xprt or NULL no matter what find_active
---
 net/sunrpc/xprtmultipath.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index 701250b305db..94f3b5f444a1 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -283,8 +283,7 @@ struct rpc_xprt *_xprt_switch_find_current_entry(struct list_head *head,
 	list_for_each_entry_rcu(pos, head, xprt_switch) {
 		if (cur == pos)
 			found = true;
-		if (found && ((find_active && xprt_is_active(pos)) ||
-			      (!find_active && xprt_is_active(pos))))
+		if (found && (find_active == xprt_is_active(pos)))
 			return pos;
 	}
 	return NULL;
-- 
2.43.0.windows.1

