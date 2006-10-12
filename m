From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in hash
Date: Thu, 12 Oct 2006 11:31:47 -0400
Message-ID: <20061012153147.GB19198@fieldses.org>
References: <1160566130.8530.17.camel@hole.melbourne.sgi.com>
	<1160620200.6596.36.camel@lade.trondhjem.org>
	<20061012082126.GM8568@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GY2XS-0001b5-Se
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 08:32:02 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GY2XS-0005Si-Hj
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 08:32:03 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20061012082126.GM8568@sgi.com>
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

On Thu, Oct 12, 2006 at 06:21:26PM +1000, Greg Banks wrote:
> On Wed, Oct 11, 2006 at 07:30:00PM -0700, Trond Myklebust wrote:
> > On Wed, 2006-10-11 at 21:28 +1000, Greg Banks wrote:
> > > knfsd: Use the client's IP address in the duplicate request cache
> > > hash function, instead of just the XID.  This avoids contention
> > > on hash buckets when the workload has many clients whose XIDs are
> > > nearly in lockstep, a property seen on compute clusters using NFS
> > > for shared storage.
> > 
> > Note that some platforms (in particular the *BSDs) use an MD5 checksum
> > of the first couple of 100 bytes of the RPC header+message instead of
> > relying on the XID. That is a good deal safer w.r.t. port reuse by other
> > clients etc.
> > 
> 
> I hear that there was a Cthon presentation on this subject.  It sounds
> very interesting, does anyone have a URL?

My possibly muddled notes from Rick's presentation:

Rick suggests:
        LRU cache per TCP connection:
                evicts from each cache on TCP ack from reply
        keep individual caches around forever, even after disconnect--
                since longterm network partition e.g. may be typical case.
                (OK, maybe not forever).
        (Note lookups are *global*--he doesn't look up on TCP connection (or
                even IP address)--he wants reconnects to get hits.)
        He uses XID and checksum on first 100 bytes of decrypted RPC body
                as key into cache.
                He assumes any hit on an in-progress rpc is a false positive.
                He also will *never* drop based on a hit on anything with
                a sequenceid-mutating op in it.


He also has more detailed notes at
ftp://ftp.cis.uoguelph.ca:/pub/nfsv4/server-cache.algorithm
and code in newnfs/nfsd/nfsd_srvcache.c in any of the nfsv4-fullkern* tarballs
on the same site.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
