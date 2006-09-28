From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 008 of 11] knfsd: Prepare knfsd for support of
 rsize/wsize of up to 1MB, over TCP.
Date: Wed, 27 Sep 2006 20:46:32 -0700
Message-ID: <20060927204632.97c8f7c2.akpm@osdl.org>
References: <20060824162917.3600.patches@notabene> <1060824063711.5008@suse.de>
	<20060925154316.GA17465@fieldses.org>
	<17691.17511.884028.425714@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSmr8-0002Hq-Gg
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 20:46:38 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1GSmr8-0006mw-7z
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 20:46:39 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17691.17511.884028.425714@cse.unsw.edu.au>
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

On Thu, 28 Sep 2006 13:41:27 +1000
Neil Brown <neilb@suse.de> wrote:

> 	pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;

That's (the newly-added) DIV_ROUND_UP().

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
