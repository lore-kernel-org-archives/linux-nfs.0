From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS attrib cache problems in 2.4.20 - 2.4.22-pre9
Date: 01 Aug 2003 08:42:41 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsel05dgke.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0307311351050.17863-100000@fubar.phlinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS List <nfs@lists.sourceforge.net>,  cel@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iTcr-0003km-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 23:42:53 -0700
To: Matt C <wago@phlinux.com>
In-Reply-To: <Pine.LNX.4.44.0307311351050.17863-100000@fubar.phlinux.com>
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

>>>>> " " == Matt C <Matt> writes:

     > Hi NFS List, chuck, trond: I have a fun NFS problem with the
     > recent 2.4 kernel NFS client. We have an application that is
     > failing when it tries to move then open a file in very quick
     > succession -- it fails because it can't find the file in the
     > new location.

It's a known issue. mmap() writes appear to be screwed up
w.r.t. truncate. I still don't have a proper solution for this
problem since it appears to be more of a VM bug than a NFS one.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
