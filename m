From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 19:41:26 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBIEJDCFAA.enorwood@effrem.com>
References: <5CA6F03EF05E0046AC5594562398B9165E77BB@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181e7n-0002dT-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 19:41:31 -0700
To: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>,
   <nfs@lists.sourceforge.net>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B9165E77BB@poexmb3.conoco.net>
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

Hi Roger,

> When you did the local dd you did make sure to break the cache?

You bet. I created 10GB files so as to be sure to break the 2GB cache. Still
*much* faster local than NFS no matter what proto/size/options.

Eff Norwood




-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
