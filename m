From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS FAQ updates
Date: Sun, 13 Mar 2005 17:45:22 -0500
Message-ID: <20050313224522.GB13667@fieldses.org>
References: <482A3FA0050D21419C269D13989C61130853986D@lavender-fe.eng.netapp.com> <1110751811.23876.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Charles Lever <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAbpS-0008MQ-8H
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 14:44:58 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAbpQ-00058f-Pc
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 14:44:58 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110751811.23876.19.camel@lade.trondhjem.org>
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

On Sun, Mar 13, 2005 at 05:10:11PM -0500, Trond Myklebust wrote:
> The subtree_check option attempts to decide whether or not a file lies
> within an exported subtree. If you turn it off, then people can
> theoretically try to guess filehandles and gain access to the files
> (assuming the access permissions on the file itself allow that).

I wouldn't put too much emphasis on that "theoretically".  The root
directory on all my ext2/3 filesystems has inode number 2, and as far as
I can tell guessing the rest of the rest of the filehandle just comes
down to guessing the root device, which on my machines is always
/dev/hdaN for some very small N.  Add a few more for people with scsi
and so on, and I bet you could cover most linux NFS servers with a dozen
guesses.  Now just lookup and readdir down to wherever you want.  Am I
missing anything here?

If the administrator tightened down directory permissions a bit, you'll
be forced to guess filehandles for objects deeper in the filesystem,
which may be a little harder.  I wouldn't count on it.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
