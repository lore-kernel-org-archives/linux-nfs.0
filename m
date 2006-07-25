From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 9] knfsd: Introduction
Date: Tue, 25 Jul 2006 11:54:21 +1000
Message-ID: <20060725114207.21779.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5C8W-0004YG-Cq
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:04 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5C8V-0003tZ-AT
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 18:55:04 -0700
To: Andrew Morton <akpm@osdl.org>
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

Following are 9 patches for knfsd in 2.6-18-rc1-mm2
They should be held for 2.6.19.

They comprise
 3 trivial cleanups from Greg Banks
 Some fixes/cleanups to socket/version selection code.
 Adding a 'portlist' file to the 'nfsd' filesystem.
  This can be used to open and close sockets used by the nfs server.
  New sockets are created in user-space and passed down by writing
   an 'fd' number.
  Old sockets are closed by finding the appropriate name in 'portlist'
  and writing it back to 'portlist' preceded by a '-'.

nfs-utils-1.0.9 can work with 'portlist' to e.g. control which
protocol (udp or tcp) is used.  However it has other problems:
 rpc.nfsd 0
will no longer stop all nfsd threads.  So there will be a 1.0.10 shortly.

NeilBrown

 [PATCH 001 of 9] knfsd: knfsd: Add some missing newlines in printks
 [PATCH 002 of 9] knfsd: knfsd: Remove an unused variable from e_show().
 [PATCH 003 of 9] knfsd: knfsd: Remove an unused variable from auth_unix_lookup()
 [PATCH 004 of 9] knfsd: Add a callback for when last rpc thread finishes.
 [PATCH 005 of 9] knfsd: Be more selective in which sockets lockd listens on.
 [PATCH 006 of 9] knfsd: Remove nfsd_versbits as intermediate storage for desired versions.
 [PATCH 007 of 9] knfsd: Separate out some parts of nfsd_svc, which start nfs servers.
 [PATCH 008 of 9] knfsd: Define new nfsdfs file: portlist - contains list of ports.
 [PATCH 009 of 9] knfsd: Allow sockets to be passed to nfsd via 'portlist'

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
