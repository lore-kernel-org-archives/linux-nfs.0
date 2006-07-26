From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Wed, 26 Jul 2006 11:14:29 +0200
Message-ID: <20060726091429.GB6979@suse.de>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<1153816400.21040.153.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5g9O-0001S0-U7
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 02:57:58 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5g9O-0007uZ-Bw
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 02:57:59 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5fTV-0007Jr-33
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 02:14:42 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1153816400.21040.153.camel@hole.melbourne.sgi.com>
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

On Tue, Jul 25, 2006 at 06:33:20PM +1000, Greg Banks wrote:
> > 			/*
> > 			 * Always select the oldest socket. It's not fair,
> > 			 * but so is life
> > 			 */
> > so I guess it is still correct ('oldest' is ambiguous).  The new
> > situation is probably equally (un)fair - would you agree?
> 
> Agreed.  The algorithm makes no pretence at fairness, but at least
> we're no longer bouncing cachelines in global data structures to
> check for old sockets (a infrequent corner case) on every incoming
> packet (the main performance path).

I think picking the oldest is just as good as picking a random one. The
only bad choice is picking the youngest socket, as that will make active
connections thrash while leaving potentially idle ones untouched.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
