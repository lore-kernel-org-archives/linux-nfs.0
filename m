From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH][RFC] Multiple UDP sockets for knfsd
Date: Sat, 15 May 2004 16:38:54 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040515063854.GB14983@sgi.com>
References: <40A42DB8.7B9C8152@melbourne.sgi.com> <1084566110.4237.66.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@melbourne.sgi.com>, Neil Brown <neilb@cse.unsw.edu.au>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOspz-00023l-Cz
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 23:39:59 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BOspz-00062L-6C
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 23:39:59 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1084566110.4237.66.camel@lade.trondhjem.org>
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

On Fri, May 14, 2004 at 04:21:50PM -0400, Trond Myklebust wrote:
> 
> I'm confused here. Are you actually implying that socket contention is
> responsible for a full *40%* decrease in throughput?

At that level of throughput, yes.

> Also, isn't that call to sock_release() while holding serv->sv_lock a
> tad deadlock-prone? Note that sock_release() will call bh_lock_sock()...

Ok, I'll fix that by leaving the unlocks alone and changing the
semantics of __svc_delete_socket() to "call with lock, drops the lock".

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
