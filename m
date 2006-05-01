From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: reason for mountd upcall
Date: Mon, 01 May 2006 11:11:26 -0400
Message-ID: <1146496287.9068.8.camel@lade.trondhjem.org>
References: <20060501134401.21390.qmail@web51615.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Faa3r-0004be-7F
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 08:11:43 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Faa3r-0001YE-31
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 08:11:43 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Faa3p-0005LT-JE
	for nfs@lists.sourceforge.net; Mon, 01 May 2006 08:11:43 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060501134401.21390.qmail@web51615.mail.yahoo.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, 2006-05-01 at 06:44 -0700, mehta kiran wrote:
> Hi,
>      I see number of files in nfsd filesystem which
>      are readable and writable by user processes
>      like rpc.mountd(for upcalls).
>      Looks like same thing can be  done in kernel.
>      Is this only to move some
>      complex code from kernel to userland ?

Why on earth would we want to put crap like reverse DNS, NIS, LDAP,
kerberos, ... in the kernel?

Cheers,
   Trond



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
