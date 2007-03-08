From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/8] exportfs cleanups
Date: Thu, 8 Mar 2007 08:40:45 +0000
Message-ID: <20070308084045.GA6356@infradead.org>
References: <20070307103932.GA22963@infradead.org>
	<17903.43101.407769.914151@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPEB4-0006A2-HC
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 00:41:55 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPEB5-0002bl-DA
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 00:40:48 -0800
In-Reply-To: <17903.43101.407769.914151@notabene.brown>
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

On Thu, Mar 08, 2007 at 05:08:29PM +1100, Neil Brown wrote:
> On Wednesday March 7, hch@infradead.org wrote:
> > This patch series has 8 patches to clean up the code flow
> > of fs/exportfs/expfs.c, and it's interface to the NFS server.
> 
> Thanks for these.  They look good.  That code certainly need some
> cleaning up.
> 
> I didn't get 6/8.  Could you resend?

Done.

> Patch 5/8 removes a number of comments without adding any.
>  Do you think it would be valuable to add a comment explaining the
>  subtleties for why directories and files are handled differently.

To me the new code was clear enough to explain what's going on, but
I can send another patch ontop of the patch series adding and updating
some comments. 

> Patch 8/8 I should look through again to make sure all the dentry
> references look right (I found them easy to get wrong).  Splitting up
> find_exported_dentry was definitely a good idea.
> You left in a comment in "If we weren't after a directory" in a place
> were we know we weren't, so at least it should be "Since we
> weren't....".

Yes.  I noticed this and remove it in an so far unsubmitted patch later
in the series, but it really should be in that patch.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
