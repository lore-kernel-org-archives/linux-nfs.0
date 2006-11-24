From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Fri, 24 Nov 2006 14:11:55 -0500
Message-ID: <1164395516.5702.53.camel@lade.trondhjem.org>
References: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
	<20061123161738.GF40079@fit.vutbr.cz>
	<20061123172456.GG40079@fit.vutbr.cz>
	<20061123213311.GH40079@fit.vutbr.cz>
	<20061124064752.GI40079@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GngTA-0003AB-6m
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 11:12:16 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+mtp2Xd2jtS95LiUEzdxX9t2PeqtxI1v4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GngT8-0006ZD-Vu
	for nfs@lists.sourceforge.net; Fri, 24 Nov 2006 11:12:17 -0800
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
In-Reply-To: <20061124064752.GI40079@fit.vutbr.cz>
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

On Fri, 2006-11-24 at 07:47 +0100, Kasparek Tomas wrote:
> On Thu, Nov 23, 2006 at 10:33:11PM +0100, Kasparek Tomas wrote:
> > On Thu, Nov 23, 2006 at 06:24:56PM +0100, Kasparek Tomas wrote:
> > > On Thu, Nov 23, 2006 at 05:17:38PM +0100, Kasparek Tomas wrote:
> > > > 
> > > > > >have seen this behaviour with kernel 2.6.18 and above up to 19-rc4.
> > > > > > Reported this, but no response.
> > > > > > 
> > > > > > http://lkml.org/lkml/2006/9/28/89
> > > > >
> > > > > Your test script doesn't use any form of locking. How are you ensuring
> > > > > that only one client has the file open at a time?
> > > > 
> > > > I use no locking at all, it's just synthetic test, I don't expect data to
> > > > be ordered or whatever, but the problem is blocks of zeros inserted.
> > > > It behaves right with the last 2.6.16.32, zeros are contained if clients
> > > > are 2.6.18.3 and 2.6.19-rc4. 
> > > > 
> > > > I'm going to do more testing in next few days, so hoe bring some new info.
> > > > 
> > > > As I wrote before, it does not depend on the server (tried with FreeBSD
> > > > server and several versions of linux 2.6.16.x and 2.6.18.x).
> > > 
> > > Just update: 2.6.17.14 is ok
> > 
> > did git bisect between 2.6.17 and 2.6.18 and found that the commit is:
> > 
> > 44b11874ff583b6e766a05856b04f3c492c32b84
> >  NFS: Separate metadata and page cache revalidation mechanisms
> > 
> > will verify (with and without patch) tomorrow.
> 
> 2.6.18.3 with reversed 44b11874ff583b6e766a05856b04f3c492c32b84 is OK.
> 
> exact patch used included.

If you are not using any form of synchronisation, then your test would
appear to be violating the close-to-open cache consistency rules (see
http://nfs.sourceforge.net/#faq_a8).

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
