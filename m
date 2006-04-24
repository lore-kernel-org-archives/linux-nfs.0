From: "Madhan P" <PMadhan@novell.com>
Subject: Can nfs lock can be upgraded ?
Date: Mon, 24 Apr 2006 00:12:32 -0600
Message-ID: <444CB945.C935.0084.0@novell.com>
References: <4445EA51020000840002C088@lucius.provo.novell.com> <444CB9A8020000840000B796@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FXuI8-0007iO-Rw
	for nfs@lists.sourceforge.net; Sun, 23 Apr 2006 23:11:24 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FXuI8-00037O-OR
	for nfs@lists.sourceforge.net; Sun, 23 Apr 2006 23:11:24 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FXuI6-0000eg-E3
	for nfs@lists.sourceforge.net; Sun, 23 Apr 2006 23:11:24 -0700
To: <nfs@lists.sourceforge.net>
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

Hi All,

Have a query, over which a definitive statement in standard material
seems to be hard to trace.  Hope people on the list can throw some light
on this.  Have a situation where, (this is all with nfs version 3)

- client asks for non-exclusive lock of a certain file handle.  range
is the entire file.
- server grants the lock.
- client asks for an exclusive lock of the same file, entire file. 
uses a different cookie than the first lock request.
- server denies the lock, as a exclusive lock cannot be granted on a
file that is already non-exclusively locked.  (The only multiple locks
that can exists must all be non-exclusive).
- client asks to unlock the file.
- server grants the unlock.
- client starts the same process over.

The clients versions, that reported this behaviour include,
- Linux diablo 2.6.13-15.8-default
- SunOS csns28 5.9 Generic_112233-12 sun4u sparc

This seems to be fine and working as expected.  But, in a situation
where, server has granted a non-exclusive lock to the client, and if
that is the only client holding a non-exclusive lock - Is/Can the server
be expected to allow the upgrade of non-exclusive lock to an exclusive
lock without going thro' a release of the non-exclusive lock ?

Any thoughts / inputs on this are welcome.

Thanks & Regards,
Madhan.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
