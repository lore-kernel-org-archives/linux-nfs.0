From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Mon, 22 Jan 2007 08:04:54 +0100
Message-ID: <20070122070454.GZ97844@fit.vutbr.cz>
References: <20061123161738.GF40079@fit.vutbr.cz>
	<20061123172456.GG40079@fit.vutbr.cz>
	<20061123213311.GH40079@fit.vutbr.cz>
	<20061124064752.GI40079@fit.vutbr.cz>
	<1164395516.5702.53.camel@lade.trondhjem.org>
	<20061125182600.GA74811@fit.vutbr.cz>
	<1164479583.5886.4.camel@lade.trondhjem.org>
	<20061212134501.GK39055@fit.vutbr.cz>
	<1165941785.5788.42.camel@lade.trondhjem.org>
	<20061222093924.GR93107@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H8tnD-0006ag-Fy
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 23:40:39 -0800
Received: from kazi.fit.vutbr.cz ([147.229.8.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H8tnD-0002j0-Ql
	for nfs@lists.sourceforge.net; Sun, 21 Jan 2007 23:40:41 -0800
Received: from kazi.fit.vutbr.cz (localhost [127.0.0.1])
	by kazi.fit.vutbr.cz (envelope-from kasparek@fit.vutbr.cz)
	(8.13.8/8.13.7) with ESMTP id l0M74sAH078424
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 22 Jan 2007 08:04:55 +0100 (CET)
Received: (from kasparek@localhost)
	by kazi.fit.vutbr.cz (8.13.8/8.13.1/Submit) id l0M74sBt078423
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 08:04:54 +0100 (CET)
	(envelope-from kasparek@fit.vutbr.cz)
To: nfs@lists.sourceforge.net
In-Reply-To: <20061222093924.GR93107@fit.vutbr.cz>
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

On Fri, Dec 22, 2006 at 10:39:24AM +0100, Kasparek Tomas wrote:
> On Tue, Dec 12, 2006 at 11:43:05AM -0500, Trond Myklebust wrote:
> > On Tue, 2006-12-12 at 14:45 +0100, Kasparek Tomas wrote:
> > 
> > > Hi, still me with the same problem, sorry for being pain in the ass, but I
> > > need to solve it somehow (being not able to change the applications used).
> > > 
> > > I have tried mounting the share with 'noac' option as mentioned in the FAQ,
> > > but the behaviour is the same.
> > > 
> > > Would you have any other advice how to get the old behaviour (for me that
> > > means that of kernel 2.6.16.x)?
> > > 
> > > (I tested some newer kernels to - 2.6.18.5 and 19.1 just for the case
> > > someting changes but no success there.)
> > 
> > Could you try 2.6.19 w/ the NFS_ALL patch from
> > http://client.linux-nfs.org/Linux-2.6.x/2.6.19/ ?
> > 
> > I know of one corruption issue that was happening there due to a race
> > between invalidate_inode_pages2() and the write code.
> 
> sorry it takes so long, I finnaly tried it and results are the same
> 
> - 2.6.19 + NFS_ALL (both with/withnout noac)
> - 2.6.20-rc1 (both with/withnout noac)
> 
> Will try to do more investigations afer Xmas.

Have tried another versions with interesting results:

- 2.6.19.1 (with/out noac)      - BAD
- 2.6.19.2 (without noac)       - BAD
- 2.6.19.2 (with noac)          - OK !!!!
- 2.6.20-rc5 (with/out noac)    - BAD

so something in 2.6.19.2 corrected the behaviour if mounted with 'noac',
but it does not work again in 20-rc5.

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, BI/140a    Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 2, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  ICQ: 293092805  jabber: tomas.kasparek@jabber.cz
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
