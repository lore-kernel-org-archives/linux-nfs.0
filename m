From: "Vsevolod (Simon) Ilyushchenko" <simonf@cshl.edu>
Subject: Failover using wackamole?
Date: Mon, 28 Feb 2005 11:18:24 -0500
Message-ID: <42234450.9070004@cshl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5nbN-0000zV-3K
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:18:33 -0800
Received: from mercury.cshl.edu ([143.48.1.21])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D5nbL-00085f-Gw
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 08:18:33 -0800
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

Hi,

I had this neat idea that NFS failover of read-only filesystems can be 
achieved using wackamole (floating IP adresses providing very simple 
HA). This did not work with NFS 3 because the filehandles are different 
on the primary and the secondary servers, so I was getting a "stale NFS 
filehandle" error after the failover.

I tried this using NFS 4 nfs-utils-1.0.6-52 from FC3 updates. However, 
it still failed with the following error:
	ls: reading directory a: Input/output error
and this in the error log on the client:
	kernel: RPC: garbage, exit EIO

Is this a bug or a feature?

Thanks,
Simon
-- 

Simon (Vsevolod ILyushchenko)   simonf@cshl.edu
				http://www.simonf.com

Terrorism is a tactic and so to declare war on terrorism
is equivalent to Roosevelt's declaring war on blitzkrieg.

Zbigniew Brzezinski, U.S. national security advisor, 1977-81


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
