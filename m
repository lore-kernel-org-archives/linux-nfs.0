From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd problem
Date: Sun, 07 May 2006 00:38:26 -0400
Message-ID: <1146976706.14133.63.camel@lade.trondhjem.org>
References: <OFE9A5A9E8.C1D26EA2-ON88257166.00166EDC-88257166.001B37A9@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fd9OT-0004ML-SQ
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:19:37 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1Fcb2j-0002I7-RH
	for nfs@lists.sourceforge.net; Sat, 06 May 2006 21:38:53 -0700
Received: from pat.uio.no ([129.240.10.6] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Fcb2h-0002ir-J4
	for nfs@lists.sourceforge.net; Sat, 06 May 2006 21:38:53 -0700
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFE9A5A9E8.C1D26EA2-ON88257166.00166EDC-88257166.001B37A9@us.ibm.com>
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

On Fri, 2006-05-05 at 22:01 -0700, Marc Eshel wrote:
> Hi Trond,
> I see a problem testing lockd with 2.6.16-CITI_NFS4_ALL-2,  I see that you 
> made few changes in lockd, so let me describe it and see if can recall any 
> changes that might cause the following problem.
> 
> I think that the source of the problem is that 2 clients from 2 different 
> machine end up with the same fl_pid on the lockd server.

It looks as if nlmsvc_lookup_block() fails to check the ip address of
the request. That is not a new bug: it has been there for a few years...

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
