From: Neil Brown <neilb@suse.de>
Subject: Re: Bug starting 2.6.16 - rpc: bad TCP reclen
Date: Thu, 20 Jul 2006 14:29:03 +1000
Message-ID: <17599.1679.768863.576310@cse.unsw.edu.au>
References: <44BCC7A1.30104@plutohome.com> <44BE45CA.3050603@plutohome.com>
	<76bd70e30607190822o1b76b04w906729300160f7d0@mail.gmail.com>
	<44BE5538.4080508@plutohome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3QAa-0005Il-FZ
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 21:29:52 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G3QAZ-0005Q2-BP
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 21:29:52 -0700
To: Razvan Gavril <razvan.g@plutohome.com>
In-Reply-To: message from Razvan Gavril on Wednesday July 19
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

On Wednesday July 19, razvan.g@plutohome.com wrote:
> Chuck Lever wrote:
> 
> > I haven't seen other reports like this recently.  It could be a
> > hardware problem on your server or in your network (like a bad server
> > NIC).   A network trace would be the way to start tracking this down.
> >
> > sudo tcpdump -s0 -w /tmp/dump
> >
> > on your server.  Stop the dump when the server starts reporting the
> > TCP stream problems.  Then take a look at the end of the dump with
> > tethereal.
> >
> 
> A hardware problem is almost impossible since we test it on a lot of 
> different computers. I'm really interested if someone can explain what 
> that message is meaning, it doesn't make much sense to me cause i don't 
> know anything about rpc.

The message means that data on the TCP connection is corrupted.
With tcp, every RPC message is prefixed by a 4 byte header.
The msb of this number is set to one to show it is the last of a
sequence of fragments (we don't support multiple rpc-fragments).  The
rest of the number is the number of bytes in the RPC message.
This should be less than about 32000 as we don't support any messages
bigger than this.  You are seeing number with the msb clear, and
numbers bigger than 32000.

It is very probably that this is not the first corruption in the TCP
stream, just the first that is being reported.  I have no idea where
the corruption could be coming from.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
