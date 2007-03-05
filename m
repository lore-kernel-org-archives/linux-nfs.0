From: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Subject: Re: Oops in lockd (2.6.20.1)
Date: Mon, 5 Mar 2007 18:54:33 +0100
Message-ID: <20070305175433.GB7892@sith.mimuw.edu.pl>
References: <20070305134706.GA6072@sith.mimuw.edu.pl>
	<200703051636.06411.olaf.kirch@oracle.com>
	<1173111509.6470.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Olaf Kirch <olaf.kirch@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOHOM-0007Kr-Ob
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 09:54:38 -0800
Received: from sith.mimuw.edu.pl ([193.0.96.4] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOHON-0003yc-KU
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 09:54:37 -0800
In-Reply-To: <1173111509.6470.29.camel@heimdal.trondhjem.org>
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

On Mon, 05 Mar 2007, Trond Myklebust wrote:

> Already fixed in 2.6.21-rc1 mainline. See
> 
> http://client.linux-nfs.org/Linux-2.6.x/2.6.20/linux-2.6.20-001-fix_nlm_async_call.dif

Thank you :)
I'll test it tomorrow and I really hope my problems with
unresponsive/dying lockd will go away at last.

Jan
-- 
Jan Rekorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
