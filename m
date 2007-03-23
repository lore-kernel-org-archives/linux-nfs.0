From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 4] knfsd: 4 bugfixes for nfsd suitable for
	2.6.21
Date: Fri, 23 Mar 2007 11:46:43 +1100
Message-ID: <20070323114512.28822.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUXvg-00014Y-Pb
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:46:53 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HUXvh-00029Q-RU
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:46:55 -0700
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

Following are 4 small bugfixes for nfsd that are suitable for 2.6.21.

Thanks,
NeilBrown

 [PATCH 001 of 4] knfsd: Allow nfsd READDIR to return 64bit cookies
 [PATCH 002 of 4] knfsd: nfsd4: fix inheritance flags on v4 ace derived from posix default ace
 [PATCH 003 of 4] knfsd: nfsd4: demote "clientid in use" printk to a dprintk
 [PATCH 004 of 4] knfsd: nfsd4: remove superfluous cancel_delayed_work() call

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
