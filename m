From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Fri, 2 Apr 2004 10:17:35 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040402001735.GD9409@sgi.com>
References: <482A3FA0050D21419C269D13989C61130435DE4C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9CNX-0001A4-8X
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:17:47 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9CNX-00085Q-01
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 16:17:47 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

On Thu, Apr 01, 2004 at 09:05:20AM -0800, Lever, Charles wrote:
> > I don't see any way for the userspace program which reads 
> > these to figure out which of the iostat files corresponds to 
> > which mount. We get the hostname in the filename and again in 
> > the contents but nowhere do we get the mount path, only the 
> > device minor number in the filename.  How about adding a line 
> > to nfs_iostat_show() to print nfss->mnt_path?
> 
> nfss->mnt_path is an NFSv4 only field at the moment.
> 
> let me make sure i understand exactly what it contains.  is
> this the mounted-on directory on the client, or the export
> path on the server?
> 
> if we saved the export path somewhere in the nfs_server
> structure, that would be mighty convenient for iostats
> and i don't think that would break namespaces.

Sounds good.

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
