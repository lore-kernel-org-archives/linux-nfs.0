From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] provide non-standard getgrouplist()
	in	libnfsidmap when need be
Date: Mon, 26 Mar 2007 12:09:09 -0400
Message-ID: <20070326160909.GD26422@fieldses.org>
References: <200703250329.03353.vapier@gentoo.org>
	<1174915365.6838.6.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0703261624130.12321@maggie.lkpg.cendio.se>
	<1174924003.6838.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter =?iso-8859-1?Q?=C5strand?= <astrand@cendio.se>,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVrku-00072k-Oe
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 09:09:12 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HVrkv-0001Tc-QK
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 09:09:15 -0700
In-Reply-To: <1174924003.6838.17.camel@heimdal.trondhjem.org>
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

On Mon, Mar 26, 2007 at 11:46:43AM -0400, Trond Myklebust wrote:
> We're not after the full list of user groups or the group entries.
> libnfsidmap exists purely in order to map a single gid into a group name
> or vice versa and then stuff the result into a kernel cache.

Not currently true, because we're also using libnfsidmap to do the krb
principal -> (uid, gid's) mapping--my mistake.

We should split that code out from libnfsidmap and stick it back into
rpc.svcgssd where it came from.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
