From: Wichert Akkerman <wichert@wiggy.net>
Subject: mountd getfh failure
Date: Wed, 6 Aug 2003 11:21:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030806092122.GB3069@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from home.wiggy.net ([213.84.101.140] helo=thunder.home.wiggy.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:RC4-SHA:128) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kKUW-0008HK-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Aug 2003 02:21:56 -0700
Received: from wichert by thunder.home.wiggy.net with local (Exim 4.20)
	id 19kKTy-0002BR-BI
	for nfs@lists.sourceforge.net; Wed, 06 Aug 2003 11:21:22 +0200
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I'm struggling with a problem with nfsd in 2.6.0-test2. Yesterday I had
some problems with nfsd, but trying to reproduce them today I found that
mountd no longer works: when I try to mount a NFS export from another
machine I get the following in my syslog:

Aug  6 11:11:34 thunder rpc.mountd: authenticated mount request from tornado.home.wiggy.net:857 for /home (/home)
Aug  6 11:11:34 thunder rpc.mountd: getfh failed: Operation not permitted

A strace of rpc.mountd confirms the problem:

nfsservctl(0x8, 0xbfffdcb0, 0x8057ba0)  = -1 EPERM (Operation not permitted)

I'm a bit at a loss as to what the problem is here..

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
