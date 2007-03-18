From: Neil Brown <neilb@suse.de>
Subject: Re: HEADS-UP: nearing nfs-utils 1.1.0 and statd changes.
Date: Mon, 19 Mar 2007 09:52:07 +1100
Message-ID: <17917.49815.63101.888846@notabene.brown>
References: <17914.20117.186786.830574@notabene.brown>
	<4d569c330703160730y28be4800p858c64f07a3e5e99@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
To: "Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT4Ef-0007xU-Dw
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 15:52:23 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HT4Eg-0004Jj-Lp
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 15:52:23 -0700
In-Reply-To: message from Kevin Coffman on Friday March 16
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

On Friday March 16, kwc@citi.umich.edu wrote:
> Hi Neil,
> Is it still the intention to change the default to build mount.nfs by
> default for 1.1.0?

Yes.  Which means the code needs some careful review as it needs to be
setuid-root.  So between -rc1 and -final I'll be looking at it
carefully, and I would be great if other did too....

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
