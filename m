From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] 1/3 - RPC metrics support
Date: Fri, 02 Apr 2004 12:42:32 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <406CD318.F48841F3@melbourne.sgi.com>
References: <482A3FA0050D21419C269D13989C61130435DE4C@lavender-fe.eng.netapp.com>
		 <1080866187.10521.14.camel@lade.trondhjem.org>
		 <20040402004924.GG9409@sgi.com> <1080870078.10521.53.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9Edm-000414-Fe
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 18:42:42 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9Edm-0004S2-4Z
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 18:42:42 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

Trond Myklebust wrote:
> 
> On Thu, 2004-04-01 at 19:49, Greg Banks wrote:
> 
> > Why not just save a copy of @devname in nfs_get_sb() ? 
> 
> That is very different. That we can do...
> 
> Please don't confuse the export path and the device name. nfss->mnt_path
> is the former: 

> The device name OTOH is just whatever label the caller of sys_mount()
> feels like passing down to the kernel. It will usually contain the name
> of the server and the export path ('cos that's what the nfs-utils
> "mount" does), but it does not have to, and we currently do not depend
> on it taking any particular value.

If all we care about is identifying the sb for purposes of iostat and
post-mortem debugging (I for one would find this useful), the precise
semantics placed on the string by the mount program don't matter that
much.  You could add a `devname' field to nfs_server and document
that it doesn't mean anything at all.  Alternatively you could check
that the first part matches (modulo domain names) the `hostname' field
and is followed by a ':' and a path, and if all that matches, save the
path.

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
