From: bnies@bluewin.ch
Subject: Re: ls hangs on NFS share from Apple Xserve
Date: Thu, 9 Sep 2004 10:08:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412EBAA10006C9F4@mssbzhh-int.msg.bluewin.ch>
References: <1094682603.8363.71.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5JzA-0007EM-28
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 01:08:52 -0700
Received: from mail5.bluewin.ch ([195.186.1.207])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5Jz9-0004E5-1M
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 01:08:51 -0700
Received: from mssbzhh-int.msg.bluewin.ch (195.186.4.230) by mail5.bluewin.ch (Bluewin AG 7.0.030.2)
        id 412F8F2D0018A0ED for nfs@lists.sourceforge.net; Thu, 9 Sep 2004 08:08:36 +0000
In-Reply-To: <1094682603.8363.71.camel@lade.trondhjem.org>
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

Hi Trond,

>They probably do not rely exclusively on the cookie to track where they
>are in the READDIR stream: for instance it is possible to cache the
>filename too, and to use that as a backup solution if the server is
>being cranky.
>We could possibly add this sort of information to Linux too.

That's probably a good idea. At least the network file system connecting
each flavours of Unix should be consistent and reliable. Maybe this bug also
exists in other BSD derivates. Sun developed NFS. Is the Solaris client and
server code available?

I filed a bug in OpenDarwins Bugzilla:

http://www.opendarwin.org/bugzilla/show_bug.cgi?id=2201

Seems that Mac OS X NFS implementation is a kind of buggy, because I found
other problems with it:

http://discussions.info.apple.com/webx?14@246.XlfoaVdSw0s.2@.6899e34d
http://discussions.info.apple.com/webx?14@246.XlfoaVdSw0s.2@.6899e2eb
http://discussions.info.apple.com/webx?14@246.XlfoaVdSw0s.0@.6899e444

Regards,
Bernd



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
