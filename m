From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 002 of 9] knfsd: knfsd: Remove an unused
	variable	from e_show().
Date: Tue, 25 Jul 2006 14:24:56 +1000
Message-ID: <1153801496.1547.652.camel@hole.melbourne.sgi.com>
References: <20060725114207.21779.patches@notabene>
	<1060725015432.21921@suse.de>
	<20060725041059.GA13294@filer.fsl.cs.sunysb.edu>
	<17605.39934.963857.665398@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Josef Sipek <jsipek@fsl.cs.sunysb.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5ETl-0008Ir-Vm
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:25:10 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5ETl-0004iu-7o
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 21:25:10 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17605.39934.963857.665398@cse.unsw.edu.au>
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

On Tue, 2006-07-25 at 14:20, Neil Brown wrote:
> On Tuesday July 25, jsipek@fsl.cs.sunysb.edu wrote:
> > On Tue, Jul 25, 2006 at 11:54:32AM +1000, NeilBrown wrote:
> > ...
> > > diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
> > > --- .prev/fs/nfsd/export.c	2006-07-24 14:33:06.000000000 +1000
> > > +++ ./fs/nfsd/export.c	2006-07-24 14:33:26.000000000 +1000
> > > @@ -1178,7 +1178,6 @@ static int e_show(struct seq_file *m, vo
> > ...
> > >  	if (p == (void *)1) {
> > 
> > I'm not an NFS expert, but the above makes me want to puke. Isn't there a
> > cleaner way of doing whatever needs to be done without:
> > 
> > 1) hard-coding a constant
> > 2) comparing a variable to an arbitrary pointer
> > 
> 
> Probably.  We just need a pointer value that is definitely not a
> pointer to a valid cache_head object, and is not NULL.
> (void*)1 seems a reasonable choice, but maybe #defineing something
> would help.

include/linux/seq_file.h:

#define SEQ_START_TOKEN ((void *)1)

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
