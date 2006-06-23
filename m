From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Requesting opinions for nfs-clustering.
Date: Fri, 23 Jun 2006 15:46:47 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606231544010.1092@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtrcA-0005SR-6m
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 12:46:50 -0700
Received: from lucidpixels.com ([66.45.37.187] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ftrc9-0006Nf-59
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 12:46:50 -0700
Received: from localhost (localhost [127.0.0.1])
	by lucidpixels.com (Postfix) with ESMTP id 8D9A81615BD6E
	for <nfs@lists.sourceforge.net>; Fri, 23 Jun 2006 15:46:47 -0400 (EDT)
To: nfs@lists.sourceforge.net
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

Hello all,

I was wondering what is the best way to serve out files in a sort of 
clustered NFS environment.

Idea:

Master NFS server -> synca ->
                   -> syncb ->-> [vip] <-> clients
                   -> syncc ->-> [vip] <-> clients
                   -> syncd ->

What is the best way to approach this problem?  The NFS servers would be 
hosted in multiple data centers and they all share the same exact files, 
however, if one server goes down, it cannot require a client to unmount 
and remount the share in order to get it working again.

Has anyone dealt with a similar project like this before?

Thanks,

Justin.


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
