From: "John Roberts" <john_roberts@credence.com>
Subject: Linux NFS writes to Solaris very, very slow
Date: Fri, 23 Jul 2004 09:20:34 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407231620.i6NGKYV20945@algebra.hillsboro.credence.com>
Reply-To: John Roberts <john_roberts@credence.com>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=us-ascii
Cc: john_roberts@credence.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bo2ml-0006jI-15
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 09:20:39 -0700
Received: from hifw1.credence.com ([63.127.103.172] helo=hinscp.hillsboro.credence.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bo2mk-0008Gq-Kh
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 09:20:38 -0700
To: nfs@lists.sourceforge.net
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


Hi there,

I work in Hillsboro, Oregon, USA for Credence Systems Corporation (as a
software engineer) and we use the Redhat Enterprise 3 (2.4.21 kernel,
a Redhat hodgepodge with some 2.6 stuff) distribution on our
x86 PCs.

We're on a network with lots of Sun systems and a central file
server that is a Veritas cluster of twin SunFire servers running
Solaris 2.8.

What we've observed is that NFS writes from our Linux boxes to
the Solaris server (and other Solaris workstations) is _very_
slow.  Reads seem to be operating at a reasonable speed.
FTP speeds are blazing (protocol below NFS).

On a completely seperate note, Linux-to-Linux NFS file writes
only seem to be fast if we publish the serving Linux volume
as asynchronous (default setting is synchronous which is slow).

I'm curious if anyone has any ideas on what I should do regarding
the slow nature of Linux clients to Solaris servers over NFS?
I don't know if anybody has encountered this or if anyone in the
Linux kernel community is looking at it.

Any thoughts/advice would be _greatly_ appreciated.

thanks,


John Roberts
john_roberts@credence.com




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
