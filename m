Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:37998 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753644AbeFDOxc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 10:53:32 -0400
Received: by mail-io0-f170.google.com with SMTP id l19-v6so28586150ioj.5
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 07:53:32 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id e28-v6sm180768itd.35.2018.06.04.07.53.30
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 07:53:30 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id w54ErTTL004626
        for <linux-nfs@vger.kernel.org>; Mon, 4 Jun 2018 14:53:29 GMT
Subject: [PATCH v1 1/2] NFSv4.0: Remove cl_ipaddr from non-UCS client ID
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 04 Jun 2018 10:53:29 -0400
Message-ID: <20180604145329.11877.56539.stgit@manet.1015granger.net>
In-Reply-To: <20180604144154.11877.19298.stgit@manet.1015granger.net>
References: <20180604144154.11877.19298.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is possible for two distinct clients to have the same cl_ipaddr:

 - if the client admin disables callback with clientaddr=0.0.0.0 on
   more than one client

 - if two clients behind separate NATs use the same private subnet
   number

 - if the client admin specifies the same address via clientaddr=
   mount option (pointing the server at the same NAT box, for
   example)

Because of the way the Linux NFSv4.0 client constructs its client
ID string by default, such clients could interfere with each others'
lease state when mounting the same server:

	scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
		clp->cl_ipaddr,
		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
		rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO));

cl_ipaddr is set to the value of the clientaddr= mount option. Two
clients whose addresses are 192.168.3.77 that mount the same server
(whose public IP address is, say, 3.4.5.6) would both generate the
same client ID string when sending a SETCLIENTID:

  Linux NFSv4.0 192.168.3.77/3.4.5.6 tcp

and thus the server would not be able to distinguish the clients'
leases. If both clients are using AUTH_SYS when sending SETCLIENTID
then the server could possibly permit the two clients to interfere
with or purge each others' leases.

To better ensure that Linux's NFSv4.0 client ID strings are distinct
in these cases, remove cl_ipaddr from the client ID string and
replace it with something more likely to be unique. Note that the
replacement looks a lot like the uniform client ID string.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b71757e..fa6f9a2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5591,13 +5591,16 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 		return 0;
 
 	rcu_read_lock();
-	len = 14 + strlen(clp->cl_ipaddr) + 1 +
+	len = 14 +
+		strlen(clp->cl_rpcclient->cl_nodename) +
+		1 +
 		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR)) +
 		1 +
 		strlen(rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO)) +
 		1;
 	rcu_read_unlock();
-
+	if (nfs4_client_id_uniquifier[0] != '\0')
+		len += strlen(nfs4_client_id_uniquifier) + 1;
 	if (len > NFS4_OPAQUE_LIMIT + 1)
 		return -EINVAL;
 
@@ -5611,10 +5614,21 @@ static void nfs4_init_boot_verifier(const struct nfs_client *clp,
 		return -ENOMEM;
 
 	rcu_read_lock();
-	scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
-			clp->cl_ipaddr,
-			rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR),
-			rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_PROTO));
+	if (nfs4_client_id_uniquifier[0] != '\0')
+		scnprintf(str, len, "Linux NFSv4.0 %s/%s/%s %s",
+			  clp->cl_rpcclient->cl_nodename,
+			  nfs4_client_id_uniquifier,
+			  rpc_peeraddr2str(clp->cl_rpcclient,
+					   RPC_DISPLAY_ADDR),
+			  rpc_peeraddr2str(clp->cl_rpcclient,
+					   RPC_DISPLAY_PROTO));
+	else
+		scnprintf(str, len, "Linux NFSv4.0 %s/%s %s",
+			  clp->cl_rpcclient->cl_nodename,
+			  rpc_peeraddr2str(clp->cl_rpcclient,
+					   RPC_DISPLAY_ADDR),
+			  rpc_peeraddr2str(clp->cl_rpcclient,
+					   RPC_DISPLAY_PROTO));
 	rcu_read_unlock();
 
 	clp->cl_owner_id = str;

