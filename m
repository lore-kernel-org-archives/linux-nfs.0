From: "G. Allen Morris III" <gam3-nfs@gam3.net>
Subject: /proc/fs/nfs/exports Broken
Date: Sun, 6 Mar 2005 12:36:28 -0500
Message-ID: <20050306173628.GA3918@gam3.net>
References: <20050306164036.GA21468@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7zgF-000630-DR
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 09:36:39 -0800
Received: from mta13.adelphia.net ([68.168.78.44])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D7zgB-0002l0-Pg
	for nfs@lists.sourceforge.net; Sun, 06 Mar 2005 09:36:39 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20050306164036.GA21468@gam3.net>
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

Neil,

Neil the net rcp export cache should not be used directly for
the /proc/nfs/exports output.

I am pretty sure that all that needs to be done is to only display
the rightmost element of the domain (client = strrchr(domain, ',')+1).

I have a patch, but plan to clean it up before I send it to you.

I just wanted to request comments on this problem for now.

G. Allen Morris III <gam3@gam3.net>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
