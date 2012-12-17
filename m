Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:20446 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052Ab2LQRV7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2012 12:21:59 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: continue run over clients list on PipeFS event
 instead of break
Date: Mon, 17 Dec 2012 17:21:57 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91194E28F@sacexcmbx05-prd.hq.netapp.com>
References: <20121217171852.26922.37774.stgit@localhost.localdomain>
In-Reply-To: <20121217171852.26922.37774.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-12-17 at 20:18 +-0300, Stanislav Kinsbursky wrote:
+AD4- There are SUNRPC clients, which program doesn't have pipe+AF8-dir+AF8-name. These
+AD4- clients can be skipped on PipeFS events, because nothing have to be created or
+AD4- destroyed. But instead of breaking in case of such a client was found, search
+AD4- for suitable client over clients list have to be continued. Otherwise some
+AD4- clients could not be covered by PipeFS event handler.
+AD4- 
+AD4- Signed-off-by: Stanislav Kinsbursky +ADw-skinsbursky+AEA-parallels.com+AD4-
+AD4- Cc: stable+AEA-vger.kernel.org +AFsAPgA9- v3.4+AF0-
+AD4- ---
+AD4-  net/sunrpc/clnt.c +AHw-    2 +--
+AD4-  1 files changed, 1 insertions(+-), 1 deletions(-)
+AD4- 
+AD4- diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
+AD4- index cdc7564..10b18b2 100644
+AD4- --- a/net/sunrpc/clnt.c
+AD4- +-+-+- b/net/sunrpc/clnt.c
+AD4- +AEAAQA- -234,7 +-234,7 +AEAAQA- static struct rpc+AF8-clnt +ACo-rpc+AF8-get+AF8-client+AF8-for+AF8-event(struct net +ACo-net, int event)
+AD4-  	spin+AF8-lock(+ACY-sn-+AD4-rpc+AF8-client+AF8-lock)+ADs-
+AD4-  	list+AF8-for+AF8-each+AF8-entry(clnt, +ACY-sn-+AD4-all+AF8-clients, cl+AF8-clients) +AHs-
+AD4-  		if (clnt-+AD4-cl+AF8-program-+AD4-pipe+AF8-dir+AF8-name +AD0APQ- NULL)
+AD4- -			break+ADs-
+AD4- +-			continue+ADs-
+AD4-  		if (rpc+AF8-clnt+AF8-skip+AF8-event(clnt, event))
+AD4-  			continue+ADs-
+AD4-  		if (atomic+AF8-inc+AF8-not+AF8-zero(+ACY-clnt-+AD4-cl+AF8-count) +AD0APQ- 0)
+AD4- 

Thanks Stanislav+ACE- Applied.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
