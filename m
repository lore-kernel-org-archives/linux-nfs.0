From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH, RFC] rework rpc_pipefs
Date: Tue, 28 Jun 2005 07:39:41 -0400
Message-ID: <1119958781.8245.4.camel@lade.trondhjem.org>
References: <20050506161018.GA3979@infradead.org>
	 <1115410171.1960.26.camel@lade.trondhjem.org>
	 <20050510122745.GA28981@infradead.org>
	 <20050628112923.GA18703@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnERd-0004i7-Et
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 04:40:01 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DnERb-0005OU-E4
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 04:40:01 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20050628112923.GA18703@infradead.org>
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

ty den 28.06.2005 Klokka 12:29 (+0100) skreiv Christoph Hellwig:
> Currently rpc_mkdir/rpc_rmdir and rpc_mkpipe/mk_unlink have an API that's
> a little unfortunate.  They take a path relative to the rpc_pipefs root and
> thus need to perform a full lookup.  If you look at debugfs or usbfs they
> always store the dentry for directories they created and thus can pass in
> a dentry + single pathname component pair into their equivalents of the
> above functions.
>  
> And in fact rpc_pipefs actually stores a dentry for all but one component so
> this change not only simplifies the core rpc_pipe code but also the callers.
> 
> Unfortuntately this code path is only used by the NFS4 idmapper and
> AUTH_GSSAPI for which I don't have a test enviroment.  Could someone give
> it a spin?  It's the last bit needed before we can rework the lookup_hash API

Sure. May I add the usual "Signed-off-by" line so that I can put it into
the NFS_ALL patch stream?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
