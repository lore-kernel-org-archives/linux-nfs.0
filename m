From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Fri, 2 Apr 2004 10:49:24 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040402004924.GG9409@sgi.com>
References: <482A3FA0050D21419C269D13989C61130435DE4C@lavender-fe.eng.netapp.com> <1080866187.10521.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9CsJ-0007r5-8Y
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:49:35 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9CsI-00016j-Vq
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:49:35 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1080866187.10521.14.camel@lade.trondhjem.org>
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

On Thu, Apr 01, 2004 at 07:36:27PM -0500, Trond Myklebust wrote:
> On Thu, 2004-04-01 at 12:05, Lever, Charles wrote:
> 
> > if we saved the export path somewhere in the nfs_server
> > structure, that would be mighty convenient for iostats
> > and i don't think that would break namespaces.
> 
> ...but it would force us to introduce a new mount_data structure, and
> hence a new "mount" ABI so that will have to wait until 2.7.x.

Why not just save a copy of @devname in nfs_get_sb() ?  It's
the same name that's stored in struct vfsmount and reported
in /proc/mounts.

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
