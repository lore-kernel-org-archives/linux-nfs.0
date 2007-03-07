From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 07 Mar 2007 16:07:39 -0500
Message-ID: <EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP3Mq-0005Qq-Oj
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:08:14 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP3Mo-0008Bo-Hd
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 13:08:11 -0800
In-Reply-To: <20070307205016.GI26553@fieldses.org>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
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

At 03:50 PM 3/7/2007, J. Bruce Fields wrote:
>> You probably don't want to sign up for enhancing the in-kernel export
>> cache. :-) Let's just say it's a bit mysterious, especially its interaction
>> with mountd.
>
>I sympathize, though this is actually one of the few mysteries of our
>nfs implementation that I feel like I understand, at least on alternate
>Thursdays....  What's bugging me a lot these days is I don't understand
>well enough why it's the way it is and what might need to be done to
>make it better.

I was actually trying to talk Simon out of trying, in case that wasn't
obvious.

But I'm really glad it bugs you! Keep thinking that way, maybe you can
untangle it someday. :-)

While you're thinking about it, what's the actual timeout on a given
in-kernel export cache entry? There's a 120-second deadline on an
unresolved cache miss being populated, but when, exactly, does an
existing (resolved) entry go stale? I admit to having tried to figure it
out once and wound up going in circles.

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
