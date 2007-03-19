From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] [nfs-utils: mountd] exports too verbose.
Date: Mon, 19 Mar 2007 14:47:16 -0400
Message-ID: <45FEDAB4.5040006@RedHat.com>
References: <45F6CB05.6010604@RedHat.com>	<17913.58996.50116.344398@notabene.brown>	<45FA9A12.1030602@RedHat.com>
	<17917.51702.109517.90615@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTMt4-0002Dm-Fi
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 11:47:18 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTMt5-00056C-65
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 11:47:20 -0700
In-Reply-To: <17917.51702.109517.90615@notabene.brown>
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



Neil Brown wrote:
> Anyway, how about this on top of the previous patch...  any
> improvement?
Looks good... The main complaint was the number of times the
message was being logged so logging it once is good...
But there was some grumbling about a message being logged
for an valid export configuration...

steved.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
