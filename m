From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 4] knfsd: revised patches to fix IPv6/sunrpc
	link error and other fixes
Date: Tue, 6 Mar 2007 13:15:00 +1100
Message-ID: <20070306131103.26638.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOPE0-0006hD-Lt
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 18:16:24 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOPE1-0007xk-Eu
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 18:16:26 -0800
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

Revised version of previous patches:
 - Fixed the 'nfsd hang when stopped' problem
 - Dropped the 'avoid checking udp checksum' as I'm no longer convinced it is
   the right way to go.
 - Added a paranoia check that the control message returned by recvfrom
   is in-fact a PKTINFO message.

Tested that a udp mount still works, and the the nfsd server can be stopped and
restarted successfully.  Found that it still doesn't if there is active
traffic so fixed that.
Also patch from Greg Banks to make the thread-pool stuff non-default as
it is not optimal on all machines, and often needs tuning where it can
be optimal.

Thanks,
NeilBrown

 [PATCH 001 of 4] knfsd: Use recv_msg to get peer address for NFSD instead of code-copying
 [PATCH 002 of 4] knfsd: Remove CONFIG_IPV6 ifdefs from sunrpc server code.
 [PATCH 003 of 4] knfsd: Fix recently introduced problem with shutting down a busy NFS server.
 [PATCH 004 of 4] knfsd: Provide sunrpc pool_mode module option

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
