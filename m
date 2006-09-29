From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 009 of 11] knfsd: Allow max size of NFSd payload
 to be configured.
Date: Fri, 29 Sep 2006 11:59:46 +1000
Message-ID: <17692.32274.496872.473492@cse.unsw.edu.au>
References: <20060824162917.3600.patches@notabene> <1060824063716.5020@suse.de>
	<20060925212457.GK32762@fieldses.org>
	<17691.19982.162616.572205@cse.unsw.edu.au>
	<Pine.LNX.4.64.0609281752290.32574@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GT7ff-0002BL-TW
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 19:00:12 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GT7ff-0000Mk-2O
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 19:00:12 -0700
To: Hugh Dickins <hugh@veritas.com>
In-Reply-To: message from Hugh Dickins on Thursday September 28
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

On Thursday September 28, hugh@veritas.com wrote:
> > 
> > I'll submit a patch which uses
> >         12 - PAGE_SHIFT
> > in a little while.
> 
> I haven't seen your context; but "12 - PAGE_SHIFT" sounds like a
> bad idea on all those architectures with PAGE_SHIFT 13 or more;
> you'll be on much safer ground working with "PAGE_SHIFT - 12".

Ahhh yes... of course.  Thanks.

		totalram <<= PAGE_SHIFT - 12;

Is what I want to convert a number of pages to 1/4096 the number of
bytes.

Thanks :-)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
