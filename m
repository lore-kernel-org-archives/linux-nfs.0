From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Odd log message associated with NFS
Date: Fri, 30 Mar 2007 17:03:44 -0400
Message-ID: <20070330210344.GF15224@fieldses.org>
References: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com>
	<20070327193909.GA585@ds20.borg.net>
	<20070328165925.GB21221@fieldses.org>
	<20070328190536.GB585@ds20.borg.net>
	<20070328232348.GJ21221@fieldses.org>
	<20070330205145.GA1349@Marvin.DL8BCU.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXOGA-00049B-Ey
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 14:03:46 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXOGB-0004R3-Bq
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 14:03:48 -0700
In-Reply-To: <20070330205145.GA1349@Marvin.DL8BCU.ampr.org>
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

On Fri, Mar 30, 2007 at 08:51:45PM +0000, Thorsten Kranzkowski wrote:
> The source address obviously isn't from my local net, and the clear
> text speaks for itself.

Woah, yeah, neato.  OK, I guess that makes me a lot more willing to
believe any "impossible" error in linux/net/sunrpc/svc.c:svc_process()
is due to random garbage on the network.

I'd definitely like more people to be able to run their nfs server
outside any firewall, so that probably means we should demote these
printk's to dprintk's some day.

> looks like an attack to some Windows service with phishing content.
> luckily this machine is neither windows based nor intel compatible :)

I'd love to know what the heck it's actually trying to do.

Thanks for the followup!

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
