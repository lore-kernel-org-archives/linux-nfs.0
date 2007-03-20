From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Tue, 20 Mar 2007 10:26:27 -0400
Message-ID: <20070320142627.GC12165@fieldses.org>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
	<17917.53245.697560.272545@notabene.brown>
	<20070319230213.GD29272@fieldses.org>
	<EXNANE01h7jtrSByh130000010c@exnane01.hq.netapp.com>
	<20070320011458.GA31225@fieldses.org>
	<EXNANE01LoygXLsxpTl0000010f@exnane01.hq.netapp.com>
	<89c397150703200424n4921f619heaa47c13482a215a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: "William A. (Andy) Adamson" <andros@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTfIE-0006zJ-BO
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 07:26:30 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HTfIE-0008Ue-6U
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 07:26:32 -0700
In-Reply-To: <89c397150703200424n4921f619heaa47c13482a215a@mail.gmail.com>
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

On Tue, Mar 20, 2007 at 07:24:00AM -0400, William A. (Andy) Adamson wrote:
> On 3/20/07, Talpey, Thomas <Thomas.Talpey@netapp.com> wrote:
> >
> >At 09:14 PM 3/19/2007, J. Bruce Fields wrote:
> >>Currently we're *not* doing what the rfc suggests--keeping a record
> >>with timestamp of first open, etc.--instead we're basically remembering
> >>just the one bit per client (is this client known to us or not), which
> >>means we *must* synchronously invalidate every client as we exit the
> >>grace period.  That's awkward.
> >
> >Ah, I get it. It has to be invalidated because the state can't be marked
> >"out of grace"? The timestamp is the right fix of course, but wouldn't
> >a single bit ("known to us" | "out of grace") kinda sorta do it? Then
> >invalidation could at least be delayed.
> >
> >It's a little worse than awkward though. Isn't the server going to return
> >BAD_STATEID after this (instead of stale/old)? The server goes from
> >serving no state-granting ops, to dropping everything that didn't make
> >it back to reclaim in time. The v3 nlm recovery doesn't do that.
> 
> 
> No. The stale stateid check is before the bad stateid check
> (fs/nfsd/nfs4state.c:nfs4_preprocess_stateid_op) - stale stateid is
> returned, which is the correct behavior past reclaim processing.

Yeah, note that the necessary information is in the stateid itself--we
embed the current boot time in every stateid we hand out--so we don't
need to keep around any memory of the client in order to hand out the
correct error.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
