From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Tue, 7 Nov 2006 00:44:20 +0100
Message-ID: <20061106234420.GA18124@uio.no>
References: <20061031001248.GA19915@uio.no>
	<4d569c330610302053k2c9644b7ge2dfb862ce274af3@mail.gmail.com>
	<20061031100346.GA2906@uio.no>
	<4d569c330610310543r429f0b4fk1dcdfa44836026c2@mail.gmail.com>
	<20061031143248.GA8444@uio.no> <20061103123737.GA5199@uio.no>
	<4d569c330611061508g5e9044cdy36d87ae2ac03952d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhE9g-0002ya-7p
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:45:28 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhE9g-0003vm-5C
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:45:29 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330611061508g5e9044cdy36d87ae2ac03952d@mail.gmail.com>
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

On Mon, Nov 06, 2006 at 06:08:49PM -0500, Kevin Coffman wrote:
> It is a mystery to me why this is happening.  Especially mysterious is
> that restarting svcgssd clears it up.  Can you check to see if there
> are memory or other resource problems with svcgssd when it stops
> working?

The machine has 2GB of RAM (plus plenty of free swap), and in general
everything else chugs happily along. I'm not sure what kind of other resource
problems there would be :-)

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
