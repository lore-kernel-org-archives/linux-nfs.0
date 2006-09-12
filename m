From: Martin Wegner <mailing-lists@mroot.net>
Subject: nfssvc: Address already in use
Date: Tue, 12 Sep 2006 02:57:24 +0200
Message-ID: <450605F4.1060806@mroot.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GMxYA-0002QI-CV
	for nfs@lists.sourceforge.net; Mon, 11 Sep 2006 18:58:58 -0700
Received: from daemo09.udag.de ([62.146.33.133] helo=mail.udag.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GMxY4-0005sO-3r
	for nfs@lists.sourceforge.net; Mon, 11 Sep 2006 18:58:57 -0700
Received: from [192.168.1.23] (p5485A93E.dip0.t-ipconnect.de [84.133.169.62])
	by mail.udag.de (Postfix) with ESMTP id 2F02E7F73
	for <nfs@lists.sourceforge.net>; Tue, 12 Sep 2006 02:57:25 +0200 (CEST)
To: nfs <nfs@lists.sourceforge.net>
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

Hello.

Whenever I try to start a NFS daemon on my Gentoo box here, I get the
following error in the logfile:

Sep 12 02:45:01 ares nfsd[17564]: nfssvc: Address already in use

Nothing more.

This error occured due to the switch of the kernel version from 2.6.15
to latest 2.6.17.* . During this change nothing of the programs, ... has
changed.

If I boot the old kernel 2.6.15 everything works fine again with the
same config, programs, ...

I made an manual call to rpc.nfsd:

/usr/sbin/rpc.nfsd 8

and ran it with strace, the result was this strace log:
http://files.mgeek.de/nfsd.strace

Some info:

NFS Server version 3

Kernel options:
<*> NFS file system support
[*]   Provide NFSv3 client support
<*> NFS server support
[*]   Provide NFSv3 server support
[*]   Provide NFS server over TCP support

nfs-utils-1.0.10

I really can't see where the problem is located so I'm appreciating any
help ...
If you need any more information, please let me know, I'll provide it as
soon as possible.

TIA, martin

-- 
Get my public GPG key from pgp.mit.edu or wwwkeys.pgp.net
Key ID: 0x44085D12
--
Homepage: http://mroot.net/
Powered by Gentoo Linux (http://gentoo.org/)


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
