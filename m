From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs-utils inode cache patch
Date: Tue, 13 Mar 2007 07:40:53 -0400
Message-ID: <EXNANE013sllNY30kkZ000000bb@exnane01.hq.netapp.com>
References: <20070309180921.57ae908c.simon.peter@gmx.de>
	<17910.9971.125407.778285@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HR5NJ-0002x8-Bs
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 04:41:12 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HR5NJ-0006Po-Eq
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 04:41:07 -0700
In-Reply-To: <17910.9971.125407.778285@notabene.brown>
References: <20070309180921.57ae908c.simon.peter@gmx.de>
	<17910.9971.125407.778285@notabene.brown>
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

At 12:22 AM 3/13/2007, Neil Brown wrote:
>http://neil.brown.name/git?p=nfs-utils;a=commitdiff;h=b1e1c8a05afdbbc3f217ef79c31c3b8ca302f9eb

Nit, typo: "log" -> "long"

* change underneath us, and an 'exportfs -f' can always
 * remove this from the kernel, so use a really log
 * timeout.  Maybe this should be configurable on the command


Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
