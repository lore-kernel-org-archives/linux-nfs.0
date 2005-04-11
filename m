From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: Re: [PATCH] nfsstat.man
Date: Mon, 11 Apr 2005 13:55:22 -0400
Message-ID: <20050411175522.GA30560@gam3.net>
References: <20050411145544.GA23506@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DL38I-0000W9-U1
	for nfs@lists.sourceforge.net; Mon, 11 Apr 2005 10:55:34 -0700
Received: from mta9.adelphia.net ([68.168.78.199])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DL38H-0002MR-FE
	for nfs@lists.sourceforge.net; Mon, 11 Apr 2005 10:55:34 -0700
Received: from harpo.ny.gam3.net ([68.235.28.141]) by mta9.adelphia.net
          (InterMail vM.6.01.04.01 201-2131-118-101-20041129) with ESMTP
          id <20050411175527.MJGY2192.mta9.adelphia.net@harpo.ny.gam3.net>
          for <nfs@lists.sourceforge.net>; Mon, 11 Apr 2005 13:55:27 -0400
Received: from gam3 by harpo.ny.gam3.net with local (Exim 3.36 #1 (Debian))
	id 1DL386-0007xn-00
	for <nfs@lists.sourceforge.net>; Mon, 11 Apr 2005 13:55:22 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20050411145544.GA23506@gam3.net>
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


Here are the main changes that I think might upset people:

The default output has be changed. To get the old default output you
must run 'nfsstat --auto -2'. That is by defult the version 2 info is
not output unless it has a non-zero entry.

I removed the -v[23] option and added -2 -3 -4 options. I changed the -a
option to -v (verbose). The -a option is reserved for nfs acl output.

Allen



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
