From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Thu, 01 Apr 2004 20:41:18 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080870078.10521.53.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DE4C@lavender-fe.eng.netapp.com>
	 <1080866187.10521.14.camel@lade.trondhjem.org>
	 <20040402004924.GG9409@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9DgS-0002Qc-B0
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 17:41:24 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B9DgR-0003Bm-W1
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 17:41:24 -0800
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040402004924.GG9409@sgi.com>
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

On Thu, 2004-04-01 at 19:49, Greg Banks wrote:

> Why not just save a copy of @devname in nfs_get_sb() ?  It's
> the same name that's stored in struct vfsmount and reported
> in /proc/mounts.

That is very different. That we can do...

Please don't confuse the export path and the device name. nfss->mnt_path
is the former: it is part of the NFS mount ABI, and contains the path
that we use to look up the mountpoint on the NFSv4 server. It allows us,
for instance, to recover in the case where the server changes the
filehandle of the mountpoint (NFSv4 servers are allowed to have
filehandles that expire).
Adding the export path to the NFSv2/v3 mount structures would for
instance allow us to do things such as identifying whether or not the
user is mounting a parent/subdirectory of one of our current mount
points.


The device name OTOH is just whatever label the caller of sys_mount()
feels like passing down to the kernel. It will usually contain the name
of the server and the export path ('cos that's what the nfs-utils
"mount" does), but it does not have to, and we currently do not depend
on it taking any particular value.


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
