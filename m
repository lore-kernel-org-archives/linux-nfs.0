From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] 1/3 - RPC metrics support
Date: Sat, 3 Apr 2004 18:35:48 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07BFD@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9xUP-0001DS-Pf
	for nfs@lists.sourceforge.net; Sat, 03 Apr 2004 18:36:01 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B9xUO-0007lK-RS
	for nfs@lists.sourceforge.net; Sat, 03 Apr 2004 18:36:00 -0800
To: "Greg Banks" <gnb@sgi.com>, "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> On Thu, Apr 01, 2004 at 07:36:27PM -0500, Trond Myklebust wrote:
> > On Thu, 2004-04-01 at 12:05, Lever, Charles wrote:
> >=20
> > > if we saved the export path somewhere in the nfs_server
> > > structure, that would be mighty convenient for iostats
> > > and i don't think that would break namespaces.
> >=20
> > ...but it would force us to introduce a new mount_data=20
> structure, and
> > hence a new "mount" ABI so that will have to wait until 2.7.x.
>=20
> Why not just save a copy of @devname in nfs_get_sb() ?  It's
> the same name that's stored in struct vfsmount and reported
> in /proc/mounts.

unless i've missed something, there are only two NFS functions
that take vfsmount as an argument.  one is nfs_show_options, and
the other is nfs_getattr.

the vfsmount struct is not available to the NFS client during a
mount operation.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
