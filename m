From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Mon, 19 Mar 2007 21:14:58 -0400
Message-ID: <20070320011458.GA31225@fieldses.org>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
	<17917.53245.697560.272545@notabene.brown>
	<20070319230213.GD29272@fieldses.org>
	<EXNANE01h7jtrSByh130000010c@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTSwG-0001Nk-St
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 18:15:09 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTSwH-0004F6-KJ
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 18:15:03 -0700
In-Reply-To: <EXNANE01h7jtrSByh130000010c@exnane01.hq.netapp.com>
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

On Mon, Mar 19, 2007 at 08:30:42PM -0400, Talpey, Thomas wrote:
> At 07:02 PM 3/19/2007, J. Bruce Fields wrote:
> >so.  That means that we no longer need to forget those clients that
> >haven't reclaimed at the end of grace--we *can* if we want to, but it's
> >not urgent because (as long as we also rememember "boot" times), we can
> >notice at the next boot that their last reclaim was too long ago.
> 
> In fact, it's highly desirable to keep their state around, until some
> conflict arises. Maybe the network is partitioed, etc. It's the Internet
> Principle, in addition to being appropriately lazy. 

You're getting a little ahead of me here.  I'm not talking about trying
to allow reclaims after the grace period ends--I agree that that would
be nice, but I don't see a really simple way to do that.  I'm just
talking about how we implement the simplest reboot recovery behavior.

Currently we're *not* doing what the rfc suggests--keeping a record
with timestamp of first open, etc.--instead we're basically remembering
just the one bit per client (is this client known to us or not), which
means we *must* synchronously invalidate every client as we exit the
grace period.  That's awkward.

> But I have a question - what's "too long ago"? Do you propose
> refusing a reclaim after some interval?

So by "too long ago" I mean "more than one boot ago".

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
