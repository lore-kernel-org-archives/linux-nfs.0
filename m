From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: NFS FAQ updates
Date: Sun, 13 Mar 2005 17:10:11 -0500
Message-ID: <1110751811.23876.19.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130853986D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAbIG-0006tz-S5
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 14:10:40 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAbIG-0002Hn-4v
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 14:10:40 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130853986D@lavender-fe.eng.netapp.com>
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

su den 13.03.2005 Klokka 13:41 (-0800) skreiv Lever, Charles:

> hmmm.  so what's the difference between not having access to a file, and
> having access but not being able to read the file?  is it just the
> ability to know the file is there?  wouldn't that be prevented by not
> having access to its parent?  or, since the file handle is still good,
> lack of permission to look the file up in the new parent would be
> inconsequential?

The subtree_check option attempts to decide whether or not a file lies
within an exported subtree. If you turn it off, then people can
theoretically try to guess filehandles and gain access to the files
(assuming the access permissions on the file itself allow that).

An example where subtree_check might actually be useful (and where
kerberos won't help you) is if you have /etc and /bin on the same
partition, and you just want to export /bin read-only.

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
