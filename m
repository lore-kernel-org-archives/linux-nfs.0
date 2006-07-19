From: Razvan Gavril <razvan.g@plutohome.com>
Subject: Re: Bug starting 2.6.16 - rpc: bad TCP reclen
Date: Wed, 19 Jul 2006 18:52:24 +0300
Message-ID: <44BE5538.4080508@plutohome.com>
References: <44BCC7A1.30104@plutohome.com> <44BE45CA.3050603@plutohome.com>
	<76bd70e30607190822o1b76b04w906729300160f7d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3ELc-0007MY-JK
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 08:52:28 -0700
Received: from k2smtpout01-02.prod.mesa1.secureserver.net ([64.202.189.89])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1G3ELc-0006u5-CE
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 08:52:29 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30607190822o1b76b04w906729300160f7d0@mail.gmail.com>
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

Chuck Lever wrote:

> I haven't seen other reports like this recently.  It could be a
> hardware problem on your server or in your network (like a bad server
> NIC).   A network trace would be the way to start tracking this down.
>
> sudo tcpdump -s0 -w /tmp/dump
>
> on your server.  Stop the dump when the server starts reporting the
> TCP stream problems.  Then take a look at the end of the dump with
> tethereal.
>

A hardware problem is almost impossible since we test it on a lot of 
different computers. I'm really interested if someone can explain what 
that message is meaning, it doesn't make much sense to me cause i don't 
know anything about rpc.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
