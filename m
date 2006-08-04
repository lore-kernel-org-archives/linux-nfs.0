From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Fri, 4 Aug 2006 19:55:47 +0200
Message-ID: <20060804175547.GB29852@suse.de>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
	<1154624881.5774.96.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G93tn-0007XL-V1
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 10:55:52 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G93tn-0008ML-6h
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 10:55:52 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1154624881.5774.96.camel@localhost>
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

> Note, however, that the entire sysctl should be unnecessary. Clients are
> supposed to tell the server how large a reply to return, by means of the
> 'maxcount' argument (see RFC1813). If the clients aren't doing that,
> then they really need to be fixed.

>From a distributor's point of view, waiting for the client vendor to
fix their bugs is often not the best way to go. People buying support
contracts expect a fix, no matter buy whom, they only want it NOW :-)
But I understand if you reject this for upstream.

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
