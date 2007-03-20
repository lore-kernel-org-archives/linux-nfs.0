From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Tue, 20 Mar 2007 10:57:06 -0400
Message-ID: <20070320145706.GF12165@fieldses.org>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
	<17917.53245.697560.272545@notabene.brown>
	<20070319230213.GD29272@fieldses.org>
	<EXNANE01h7jtrSByh130000010c@exnane01.hq.netapp.com>
	<20070320011458.GA31225@fieldses.org>
	<EXNANE01LoygXLsxpTl0000010f@exnane01.hq.netapp.com>
	<89c397150703200424n4921f619heaa47c13482a215a@mail.gmail.com>
	<20070320142627.GC12165@fieldses.org>
	<EXNANE01MWuLn5U9T3T0000011a@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTfls-0001wW-EP
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 07:57:08 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HTflt-000359-TZ
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 07:57:10 -0700
In-Reply-To: <EXNANE01MWuLn5U9T3T0000011a@exnane01.hq.netapp.com>
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

On Tue, Mar 20, 2007 at 10:49:15AM -0400, Talpey, Thomas wrote:
> At 10:26 AM 3/20/2007, J. Bruce Fields wrote:
> >On Tue, Mar 20, 2007 at 07:24:00AM -0400, William A. (Andy) Adamson wrote:
> >> No. The stale stateid check is before the bad stateid check
> >> (fs/nfsd/nfs4state.c:nfs4_preprocess_stateid_op) - stale stateid is
> >> returned, which is the correct behavior past reclaim processing.
> >
> >Yeah, note that the necessary information is in the stateid itself--we
> >embed the current boot time in every stateid we hand out--so we don't
> >need to keep around any memory of the client in order to hand out the
> >correct error.
> 
> Yeah, after Andy's pointer I did notice that all non-0, non-1,
> non-current-server-boot-time stateids from the client will result in
> a "stale" return from STALE_STATEID(). ;-)
> 
> I might argue on that "correct" adjective, but yes, it does encourage
> reclaim/recovery.

Is there a particular case you're worried about?

> If the client is truly full of garbage, then the clientid
> will probably fail too anyway.

Yeah, I don't see any reason to care about a client that hands us random
stateid's that weren't given out by us. 

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
