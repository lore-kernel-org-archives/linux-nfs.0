From: Brad Barnett <lists@L8R.net>
Subject: knfsd brought to its knees, by a simple rsync or cp operation
Date: Sat, 26 Feb 2005 08:28:54 -0500
Message-ID: <20050226082854.2a496ec3@be.back.l8r.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5208-0006m0-Tk
	for nfs@lists.sourceforge.net; Sat, 26 Feb 2005 05:28:56 -0800
Received: from l8r.net ([64.26.155.43] ident=aliens)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D5208-0003g9-3Y
	for nfs@lists.sourceforge.net; Sat, 26 Feb 2005 05:28:56 -0800
Received: from be.back.l8r.net (bbarnett@be [10.10.10.10])
	by l8r.net (8.12.3/8.12.3/Debian-7.1) with ESMTP id j1QDSBuu007892
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <nfs@lists.sourceforge.net>; Sat, 26 Feb 2005 08:28:11 -0500
To: nfs@lists.sourceforge.net
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



There seems to be some odd behaviour with knfsd.  I have a box with a
raid10, and a single cp or rsync operation should not effectively kill
knfsd performance.

It does, however.

First, nfs works very well as long as this box does not have any local
disk i/o.  I can, literally, transfer files at the upper limit of my
100mbit network connection.  Directory reads are fast, file transfers are
great in both directions.  "Instant" would be the word I would use for
access.

It works great, fast and beautifully.  There does not appear to be any
configuration issue at play here.

The problems start as soon as any local I/O starts.  Directory listings
over nfs can take > 5 or 6 seconds, once I start my rsync backup process. 
File transfer rates fall through the floor.

However, directory listings, locally on the box, are still instant.  File
reads are instant.  There is a _very_ minor slowdown, but my raid10 array
is doing a great job at handling a single rsync session + a single
directory request or copy request.  Again, with knfsd, performance bombs.

There is obviously something wacky in the way the kernel is scheduling
things here.  Any ideas, patches, suggestions?

Kernel 2.6.10, NFSv3 mounted, noatime mounts.  More info can be provided
in needed, but again.. this setup works beautifully under load from
multiple NFS clients.  It is fast, responsive, you name it.  However, one
_single_ cp or rsync session can bring NFS responsiveness to its knees,
without tasking the cpu, ram or swap.

Thanks.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
