From: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>
Subject: Re: [Fwd: Re: [Patch] Possible dereference in
	fs/nfsd/nfs4callback.c]
Date: Wed, 27 Sep 2006 16:00:44 +0200
Message-ID: <20060927140044.GA24490@alice>
References: <451962BD.6050909@oracle.com>
	<76bd70e30609261036l111274er219db13a336c1164@mail.gmail.com>
	<1159296937.5492.15.camel@lade.trondhjem.org>
	<76bd70e30609261237v72fe65fbuab72b27eae0b24f9@mail.gmail.com>
	<1159301581.5492.44.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Sesterhenn / Snakebyte <snakebyte@gmx.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSZy3-0004Fy-Nj
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 07:00:55 -0700
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GSZy2-0004YD-TH
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 07:00:56 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1159301581.5492.44.camel@lade.trondhjem.org>
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

* Trond Myklebust (trond.myklebust@fys.uio.no) wrote:
> On Tue, 2006-09-26 at 15:37 -0400, Chuck Lever wrote:
> > Getting rid of the check makes the code slightly clearer, does not
> > change the characteristic that the code will oops if inode == NULL,
> > and has the side advantage of shutting up coverity checking.  That's
> > all my patch does.
> 
> That would be fine.

marked 1372, 1373 and 847 as BUG, they will dissappear from
coverity once the patches hit linus tree. Chuck, will you
do the patch for 847 which drops the ENOENT or should i submit one?
1034 is marked as FALSE in coverity, i will submit 1110 and 733
to the bugzilla as soon as i get my password

should I submit further coverity warnings to this list,
if some appear in the future?

Thanks, Eric

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
