From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 09:15:28 +1100
Message-ID: <17903.14720.458169.409983@notabene.brown>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP4Q4-000432-ML
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:15:36 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP4Q5-0005Lx-9w
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 14:15:38 -0800
In-Reply-To: message from Talpey, Thomas on Wednesday March 7
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

On Wednesday March 7, Thomas.Talpey@netapp.com wrote:
> 
> The "flush" file lives in /proc/net/rpc/nfsd.export, and you write an
> integer value to it. I *think* it then flushes any entries which are
> more than that many seconds old.

You write a timestamp in seconds-since-epoch and any entries older
that time are treated as expired.  We typically write out the
mtime of the etab file.  Or '1' to force a full flush.

Arguably that sort of fine control isn't needed, but it seemed like a
good idea at the time (it cause problems if your system clock goes
backwards).

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
