From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: can anyone explain this state?
Date: Thu, 18 Aug 2005 10:02:56 -0400
Message-ID: <1124373776.8343.8.camel@lade.trondhjem.org>
References: <bc57270905081704131c4b23d4@mail.gmail.com>
	 <1124280174.23245.4.camel@lade.trondhjem.org> <43032CF2.3070908@redhat.com>
	 <1124282392.23245.26.camel@lade.trondhjem.org>
	 <20050817235136.GA12262@sgi.com>
	 <1124324316.8347.79.camel@lade.trondhjem.org>  <43048FEF.5020402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb@sgi.com>, Peter Staubach <staubach@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5oAA-0001N8-RW
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 10:26:46 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5o66-0004Wn-GL
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 10:26:46 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1E5l20-00036l-Ri
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 07:06:09 -0700
To: Michael <oldmoonster@gmail.com>
In-Reply-To: <43048FEF.5020402@gmail.com>
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

to den 18.08.2005 Klokka 21:41 (+0800) skreiv Michael:

> ========================================================================
> Yes, I know it should be cache related, but you can see it took me
> more than 1 minute at the first time copy 100Mfile from nfs server,
> but suddenly the second time took 4 second.
> How can the cache result to this? NFS client cache ability? ok, if it
> is, that means NFS client could cache at least 90M data of 100M, then,
> how to explain the last 2 copies?  with rsize=8k,first time copy 100M
> file took 9 seconds, but the second time took 7 seconds, if cache work
> as great as rsize=1k, why not the second time copy take less than 1
> second?
> ========================================================================

The "nfsstat" program should tell you exactly how many requests NFS has
put on the wire since you booted. I suggest you run it after each test,
and compare the number of READs the client has made. By looking at those
numbers, you should be able to tell exactly how much data was cached and
how much had to be retrieved from the server.

BTW: caching 100M of data is hardly much of a problem on a modern
machine. All memory that is not in active use by processes may be used
by the page cache for caching files, so in practise if you have > 100M
core memory and a lightly loaded machine, there is a high chance that
the file will be able to be kept entirely in memory.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
