From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Mon, 6 Nov 2006 18:15:39 -0500
Message-ID: <20061106231539.GI12372@fieldses.org>
References: <20061031001248.GA19915@uio.no>
	<4d569c330610302053k2c9644b7ge2dfb862ce274af3@mail.gmail.com>
	<20061031100346.GA2906@uio.no>
	<4d569c330610310543r429f0b4fk1dcdfa44836026c2@mail.gmail.com>
	<20061031143248.GA8444@uio.no> <20061103123737.GA5199@uio.no>
	<4d569c330611061508g5e9044cdy36d87ae2ac03952d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhDgt-0000Jz-Kf
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:15:43 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhDgt-00036S-Ie
	for nfs@lists.sourceforge.net; Mon, 06 Nov 2006 15:15:44 -0800
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
> Hello Steinar,
> The userland messages from svcgssd all indicate it is happy and is
> sending down a context to the kernel.  The packet trace shows that the
> kernel is replying to the NULL call with GSS_S_NO_CONTEXT.  This can
> be returned by the kernel if it is unable to find the context that was
> (supposedly) sent down from svcgssd.
> 
> It is a mystery to me why this is happening.  Especially mysterious is
> that restarting svcgssd clears it up.  Can you check to see if there
> are memory or other resource problems with svcgssd when it stops
> working?

I wonder if it'd also be interesting to see the kernel/svcgssd
interactions when it's failing.  If there's strace options that'll give
you all the I/O data.....

>From the strace man page: it looks like

	strace -oTMP -e read=a,b,c -e write=a,b,c pid-of-svcgssd

should do it, where a, b, c... are the file descriptors of any of the
files named "channel" under /proc/net/rpc.  You can find those file
descriptors with

	ls -l /proc/pid-of-scgssd/fd/ |grep channel

Fun.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
