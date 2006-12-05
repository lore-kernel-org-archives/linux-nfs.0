From: "Fredrik Lindgren" <fli@swip.net>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Tue, 05 Dec 2006 12:09:14 +0100
Message-ID: <37b13306c6b2f0469e1f8ce63a6a6706@swip.net>
References: <1164395516.5702.53.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrYAv-0001xK-0v
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 03:09:25 -0800
Received: from mailfe08.swip.net ([212.247.154.225] helo=swip.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GrYAv-000158-G5
	for nfs@lists.sourceforge.net; Tue, 05 Dec 2006 03:09:25 -0800
In-Reply-To: <1164395516.5702.53.camel@lade.trondhjem.org>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Kasparek Tomas" <kasparek@fit.vutbr.cz>
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

> > > > > As I wrote before, it does not depend on the server 
> > > > > (tried with FreeBSD server and several versions of
> > > > > linux 2.6.16.x and 2.6.18.x).
> > > > 
> > > > Just update: 2.6.17.14 is ok
> > > 
> > > did git bisect between 2.6.17 and 2.6.18 and found that 
> > > the commit is:
> > > 
> > > 44b11874ff583b6e766a05856b04f3c492c32b84
> > >  NFS: Separate metadata and page cache revalidation mechanisms
> > > 
> > > will verify (with and without patch) tomorrow.
> > 
> > 2.6.18.3 with reversed 
> > 44b11874ff583b6e766a05856b04f3c492c32b84 is OK.
> > 
> > exact patch used included.
> 
> If you are not using any form of synchronisation, then your test would
> appear to be violating the close-to-open cache consistency rules (see
> http://nfs.sourceforge.net/#faq_a8).

Hello,

I have tested our application (CommuniGate Pro) with 2.6.18.3 with
Mr. Kaspareks patch applied and I'm seeing no corruption after several
days of uptime. Without the patch I usually see bogus data in in some
files within an hour.

Also, anyone has any input in why 2.6.18.3 (both with and without
Mr Kaspareks patch) does about half the amount of GETATTR calls
compared to 2.6.13 with our application? Is this an indended change?
Not that I'm complaining or anything, but it would be nice to know
that it was intentional :)

Wheter CGP voilates the "close-to-open cache consistency rules" or not,
I don't know. but the fact is that it works with a stock 2.6.13 and 
2.6.18.3 sans patch 44b11874ff583b6e766a05856b04f3c492c32b84, it breaks
on 2.6.18.3.

Regards,
  Fredrik Lindgren




-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
