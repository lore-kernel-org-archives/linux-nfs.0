From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH] 1/3 - RPC metrics support
Date: Thu, 01 Apr 2004 19:36:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080866187.10521.14.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DE4C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb@melbourne.sgi.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9Cfh-0004Ix-Gv
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:36:33 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B9Cfh-0005Ux-AG
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:36:33 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DE4C@lavender-fe.eng.netapp.com>
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

On Thu, 2004-04-01 at 12:05, Lever, Charles wrote:

> if we saved the export path somewhere in the nfs_server
> structure, that would be mighty convenient for iostats
> and i don't think that would break namespaces.

...but it would force us to introduce a new mount_data structure, and
hence a new "mount" ABI so that will have to wait until 2.7.x.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
