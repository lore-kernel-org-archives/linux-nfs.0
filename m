From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Fri, 4 Aug 2006 22:06:57 +0200
Message-ID: <20060804200657.GC29852@suse.de>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
	<1154680981.21040.2415.camel@hole.melbourne.sgi.com>
	<1154705797.4727.18.camel@localhost>
	<20060804175232.GA29852@suse.de>
	<1154715807.4727.30.camel@localhost> <44D39D18.7080907@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Greg Banks <gnb@melbourne.sgi.com>,
	Chuck Lever <chucklever@gmail.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G95wt-0001tV-1w
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 13:07:11 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G95ws-00038s-0P
	for nfs@lists.sourceforge.net; Fri, 04 Aug 2006 13:07:11 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44D39D18.7080907@redhat.com>
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

On Fri, Aug 04, 2006 at 03:16:40PM -0400, Peter Staubach wrote:
> The two fields were intended to be used to reduce the overhead on
> the server by passing a hint for the amount of data that the client
> was actually looking for and then a count for the maximum sized response
> that it was prepared to handle.
> 
> Solaris probably uses something like 1048/32768 or 8192/32768, doesn't
> it?

I don't remember the values, all I know was that it got stuck in
READDIRPLUS, repeating the same call over and over again. And it can't
have been that many directory entries (definitely not in the thousands),
and IIRC we didn't hit the maxcount limit.

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
