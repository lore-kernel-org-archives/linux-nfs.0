From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Fri, 4 Aug 2006 19:52:32 +0200
Message-ID: <20060804175232.GA29852@suse.de>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
	<1154680981.21040.2415.camel@hole.melbourne.sgi.com>
	<1154705797.4727.18.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <chucklever@gmail.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G93qg-0007GR-To
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 10:52:39 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G93qg-000475-5t
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 10:52:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1154705797.4727.18.camel@localhost>
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

On Fri, Aug 04, 2006 at 11:36:37AM -0400, Trond Myklebust wrote:
> Not really. It would be better to identify and fix the buggy clients
> that aren't setting the READDIRPLUS maxcount parameter correctly.

One of them was Solaris 9, IIRC. Don't recall what the other one was.
I contacted at least Sun, but that didn't go anywhere.

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
