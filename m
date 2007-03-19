From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Mon, 19 Mar 2007 14:40:32 -0400
Message-ID: <EXNANE016beUzmRf6Ci00000104@exnane01.hq.netapp.com>
References: <17914.20117.186786.830574@notabene.brown>
	<EXNANE01pH71yEXUIEA000000e2@exnane01.hq.netapp.com>
	<17917.50411.770610.290399@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTMmq-0001TT-Bh
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 11:40:52 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTMmr-0002xY-8q
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 11:40:54 -0700
In-Reply-To: <17917.50411.770610.290399@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown>
	<EXNANE01pH71yEXUIEA000000e2@exnane01.hq.netapp.com>
	<17917.50411.770610.290399@notabene.brown>
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

At 07:02 PM 3/18/2007, Neil Brown wrote:
>The part of statd that I particularly want to keep out of the kernel
>is the creating of files in /var/lib/nfs/sm/.

This sounds good. And of course, if the kernel doesn't do the notify
then it doesn't need to read (list) them either.

>SuSE's kstatd seems to cope without resolving mon_name.

I'd be interested in the details. It's been our observation that very few
statd implementations work properly in all cases.

>One option is to just ignore it and use the source IP address.  That
>would work fine with the default config which uses IP address for all
>host identification.
>However this doesn't work well for multi-homes hosts and there is a

Yes, multihomed hosts (clients) are the problem. Without the mon_name
lookup, they will be required to send their notifies from each interface
that they originally took nlm locks on. Otherwise, the server won't ever
know, and the locks won't be released. So unless the world comes back
in exactly the same state (and don't forget DHCP) with the same
connectivity, the nlm recovery will fail.

>However if it turns out that name-resolution is really needed in this
>path, then I'll definitely keep that part of statd out of the kernel.

Let me finish digging up some of our testing scenarios and I think you
may be convinced. We did some very interesting research last year
that led to some important changes in the way our Ontap server
performs recovery. There are implications on the client side too,
though most of them were in nfs-utils<=1.0.6 and so fixed.

The big huge gigantic problem with SM_NOTIFY is that it is semantically
void - absolutely nothing can be inferred from its "success". Any peer
with half an idea what an RPC is, will respond whether it thinks it holds
a lock or not. In fact, a peer that doesn't reply gives you more information!

Tom.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
