From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Sun, 04 Apr 2004 16:17:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <406FA86F.A9748FFC@melbourne.sgi.com>
References: <482A3FA0050D21419C269D13989C611302B07BFD@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BA0x4-0007Vk-TV
	for nfs@lists.sourceforge.net; Sat, 03 Apr 2004 22:17:50 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BA0x4-0005LZ-MP
	for nfs@lists.sourceforge.net; Sat, 03 Apr 2004 22:17:50 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

"Lever, Charles" wrote:
> 
> > Why not just save a copy of @devname in nfs_get_sb() ?  It's
> > the same name that's stored in struct vfsmount and reported
> > in /proc/mounts.
> 
> unless i've missed something, there are only two NFS functions
> that take vfsmount as an argument.  one is nfs_show_options, and
> the other is nfs_getattr.
> 
> the vfsmount struct is not available to the NFS client during a
> mount operation.

The devname string that fs/super.c:do_kern_mount() passes to
nfs_get_sb() via file_system_type->get_sb is passed to
alloc_vfsmount() and used there to initialise the vfsmount's
mnt_devname.  So while NFS doesn't have the vfsmount it does
have the same devname string.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
