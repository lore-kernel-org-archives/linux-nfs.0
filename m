From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] Correctly handle -f (fake) mount option.
Date: Tue, 20 Mar 2007 09:32:24 +1100
Message-ID: <17919.3960.119592.700194@notabene.brown>
References: <20070319193317.GH18681@petra.dvoda.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Karel Zak <kzak@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTQP4-0001KI-FF
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 15:32:34 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTQP5-00049z-F0
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 15:32:36 -0700
In-Reply-To: message from Karel Zak on Monday March 19
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

On Monday March 19, kzak@redhat.com wrote:
> The fake option has to write to mtab like a normal mount. Read mount(8) man
> page for more details.  It's very important for system init scripts that use
> "-f" as a way how write info about mount points to /etc/mtab.

Thanks!
applies.

NeilBrown


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
