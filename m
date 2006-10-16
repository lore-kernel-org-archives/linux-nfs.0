From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in	hash
Date: Mon, 16 Oct 2006 12:27:32 +1000
Message-ID: <17714.60948.856931.650829@cse.unsw.edu.au>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
	<1160620200.6596.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZICa-0007gU-M4
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:27:40 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GZICa-00047T-56
	for nfs@lists.sourceforge.net; Sun, 15 Oct 2006 19:27:41 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Wednesday October 11
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

On Wednesday October 11, trond.myklebust@fys.uio.no wrote:
> On Wed, 2006-10-11 at 21:28 +1000, Greg Banks wrote:
> > knfsd: Use the client's IP address in the duplicate request cache
> > hash function, instead of just the XID.  This avoids contention
> > on hash buckets when the workload has many clients whose XIDs are
> > nearly in lockstep, a property seen on compute clusters using NFS
> > for shared storage.
> 
> Note that some platforms (in particular the *BSDs) use an MD5 checksum
> of the first couple of 100 bytes of the RPC header+message instead of
> relying on the XID. That is a good deal safer w.r.t. port reuse by other
> clients etc.

I'm amused at the juxtaposition here.
We have the possibility of using an MD5 hash over 100 bytes in a
comment on patch containing the comment

+ * Experiment shows that using the Jenkins hash improves the spectral
+ * properties of this hash, but the CPU cost of calculating it outweighs
+ * the advantages.

If a Jenkins hash is too expensive, I suspect MD5 would be even more
so...

I'm not suggesting either approach is right or wrong - just that it is
thought provoking.

Greg: did you have measurements to suggest that a Jenkins hash was too
expensive?   Did it just increase CPU load a bit, or did it affect
throughput?

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
