From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] 1/3 - RPC metrics support
Date: Thu, 1 Apr 2004 09:05:20 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DE4C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Greg Banks" <gnb@melbourne.sgi.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B95dG-0000L0-DQ
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 09:05:34 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B95dG-00035F-1U
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 09:05:34 -0800
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
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

> I don't see any way for the userspace program which reads=20
> these to figure out which of the iostat files corresponds to=20
> which mount. We get the hostname in the filename and again in=20
> the contents but nowhere do we get the mount path, only the=20
> device minor number in the filename.  How about adding a line=20
> to nfs_iostat_show() to print nfss->mnt_path?

nfss->mnt_path is an NFSv4 only field at the moment.

let me make sure i understand exactly what it contains.  is
this the mounted-on directory on the client, or the export
path on the server?

if we saved the export path somewhere in the nfs_server
structure, that would be mighty convenient for iostats
and i don't think that would break namespaces.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
