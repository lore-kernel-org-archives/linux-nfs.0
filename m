From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Fri, 10 Nov 2006 15:25:21 -0500
Message-ID: <20061110202521.GE9453@fieldses.org>
References: <20061106231539.GI12372@fieldses.org>
	<20061106231615.GA17582@uio.no>
	<20061106231821.GK12372@fieldses.org>
	<20061106232224.GL12372@fieldses.org>
	<20061106234607.GA18236@uio.no>
	<20061106234922.GM12372@fieldses.org>
	<20061107004720.GA16731@uio.no>
	<20061108004440.GL11346@fieldses.org>
	<20061108005045.GA4524@uio.no>
	<4d569c330611101211y4846d2b2l2ad4be385688deff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GicwJ-00055F-MB
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 12:25:27 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GicwJ-0007ym-FC
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 12:25:28 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330611101211y4846d2b2l2ad4be385688deff@mail.gmail.com>
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

On Fri, Nov 10, 2006 at 03:11:31PM -0500, Kevin Coffman wrote:
> I didn't find any clues in the strace output either.  I'm not sure
> where to look next.

Well, if we're seeing a NO_CONTEXT error on the wire, and if (as is
apparent from the strace), svcgssd isn't itself sending a NO_CONTEXT
error down, then you must be correct that it's coming from
gss_write_init_verf().

So gss_svc_searchbyctx() is returning NULL.

I wonder if the kmalloc() in dup_to_netobj() is failing?  If it was
caused by a memory leak of some kind, that would explain why it takes a
while for the problem to show up, but not why restarting rpc.svcgssd
would help.

But the only other possibilities are that rsc_lookup() or cache_check()
are failing, and I don't see how that can happen when the previous
context downcall succeeded (as I believe the strace showed it did),
unless there's a bug in the cache code.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
