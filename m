From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: userspace NFS daemon
Date: Mon, 06 Sep 2004 16:08:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094501305.8342.118.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0409062120550.19152-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Frank van Maarseveen <frankvm@xs4all.nl>, Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4PnB-00065D-Qn
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 13:08:45 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C4PnB-0001CQ-0P
	for nfs@lists.sourceforge.net; Mon, 06 Sep 2004 13:08:45 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0409062120550.19152-100000@kenzo.iwr.uni-heidelberg.de>
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

P=E5 m=E5 , 06/09/2004 klokka 15:35, skreiv Bogdan Costescu:

> As in Unix tradition, there are several ways to achieve the same goal. =20
> There are people using 'mount -o bind' (like RHEL's diskless booting
> setup procedure) or hard-links (what I use). But both of these require
> some maintenance effort in form of scripts and a general cleanliness
> in handling software updates or new installs. With clusternfs, the
> files are created in their place with their intended destination in
> the name and the daemon takes care of the rest... There are people
> that prefer to concentrate on science rather than system
> administration. :-)

Hey, it's a free world.

However please beware that most of the hacks that worked around the
non-rfc-compliant behaviours of unfsd are long since gone from the
kernel and will not be coming back.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
