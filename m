From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: rpc.statd  in /sbin or /usr/sbin ??
Date: Thu, 22 Mar 2007 08:10:22 -0400
Message-ID: <EXNANE01pMmOlbcrYP000000296@exnane01.hq.netapp.com>
References: <17917.58341.502839.29524@notabene.brown>
	<200703190924.03153.olaf.kirch@oracle.com>
	<45FE8782.5020001@RedHat.com>
	<17922.4151.996812.925495@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUM7i-0000vl-Ux
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 05:10:31 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUM7k-0005cN-03
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 05:10:33 -0700
In-Reply-To: <17922.4151.996812.925495@notabene.brown>
References: <17917.58341.502839.29524@notabene.brown>
	<200703190924.03153.olaf.kirch@oracle.com>
	<45FE8782.5020001@RedHat.com>
	<17922.4151.996812.925495@notabene.brown>
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

At 01:12 AM 3/22/2007, Neil Brown wrote:
>So how about this: In a similar way that we now try to start statd if
>'nolock' is not set, we could set 'nolock' if we fail to start statd
>(and it isn't already running).  What do people think of that?

Gack. At worst, the mount should fail, instead of silently changing the
mount to one which may break application semantics! This would change
the default behavior in a way the admin couldn't override. Besides,
what's to say statd won't die later?

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
