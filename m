From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Tue, 20 Mar 2007 11:03:56 -0400
Message-ID: <EXNANE01a8d9Ee4zadT0000011c@exnane01.hq.netapp.com>
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
	<20070320145706.GF12165@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTfsh-0002qG-DB
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 08:04:11 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTfsh-0005Xc-Ci
	for nfs@lists.sourceforge.net; Tue, 20 Mar 2007 08:04:13 -0700
In-Reply-To: <20070320145706.GF12165@fieldses.org>
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
	<20070320145706.GF12165@fieldses.org>
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

At 10:57 AM 3/20/2007, J. Bruce Fields wrote:
>Is there a particular case you're worried about?
>
>> If the client is truly full of garbage, then the clientid
>> will probably fail too anyway.
>
>Yeah, I don't see any reason to care about a client that hands us random
>stateid's that weren't given out by us. 

Well, maybe just returning them as "stale". But in the absence of
the server persisting it all, it could be the best it can do.

With v4.1 and a session, it will be a lot harder to get there anyway.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
