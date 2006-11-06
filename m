From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Mon, 6 Nov 2006 18:49:22 -0500
Message-ID: <20061106234922.GM12372@fieldses.org>
References: <20061031100346.GA2906@uio.no>
	<4d569c330610310543r429f0b4fk1dcdfa44836026c2@mail.gmail.com>
	<20061031143248.GA8444@uio.no> <20061103123737.GA5199@uio.no>
	<4d569c330611061508g5e9044cdy36d87ae2ac03952d@mail.gmail.com>
	<20061106231539.GI12372@fieldses.org>
	<20061106231615.GA17582@uio.no>
	<20061106231821.GK12372@fieldses.org>
	<20061106232224.GL12372@fieldses.org>
	<20061106234607.GA18236@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhEDU-0003Kq-3r
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:49:24 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhEDV-0004pW-13
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:49:25 -0800
To: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
In-Reply-To: <20061106234607.GA18236@uio.no>
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

On Tue, Nov 07, 2006 at 12:46:07AM +0100, Steinar H. Gunderson wrote:
> On Mon, Nov 06, 2006 at 06:22:24PM -0500, J. Bruce Fields wrote:
> > I just looked back through my mail and can find sysrq-t and tcpdump
> > output, but no strace output.  Did you send it and I lost it?
> 
> http://home.samfundet.no/~sesse/svcgssd-strace.log.bz2

bfields@puzzle:~$ wget http://home.samfundet.no/~sesse/svcgssd-strace.log.bz2
--18:48:38--  http://home.samfundet.no/~sesse/svcgssd-strace.log.bz2
           => `svcgssd-strace.log.bz2'
Resolving home.samfundet.no... 129.241.93.17, 2001:700:300:1800::1917
Connecting to home.samfundet.no|129.241.93.17|:80... connected.
HTTP request sent, awaiting response... 404 Not Found
18:48:39 ERROR 404: Not Found.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
