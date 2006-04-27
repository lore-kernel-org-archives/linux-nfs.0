From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Update: NFS over a Win2k Server NAT Router with
	"DMZ":nfs: server not responding, still trying
Date: Thu, 27 Apr 2006 14:26:23 -0400
Message-ID: <1146162383.8101.30.camel@lade.trondhjem.org>
References: <005401c66a19$2a6f6d30$0200a8c0@novastorm>
	 <000401c66a21$154a8c70$0200a8c0@novastorm>
	 <1146160972.8101.12.camel@lade.trondhjem.org>
	 <001101c66a26$adfb58f0$0200a8c0@novastorm>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZBCD-0000eK-Nr
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:26:33 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FZBCD-000775-Ms
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:26:33 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FZBCD-0007wP-4M
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 11:26:33 -0700
To: Michael Lackner <thrawn@xin.at>
In-Reply-To: <001101c66a26$adfb58f0$0200a8c0@novastorm>
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

On Thu, 2006-04-27 at 20:16 +0200, Michael Lackner wrote:

> I'm afraid, the nfs server on "fileserver" doesn't even support tcp. There should be
> experimental tcp support for nfs in kernel 2.4.20 already, but i don't know if this 
> feature is activated in RH9. How can i check if my nfs server supports tcp and how 
> can i activate tcp, if so? By default, nfsd runs only on udp on that machine.

If TCP support has been compiled into the kernel, then it should be
running, in which case 'rpcinfo -t <server> nfs' should confirm it.

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
