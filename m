From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: linux-2.4.19-18-noac.dif
Date: Tue, 26 Nov 2002 18:25:45 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF97708985.A1869F34-ON88256C7E.000C7D0A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: trond.myklebust@fys.uio.no, Charles.Lever@netapp.com
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>





Hi Trond/Chuck,

I was looking through Trond's patch repository and saw the patch listed
above.  What was the problem, or potential problem, that lead to this
patch?  What would/could happen if a page was not set up to date when an
entire page gets written by nfs_writepage_sync()?  I couldn't find any
discussion of this in the archives other than the posting of the patch to
the nfs list.

http://www.fys.uio.no/~trondmy/src/2.4.19/linux-2.4.19-18-noac.dif

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
