From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 002 of 9] knfsd: knfsd: Remove an unused variable
	from e_show().
Date: Tue, 25 Jul 2006 14:20:14 +1000
Message-ID: <17605.39934.963857.665398@cse.unsw.edu.au>
References: <20060725114207.21779.patches@notabene>
	<1060725015432.21921@suse.de>
	<20060725041059.GA13294@filer.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5EPi-0007v6-Qg
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:20:58 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5EPi-0001U7-O7
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:20:59 -0700
To: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
In-Reply-To: message from Josef Sipek on Tuesday July 25
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

On Tuesday July 25, jsipek@fsl.cs.sunysb.edu wrote:
> On Tue, Jul 25, 2006 at 11:54:32AM +1000, NeilBrown wrote:
> ...
> > diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
> > --- .prev/fs/nfsd/export.c	2006-07-24 14:33:06.000000000 +1000
> > +++ ./fs/nfsd/export.c	2006-07-24 14:33:26.000000000 +1000
> > @@ -1178,7 +1178,6 @@ static int e_show(struct seq_file *m, vo
> ...
> >  	if (p == (void *)1) {
> 
> I'm not an NFS expert, but the above makes me want to puke. Isn't there a
> cleaner way of doing whatever needs to be done without:
> 
> 1) hard-coding a constant
> 2) comparing a variable to an arbitrary pointer
> 

Probably.  We just need a pointer value that is definitely not a
pointer to a valid cache_head object, and is not NULL.
(void*)1 seems a reasonable choice, but maybe #defineing something
would help.

Patches welcome.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
