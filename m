From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Marking inodes as stale can be wrong
Date: Fri, 30 Apr 2004 11:51:40 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4091B12C.FBB1FF34@melbourne.sgi.com>
References: <20040429144012.GA15361@suse.de>
		 <1083257096.3686.27.camel@lade.trondhjem.org>
		 <20040429165802.GA18748@suse.de>
		 <1083258570.3686.38.camel@lade.trondhjem.org>
		 <20040429235018.GC4843@sgi.com> <1083285820.14910.77.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJNC1-0005Yv-PL
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 18:51:57 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BJNC1-0005F7-I5
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 18:51:57 -0700
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
> Note for instance that the error NFS3ERR_JUKEBOX is not listed as a
> return value for any of the procedures: I'm sure that it would come as a
> surprise to most server implementors if you were to disallow its use
> solely on those grounds.

Oh indeed ;-)  My next server patch does precisely that.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
