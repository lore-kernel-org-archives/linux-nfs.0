From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 0 of 12] Introduction
Date: Tue, 08 Feb 2005 14:06:53 +1100
Message-ID: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLiq-0006vA-RP
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:28 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLiq-0005Di-57
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:28 -0800
To: Andrew Morton <akpm@osdl.org>
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


Following are 12 patches for nfsd in 2.6.11-rc2-mm2

- Fix minor problem with '..' access interacting with the "nohide" export option.
- reduce stack space usage in find_exported_dentry
- 6 patches from Bruce Fields to improve authentication handling for callbacks.
- Fix problem that stopped read access to append-only files.
- Fix bug where readdir replies are cache badly.
- Add lots of "static" declarations where appropriate
- Change nfscache to use list.h macros and smaller kmallocs

I believe they are all ready for ready for 2.6.11.
Number 10 (readdir fix) is probably the most critical (and most trivial).
The append-only would be next in line.
The 6 from Bruce fix a real performance problem with locking.

The rest could be safely delayed if that seem appropriate, but they are 
either quite trivial or (for the last one) quite well tested.

NeilBrown



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
