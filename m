From: Pete Zaitcev <zaitcev@redhat.com>
Subject: >16 groups status
Date: Tue, 15 Oct 2002 23:02:22 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021015230222.A25137@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pete Zaitcev <zaitcev@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=devserv.devel.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181eS1-0001bp-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 20:02:25 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Guys,

does anyone remember why the van Maarseveen's patch is not being
integrated? I looked at it, and the only problem I see is that
it's not under a suitable CONFIG_XXXX (dependent on CONFIG_SUNRPC,
perhaps).

This seems to be the home of it:
 http://web.inter.nl.net/users/fvm/nfs-ngroups/

-- Pete


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
