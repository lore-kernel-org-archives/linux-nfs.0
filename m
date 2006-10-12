From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in	hash
Date: Wed, 11 Oct 2006 19:30:00 -0700
Message-ID: <1160620200.6596.36.camel@lade.trondhjem.org>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXqKw-0004Pk-UO
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 19:30:19 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GXqKw-0000om-II
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 19:30:19 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2006-10-11 at 21:28 +1000, Greg Banks wrote:
> knfsd: Use the client's IP address in the duplicate request cache
> hash function, instead of just the XID.  This avoids contention
> on hash buckets when the workload has many clients whose XIDs are
> nearly in lockstep, a property seen on compute clusters using NFS
> for shared storage.

Note that some platforms (in particular the *BSDs) use an MD5 checksum
of the first couple of 100 bytes of the RPC header+message instead of
relying on the XID. That is a good deal safer w.r.t. port reuse by other
clients etc.

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
