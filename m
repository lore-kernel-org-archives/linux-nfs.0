From: "Peter Flanders" <pflanders@clarkisland.com>
Subject: TCP Multi-Kernel oops
Date: Fri, 20 Dec 2002 20:38:21 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBEEKHCKAA.pflanders@clarkisland.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <bob.schwaegler@clarkisland.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18PbPB-0004ZA-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Dec 2002 20:38:29 -0800
To: "NFS" <nfs@lists.sourceforge.net>
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

Hi All,

I spent the day having a Debian 3.0 stable machine oops on me over and over
with several different kernels. Here's the deal:

-Dual Xeon 2.4Ghz SuperMicro system with 2.0GB of ram serving NFS v3 over
TCP.
-MPS and UniPS kernels tested with and without high memory support.
-Filesystem is EXT3, default mount options, default filesystem make options
-Clients are Compaq Tru64 version 5.1.
-On connect, clients cause kernel to give hundreds of the following console
messages:

bad tcp reclen 0x0000808c (large)

(the 0x000... address sometimes is different)

And then it eventually gives and oops and crashes. I sometimes also get the
following message, but only once or twice prior to crash:

nfsd: accept failed (err 22)!

Summary of what I tried:

Kernel 2.4.18 with all neil brown patches - crashed
Kernel 2.4.19 with all neil brown patches - crashed
Kernel 2.4.20 with all neil brown patches - crashed
Kernel 2.4.21-pre2 vanilla - crashed
Kernel 2.4.18 with trond m all patch - seems to be working ok for now.
Kernel 2.4.19 with trond m all patch - was sort of stable but crashed
Kernel 2.4.20 with trond m all patch - was sort of stable but crashed

>From what I can tell, it looks like Neil Brown has tried to address this
issue where the client sends out a large TCP fragment, but even with that
patch specifically applied, the system still crashes with an oops.

I understand that NFS over TCP is not currently well supported in Linux, but
I need to get a stable system put together as all of our clients are Tru64
and they *must* use TCP. UDP is not an option for us.

Thanks in advance!

Peter

ps - I don't know how to capture and oops yet so I didn't.




-------------------------------------------------------
This SF.NET email is sponsored by:  The Best Geek Holiday Gifts!
Time is running out!  Thinkgeek.com has the coolest gifts for
your favorite geek.   Let your fingers do the typing.   Visit Now.
T H I N K G E E K . C O M        http://www.thinkgeek.com/sf/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
