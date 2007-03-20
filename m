From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Tue, 20 Mar 2007 10:49:15 -0400
Message-ID: <EXNANE01MWuLn5U9T3T0000011a@exnane01.hq.netapp.com>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
	<17917.53245.697560.272545@notabene.brown>
	<20070319230213.GD29272@fieldses.org>
	<EXNANE01h7jtrSByh130000010c@exnane01.hq.netapp.com>
	<20070320011458.GA31225@fieldses.org>
	<EXNANE01LoygXLsxpTl0000010f@exnane01.hq.netapp.com>
	<89c397150703200424n4921f619heaa47c13482a215a@mail.gmail.com>
	<20070320142627.GC12165@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTfeT-00018S-8m
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 07:49:29 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTfeT-0002LJ-Lt
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 07:49:30 -0700
In-Reply-To: <20070320142627.GC12165@fieldses.org>
References: <17914.20117.186786.830574@notabene.brown>
	<20070316181047.GD4538@fieldses.org>
	<17917.53245.697560.272545@notabene.brown>
	<20070319230213.GD29272@fieldses.org>
	<EXNANE01h7jtrSByh130000010c@exnane01.hq.netapp.com>
	<20070320011458.GA31225@fieldses.org>
	<EXNANE01LoygXLsxpTl0000010f@exnane01.hq.netapp.com>
	<89c397150703200424n4921f619heaa47c13482a215a@mail.gmail.com>
	<20070320142627.GC12165@fieldses.org>
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

At 10:26 AM 3/20/2007, J. Bruce Fields wrote:
>On Tue, Mar 20, 2007 at 07:24:00AM -0400, William A. (Andy) Adamson wrote:
>> No. The stale stateid check is before the bad stateid check
>> (fs/nfsd/nfs4state.c:nfs4_preprocess_stateid_op) - stale stateid is
>> returned, which is the correct behavior past reclaim processing.
>
>Yeah, note that the necessary information is in the stateid itself--we
>embed the current boot time in every stateid we hand out--so we don't
>need to keep around any memory of the client in order to hand out the
>correct error.

Yeah, after Andy's pointer I did notice that all non-0, non-1,
non-current-server-boot-time stateids from the client will result in
a "stale" return from STALE_STATEID(). ;-)

I might argue on that "correct" adjective, but yes, it does encourage
reclaim/recovery. If the client is truly full of garbage, then the clientid
will probably fail too anyway.

Thanks.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
