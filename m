From: Helge Bahmann <hcb@chaoticmind.net>
Subject: Re: lockd and krb5
Date: Thu, 16 Nov 2006 17:02:38 +0100
Message-ID: <200611161702.38857.hcb@chaoticmind.net>
References: <200611161137.28079.hcb@chaoticmind.net>
	<4d569c330611160621w48c7a85cy9982ea8c9d96877@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gkjho-0003Kz-FG
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 08:03:12 -0800
Received: from m4s07.vlinux.de ([83.151.27.105])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1Gkjhn-0000UG-D5
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 08:03:13 -0800
To: "Kevin Coffman" <kwc@citi.umich.edu>
In-Reply-To: <4d569c330611160621w48c7a85cy9982ea8c9d96877@mail.gmail.com>
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

Am Donnerstag, 16. November 2006 15:21 schrieb Kevin Coffman:
> I can't help directly with the locking behavior, but could it be
> related to expiring Kerberos credentials and/or gss contexts? 

no credentials are valid

> Is the KDE startup that often triggers this at initial login, or at some
> other time?

seems completely erratic; it happens both at initial login as well as second 
login (after successful logout, but before credentials expire); if there is 
any regularity at all then it seems that initial login seems more likely to 
succeed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
