From: Neil Brown <neilb@suse.de>
Subject: Re: Opps in 2.6.21-rc4 nfsd
Date: Mon, 26 Mar 2007 10:50:31 +1000
Message-ID: <17927.6359.721594.133569@notabene.brown>
References: <2fe399760703221224g40fc44ddof41d1fcd442612d5@mail.gmail.com>
	<20070323152913.GH752@stusta.de>
	<2fe399760703230845s4f652df0v9fd57e1aa7943e4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Adrian Bunk <bunk@stusta.de>
To: "Phy Prabab" <phyprabab@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVdQ5-0000X0-HC
	for nfs@lists.sourceforge.net; Sun, 25 Mar 2007 17:50:45 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HVdQ7-0005SE-Km
	for nfs@lists.sourceforge.net; Sun, 25 Mar 2007 17:50:47 -0700
In-Reply-To: message from Phy Prabab on Friday March 23
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

On Friday March 23, phyprabab@gmail.com wrote:
> Adrian et al,
> 
> Under 2.6.20.2+3 I get a similar crash and more frequently.  At least
> under 2.6.21rc4 I only get this about once every two hours under heavy
> nfs testing.

That is very odd.  The code where it is crashing in the trace you
provide does not exist in 2.6.20 at all.

Do you have an Oops trace from when it crashed under 2.6.20.x ??

I'll try to have a patch for you to try on 2.6.21rc4 shortly.

What version of nfs-utils are you using?

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
