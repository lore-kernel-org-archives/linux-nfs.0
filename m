From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/3] NFS Bugfixes for 2.6.20-rc5
Date: Wed, 24 Jan 2007 11:53:07 -0800
Message-ID: <20070124195307.21259.64156.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sds@tycho.nsa.gov, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9oD3-0004gw-E2
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:55:05 -0800
Received: from dsl081-065-125.sfo1.dsl.speakeasy.net ([64.81.65.125]
	helo=lade.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H9oD1-0002Xg-5i
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:55:04 -0800
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

The following series fixes 3 bugs in the 2.6.20-rc5 NFS client.

 - Fix Oops in rpc_call_sync()
 - Fix races in nfs_revalidate_mapping()
 - Ensure we support selinux xattrs

Cheers,
  Trond

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
