From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 6/8] knfsd: repcache: use client IP address in hash
Date: Thu, 12 Oct 2006 10:19:31 -0400
Message-ID: <76bd70e30610120719u3b5e48fch8a0da89ed8ed6a6c@mail.gmail.com>
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
	id 1GY1PK-0000OI-9Y
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 07:19:34 -0700
Received: from wr-out-0506.google.com ([64.233.184.224])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GY1PJ-00055U-RT
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 07:19:35 -0700
Received: by wr-out-0506.google.com with SMTP id 67so127400wri
	for <nfs@lists.sourceforge.net>; Thu, 12 Oct 2006 07:19:31 -0700 (PDT)
To: "Greg Banks" <gnb@sgi.com>
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

On 10/12/06, Greg Banks <gnb@sgi.com> wrote:
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
>
> I presume the approach involves masking out the IPID and TCP sequence
> number?  Otherwise retries would never hash to the same value as the
> original requests, thus defeating the repcache entirely.

The hash starts at the beginning of the RPC header, so the IP and
TCP/UDP headers are skipped.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
