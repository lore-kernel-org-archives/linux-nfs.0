From: Benjamin Bennett <ben@phys.psu.edu>
Subject: cache permissions issue with gss
Date: Mon, 07 Mar 2005 11:25:20 -0500
Message-ID: <1110212720.13136.23.camel@kenny.phys.psu.edu>
Mime-Version: 1.0
Content-Type: text/plain
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8L2w-00029d-LL
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 08:25:30 -0800
Received: from faraday.phys.psu.edu ([128.118.49.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D8L2u-0003Mn-Nd
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 08:25:30 -0800
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
  Using RHEL4 (2.6.9) to export using gss, and FC2 (2.6.10) to mount the
export I've noticed that root has perhaps more access to cached data
than he should.

  Specifically, on the FC2 client, root mounts the filesystem using v4 &
gss but doesn't have any permissions (other than other). Once a user
lists a directory on that filesystem that only that user can list, root
will then be able to list the directory as well. If root attempts to
write to a file in the directory it fails with a permission error,
apparently invalidates the cache and root can no longer list the
directory. This will repeat if the user lists the directory again.
  This does not appear to be true for users other than root.

thoughts?


--ben



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
