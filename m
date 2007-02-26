From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 09/11] nfs-utils: mount: Fixed mounts to multi-home
	servers
Date: Mon, 26 Feb 2007 06:18:54 -0500
Message-ID: <45E2C21E.9030501@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080001090407020407080103"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLdqD-0000Qs-KM
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:16:25 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLdqF-0006ed-DZ
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 03:16:27 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBGQ2g001206
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:26 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l1QBGL7x005834
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:21 -0500
Received: from [10.13.248.66] (vpn-248-66.boston.redhat.com [10.13.248.66])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	l1QBGJG4025623
	for <nfs@lists.sourceforge.net>; Mon, 26 Feb 2007 06:16:19 -0500
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------080001090407020407080103
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------080001090407020407080103
Content-Type: text/x-patch;
 name="patch-09.dif"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-09.dif"

commit 253c6b866a1ed4678c30131a41ef96821bae9d5f
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Feb 24 16:08:22 2007 -0500

    Doing a connect on UDP sockets causes the Linux network
    stack to reject UDP patches from multi-home server with
    nic on the same subnet which caused mounts to hang.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/conn.c b/support/nfs/conn.c
index 89f7676..06afcc4 100644
--- a/support/nfs/conn.c
+++ b/support/nfs/conn.c
@@ -98,7 +98,7 @@ int get_socket(struct sockaddr_in *saddr, u_int p_prot, int resvp)
 			return RPC_ANYSOCK;
 		}
 	}
-	if (type == SOCK_STREAM || type == SOCK_DGRAM) {
+	if (type == SOCK_STREAM) {
 		cc = connect(so, (struct sockaddr *)saddr, namelen);
 		if (cc < 0) {
 			rpc_createerr.cf_stat = RPC_SYSTEMERROR;

--------------080001090407020407080103
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------080001090407020407080103
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080001090407020407080103--
