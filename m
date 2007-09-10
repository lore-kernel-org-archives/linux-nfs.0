From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 14/19] NFS - print accurate transport protocol
Date: Mon, 10 Sep 2007 13:48:47 -0400
Message-ID: <EXNANE01jYKtWfN3vSA000004bd@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUncJ-0003en-D3
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:04:11 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUncN-00087n-Px
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 11:04:16 -0700
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com
	[10.57.156.154])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AI4ACE026951
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 11:04:10 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

NFS - print accurate transport protocol

Use the per-transport strings to display the transport protocol accurately.

Signed-off-by: Tom Talpey <tmt@netapp.com>

---

 fs/nfs/super.c |   16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

Index: kernel/fs/nfs/super.c
===================================================================
--- kernel.orig/fs/nfs/super.c
+++ kernel/fs/nfs/super.c
@@ -431,8 +431,6 @@ static void nfs_show_mount_options(struc
 	};
 	const struct proc_nfs_info *nfs_infop;
 	struct nfs_client *clp = nfss->nfs_client;
-	char buf[12];
-	const char *proto;
 
 	seq_printf(m, ",vers=%d", clp->rpc_ops->version);
 	seq_printf(m, ",rsize=%d", nfss->rsize);
@@ -451,18 +449,8 @@ static void nfs_show_mount_options(struc
 		else
 			seq_puts(m, nfs_infop->nostr);
 	}
-	switch (nfss->client->cl_xprt->prot) {
-		case IPPROTO_TCP:
-			proto = "tcp";
-			break;
-		case IPPROTO_UDP:
-			proto = "udp";
-			break;
-		default:
-			snprintf(buf, sizeof(buf), "%u", nfss->client->cl_xprt->prot);
-			proto = buf;
-	}
-	seq_printf(m, ",proto=%s", proto);
+	seq_printf(m, ",proto=%s",
+		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_PROTO));
 	seq_printf(m, ",timeo=%lu", 10U * clp->retrans_timeo / HZ);
 	seq_printf(m, ",retrans=%u", clp->retrans_count);
 	seq_printf(m, ",sec=%s", nfs_pseudoflavour_to_name(nfss->client->cl_auth->au_flavor));

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
