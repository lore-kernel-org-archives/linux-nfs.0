From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 3/4] Add /proc/sys/fs/nfs sysctls to nfsd module
Date: Thu, 03 Aug 2006 13:08:00 -0400
Message-ID: <1154624881.5774.96.camel@localhost>
References: <20060803110538.GA17173@suse.de>
	<76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8ggc-0007vY-G6
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 10:08:47 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8ggb-000602-Kx
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 10:08:43 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30608030952p15e1500cy191b5ef19241b58e@mail.gmail.com>
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

On Thu, 2006-08-03 at 09:52 -0700, Chuck Lever wrote:
> I don't recall the history of /proc/sys/fs -- is there also a
> /proc/sys/fs/nfsd directory, and wouldn't it be better to add this
> particular sysctl in there?

I too would prefer to reserve /proc/sys/fs/nfs for client and/or common
stuff (like the lockd listening ports).

There is an nfsd filesystem (usually mounted on /proc/fs/nfsd), for
which the above is more appropriate.

Note, however, that the entire sysctl should be unnecessary. Clients are
supposed to tell the server how large a reply to return, by means of the
'maxcount' argument (see RFC1813). If the clients aren't doing that,
then they really need to be fixed.
Linux clients should, AFAIK, always be setting maxcount to
PAGE_CACHE_SIZE == 4k.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
