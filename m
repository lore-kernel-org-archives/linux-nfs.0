From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [BUG] All Kerberos mounts stop working,
	restarting rpc.svcgssd helps
Date: Tue, 31 Oct 2006 15:32:48 +0100
Message-ID: <20061031143248.GA8444@uio.no>
References: <20061031001248.GA19915@uio.no>
	<4d569c330610302053k2c9644b7ge2dfb862ce274af3@mail.gmail.com>
	<20061031100346.GA2906@uio.no>
	<4d569c330610310543r429f0b4fk1dcdfa44836026c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Geugj-0008S9-BF
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 06:34:01 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Geugf-0003iw-Uc
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 06:34:02 -0800
To: Kevin Coffman <kwc@citi.umich.edu>
In-Reply-To: <4d569c330610310543r429f0b4fk1dcdfa44836026c2@mail.gmail.com>
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

On Tue, Oct 31, 2006 at 08:43:47AM -0500, Kevin Coffman wrote:
> When you say existing mounts stop working, do you mean that data is no
> longer available on those existing mounts, or that new connections
> requiring new contexts via svcgssd stop working?

Data is no longer available on those existing mounts. In fact, if I run ls
-ld on the mount point, it is suddenly owned by the user and group "?".

> Could you send a packet trace from the server after mounts stop
> working?  (tcpdump -s 0 -w /tmp/x)  Also, if it is enabled, could you
> get the output from sysRq-T?

I'll be sure to grab the data next time the problems occur.

By the way, I also have an strace log available; but it's rather large-ish:

  http://home.samfundet.no/~sesse/svcgssd-strace.log.bz2

Note that it's not the same invocation as the previous log I sent you.

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
