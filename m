From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 009 of 11] knfsd: Allow max size of NFSd
	payload	to be configured.
Date: Thu, 28 Sep 2006 14:22:38 +1000
Message-ID: <17691.19982.162616.572205@cse.unsw.edu.au>
References: <20060824162917.3600.patches@notabene> <1060824063716.5020@suse.de>
	<20060925212457.GK32762@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSnQ6-00059f-J6
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 21:22:46 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSnQ6-0005BJ-36
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 21:22:47 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: message from J. Bruce Fields on Monday September 25
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

On Monday September 25, bfields@fieldses.org wrote:
> 
> It looks to me like totalram is actually measured in pages.  So in
> practice this gives almost everyone 8k here.  So that 12 should be
> something like 12 - PAGE_CACHE_SHIFT?

Uhm.... yes.  Thanks.
But are the pages that totalram is measure in, normal pages, of
page_cache pages?  And is there a difference?
Should we use PAGE_CACHE_SHIFT, or PAGE_SHIFT?
And why do we have both if they are numerically identical?

I'll submit a patch which uses
        12 - PAGE_SHIFT
in a little while.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
