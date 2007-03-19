From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Mon, 19 Mar 2007 19:02:13 -0400
Message-ID: <20070319230213.GD29272@fieldses.org>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
	<17917.53245.697560.272545@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	richterd@citi.umich.edu
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTQro-0004Yt-Kj
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 16:02:17 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HTQrp-0004Iz-GD
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 16:02:18 -0700
In-Reply-To: <17917.53245.697560.272545@notabene.brown>
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

On Mon, Mar 19, 2007 at 10:49:17AM +1100, Neil Brown wrote:
> On Friday March 16, bfields@fieldses.org wrote:
> > NFSv4 needs something like the third as well--knfsd needs to know on
> > startup the list of clients that will be allowed to reclaim state from a
> > previous boot instance.  (This is to protect clients that *think*
> > they're still holding locks on the server, but (thanks to a network
> > partition) don't realize that the server has actually rebooted twice.)
> 
> Similar... but different...

OK, actually more different than similar.  We need to run something at
about the same time--nfsd startup--but the stuff it has to do is pretty
different.  (In particular, it just needs to dump some information into
the kernel--it doesn't need to talk to any other hosts.)

> You would want to forget about clients who haven't reclaimed when the
> 'grace period' expires.  Yes?  So when the grace period starts, you
> move state from "current" to "recovering".  Then when a client tries
> to recover, we check in 'recovering' and if we find something, we
> recreate the state in 'current'.  Then when the grace period ends, we
> remove everything from 'recovering'.  So if the server reboots twice
> without actually completing a grace period, the client would still be
> safe.

Essentially correct--but I'd like one small change to that: when we move
clients to that "current" list (an action that'll have to be recorded to
stable storage) I also want to record a timestamp showing when we did
so.  That means that we no longer need to forget those clients that
haven't reclaimed at the end of grace--we *can* if we want to, but it's
not urgent because (as long as we also rememember "boot" times), we can
notice at the next boot that their last reclaim was too long ago.

This saves us having to do a bunch of synchronous work at the time the
grace period ends, which is inefficient and complicates the locking.
And it solves one or two extremely obscure corner cases.

(And it's what the rfc recommends, actually--I thought I was being
clever by doing something "simpler".  What a loser.)

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
