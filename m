From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Tue, 31 Oct 2006 11:03:46 +0100
Message-ID: <20061031100346.GA2906@uio.no>
References: <20061031001248.GA19915@uio.no>
	<4d569c330610302053k2c9644b7ge2dfb862ce274af3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GeqUH-0000VB-5L
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 02:04:54 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GeqUG-0001Gy-Tt
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 02:04:54 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330610302053k2c9644b7ge2dfb862ce274af3@mail.gmail.com>
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

On Mon, Oct 30, 2006 at 11:53:02PM -0500, Kevin Coffman wrote:
> Hello Steinar,
> I don't see anything in the svcgssd output indicating there was any
> kind of error.

Me neither, that's why it's so odd. :-)

> When you say "packets fly back and forth, but mount simply refuses",
> is there any kind of delay (i.e. 30 second timeout) or does the mount
> fail pretty quickly?  Do you see the "typical" error message(s) from
> mount?

The mount fails immediately, IIRC with simply "Permission denied". Also,
existing mounts stop working (usually, they hang).

> What kernel is this with?

Mostly 2.6.17 and 2.6.18 on the clients; 2.6.17.11 on the server.

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
