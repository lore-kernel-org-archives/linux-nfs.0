From: Olaf Kirch <okir@suse.de>
Subject: Re: kernel+userspace based nfsd running in parallel on linux?
Date: Mon, 18 Dec 2006 08:21:30 +0100
Message-ID: <20061218072130.GA11302@suse.de>
References: <1499049521@web.de> <200612161717.31090.bernd-schubert@gmx.de>
	<20061216215544.GA5968@suse.de>
	<Pine.LNX.4.64.0612170140250.31965@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwCoa-0005do-UL
	for nfs@lists.sourceforge.net; Sun, 17 Dec 2006 23:21:37 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GwCoZ-0005ZH-V9
	for nfs@lists.sourceforge.net; Sun, 17 Dec 2006 23:21:38 -0800
To: Peter =?iso-8859-1?Q?=C5strand?= <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0612170140250.31965@maggie.lkpg.cendio.se>
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

On Sun, Dec 17, 2006 at 11:25:45AM +0100, Peter =C5strand wrote:
> This is no problem, you can run both the nfs and mount service without th=
e =

> portmapper. They can even run on the same port. So, typically you run =


Yeah, I know. But is that what he was asking for?

Olaf
-- =

Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
