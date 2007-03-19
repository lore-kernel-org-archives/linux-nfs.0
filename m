From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: Re: rpc.statd  in /sbin or /usr/sbin ??
Date: Mon, 19 Mar 2007 09:24:01 +0100
Message-ID: <200703190924.03153.olaf.kirch@oracle.com>
References: <17917.58341.502839.29524@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTDAf-0001IU-Hq
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 01:24:49 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTDAg-0000xR-91
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 01:24:51 -0700
In-Reply-To: <17917.58341.502839.29524@notabene.brown>
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

On Monday 19 March 2007 02:14, Neil Brown wrote:
>  The only reason I can see for putting statd in /sbin is if it were
>  needed for mounting /usr (in cases where /usr is accessed via NFS).

Can't speak for others, but this is the reason why Suse put it into /sbin too,
as long as they shipped it.

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
