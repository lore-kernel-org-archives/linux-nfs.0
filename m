From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Fri, 10 Nov 2006 16:41:40 -0500
Message-ID: <20061110214140.GG9453@fieldses.org>
References: <20061106234607.GA18236@uio.no>
	<20061106234922.GM12372@fieldses.org>
	<20061107004720.GA16731@uio.no>
	<20061108004440.GL11346@fieldses.org>
	<20061108005045.GA4524@uio.no>
	<4d569c330611101211y4846d2b2l2ad4be385688deff@mail.gmail.com>
	<20061110202521.GE9453@fieldses.org>
	<4d569c330611101239v46a8e444u15aa06433259d220@mail.gmail.com>
	<20061110204917.GF9453@fieldses.org>
	<4d569c330611101337g6f7bfd3ex2e6d347d5b030e98@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gie8B-0003yV-Ep
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 13:41:47 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gie8B-0004jd-Do
	for nfs@lists.sourceforge.net; Fri, 10 Nov 2006 13:41:48 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330611101337g6f7bfd3ex2e6d347d5b030e98@mail.gmail.com>
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

On Fri, Nov 10, 2006 at 04:37:32PM -0500, Kevin Coffman wrote:
> svcgssd actually fopens and fcloses the context channel and opens and
> closes the init channel for each downcall.  So I don't see how that
> would affect it either?

That's true for the context channel, but for the init channel, it
actually does have a file descriptor open all the time.  (It may open
and close a second one when it makes a downcall, I don't remember.)

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
