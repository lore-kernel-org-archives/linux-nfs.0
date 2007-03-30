From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Fri, 30 Mar 2007 12:44:01 +0200
Message-ID: <200703301244.01465.bernd-schubert@gmx.de>
References: <17931.15549.578071.112573@notabene.brown>
	<200703291151.59120.bernd-schubert@gmx.de>
	<17932.29637.650203.597630@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXEaZ-0002vd-EQ
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 03:44:11 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HXEaZ-0003dv-2T
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 03:44:13 -0700
In-Reply-To: <17932.29637.650203.597630@notabene.brown>
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

On Friday 30 March 2007 04:19:49 Neil Brown wrote:
> rpc.statd used to drop root privilege before binding the port to
> listen on.  This is fixed in 1.1.0, so that little part of your
> problem should go away.

Great, thanks a lot!


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
