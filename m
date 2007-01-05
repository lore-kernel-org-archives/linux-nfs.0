From: Stephan Henningsen <sth@amplex.dk>
Subject: Re: Trouble accessing NFS mountpoint as user
Date: Fri, 05 Jan 2007 07:56:25 +0100
Message-ID: <459DF699.6010303@amplex.dk>
References: <459CB96A.1060806@amplex.dk>
	<1167901767.6046.17.camel@lade.trondhjem.org>
	<459CD54E.9050107@amplex.dk> <20070104210041.GA15676@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2j0V-00048F-U3
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 22:56:52 -0800
Received: from [62.242.67.89] (helo=server.amplex.dk)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H2j0W-0000Fa-Cm
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 22:56:53 -0800
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20070104210041.GA15676@janus>
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

Frank van Maarseveen wrote:
> There's an alternative: See http://www.frankvm.com/nfs-ngroups/ for a
> patch to get rid of the 16 groups limit on linux NFS2/NFS3 clients without
> breaking the protocol.

Interesting patch, thanks.  However, I'm already in the middle of switching 
to NFSv4.

-- 
Stephan Henningsen



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
