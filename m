From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/8] exportfs cleanups
Date: Thu, 8 Mar 2007 17:08:29 +1100
Message-ID: <17903.43101.407769.914151@notabene.brown>
References: <20070307103932.GA22963@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPBo1-00083S-HC
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 22:08:49 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPBo2-0001xM-AN
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 22:08:51 -0800
In-Reply-To: message from Christoph Hellwig on Wednesday March 7
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

On Wednesday March 7, hch@infradead.org wrote:
> This patch series has 8 patches to clean up the code flow
> of fs/exportfs/expfs.c, and it's interface to the NFS server.

Thanks for these.  They look good.  That code certainly need some
cleaning up.

I didn't get 6/8.  Could you resend?

Patch 5/8 removes a number of comments without adding any.
 Do you think it would be valuable to add a comment explaining the
 subtleties for why directories and files are handled differently.

Patch 8/8 I should look through again to make sure all the dentry
references look right (I found them easy to get wrong).  Splitting up
find_exported_dentry was definitely a good idea.
You left in a comment in "If we weren't after a directory" in a place
were we know we weren't, so at least it should be "Since we
weren't....".


The rest all look fine.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
