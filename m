From: Greg Banks <gnb@sgi.com>
Subject: Re: can anyone explain this state?
Date: Thu, 18 Aug 2005 09:51:36 +1000
Message-ID: <20050817235136.GA12262@sgi.com>
References: <bc57270905081704131c4b23d4@mail.gmail.com> <1124280174.23245.4.camel@lade.trondhjem.org> <43032CF2.3070908@redhat.com> <1124282392.23245.26.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	Michael <mikore.li@gmail.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5pCp-0005k5-PQ
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 11:33:35 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5pCm-0005Os-S5
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 11:33:35 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1E5Xjv-0005G2-Vj
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 16:54:38 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1124282392.23245.26.camel@lade.trondhjem.org>
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

On Wed, Aug 17, 2005 at 08:39:52AM -0400, Trond Myklebust wrote:
> on den 17.08.2005 Klokka 08:26 (-0400) skreiv Peter Staubach:
> > Trond Myklebust wrote:
> > >This is done using asynchronous writes. Much faster, and no need (on
> > >NFSv3) to wait for the disk before sending the next request.
> > >
> > >The reason is that on 2.4 kernels (and early 2.6 kernels) we could only
> > >do synchronous writes when you set wsize < PAGE_SIZE.
> > >
> > 
> > Maybe I am misreading the commands being run, but they look like they would
> > generate all NFS READ traffic.  It appears to be copying from an NFS mounted
> > file system to /tmp, a local file system.
> 
> Oops. errno=ENOCOFFEE... You are quite right.
> 
> Yep. That would indeed put the differences down to caching.

Trond, your comments also apply for READs with rsize<PAGE_SIZE; 2.4
will do sync reads on the wire in this case.  The performance drop
is not as dramatic as with writes because the server is doing its own
local readahead, which can't happen for writes, but there's still
a performance drop due to lack of parallelism on the wire.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
