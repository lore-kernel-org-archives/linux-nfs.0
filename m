From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Marking inodes as stale can be wrong
Date: Fri, 30 Apr 2004 18:47:24 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4092129C.34484C9B@melbourne.sgi.com>
References: <20040429144012.GA15361@suse.de> <1083257096.3686.27.camel@lade.trondhjem.org> <20040429165802.GA18748@suse.de> <1083258570.3686.38.camel@lade.trondhjem.org> <20040429235018.GC4843@sgi.com> <1083285820.14910.77.camel@lade.trondhjem.org> <4091B12C.FBB1FF34@melbourne.sgi.com> <20040430083445.GB29672@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJTi3-0004Mg-PL
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 01:49:27 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJTi3-00076o-H3
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 01:49:27 -0700
To: Olaf Kirch <okir@suse.de>
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

Olaf Kirch wrote:
> 
> Here's a minimalistic fix. It may be better to change nfsd_acceptable
> to return 0 on success and negative error code on error, but I'm not
> sure this is really needed as long as the only acceptance test
> in nfsd_acceptable is the subtree check.

I think the patch makes the opposite mistake to the current code.
RFC1813 says:

NFS3ERR_ACCES
       Permission denied. The caller does not have the correct
       permission to perform the requested operation.[...]

NFS3ERR_STALE
       Invalid file handle. The file handle given in the
       arguments was invalid. The file referred to by that file
       handle no longer exists or access to it has been
       revoked.

So in the case where "subtree_check" is on and the client sends a
file handle to a file in a tree which has been unexported, a server
with the patch will incorrectly send ACCES instead of STALE.

I think the real fix is your other suggestion: changing the calling
convention of nfsd_acceptable to allow it to choose the error.

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
