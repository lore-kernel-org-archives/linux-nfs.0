From: Matt C <wago@phlinux.com>
Subject: NFS attrib cache problems in 2.4.20 - 2.4.22-pre9
Date: Thu, 31 Jul 2003 13:58:40 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0307311351050.17863-100000@fubar.phlinux.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: cel@citi.umich.edu, <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from fubar.phlinux.com ([216.254.54.154])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iKVc-0005N5-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 13:58:48 -0700
To: NFS List <nfs@lists.sourceforge.net>
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

Hi NFS List, chuck, trond:

I have a fun NFS problem with the recent 2.4 kernel NFS client. We have an 
application that is failing when it tries to move then open a file in very 
quick succession -- it fails because it can't find the file in the new 
location.

Since we can't export our application out to the 'net, I've been doing 
testing with fsx-linux, which also fails in the same scenario with what 
looks like an attribute cache issue. The exact FSX error is
"Size error:  expected 0x1803ca stat 0x1803ca seek 0x68bf4c".

This fails with the 3 kernels that I tested: 2.4.20, 2.4.21 and 
2.4.22-pre9. When I add 'noac' to my mount flags on the client, the 
problem goes away.

I've written this up on the following page, with links to the complete FSX 
log, as well as complete kernel debug messages and the kernel .config 
file.

http://www.phlinux.com/kernel/nfs-ac.html

I've been talking with Chuck Lever about this over the past few days, and 
he suggested that I post here once I had good debug information. I'm happy 
to run any other tests and/or capture other information if it's helpful.

Thanks!

-matt



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
