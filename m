From: Christoph Hellwig <hch@infradead.org>
Subject: i_generation = 0 special casing
Date: Wed, 24 Nov 2004 09:43:20 +0000
Message-ID: <20041124094320.GA10206@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWtgY-0006Qq-9o
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 01:43:38 -0800
Received: from [213.146.154.40] (helo=pentafluge.infradead.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWtgK-0005RP-Gf
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 01:43:38 -0800
To: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
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

export_iget (and routines based on it such as xfs_vget) check for
i_generation beeing 0 meaning that every generation is okay.  Where in
the NFS code is this wildcard needed?

I had to find out that XFS starts it's i_generation at zero and either
I have to fix up the i_generation or drop this wildcard if it's not
actually used.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
