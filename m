From: Olaf Kirch <okir@suse.de>
Subject: Re: Marking inodes as stale can be wrong
Date: Fri, 30 Apr 2004 10:58:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040430085820.GD29672@suse.de>
References: <20040429144012.GA15361@suse.de> <1083257096.3686.27.camel@lade.trondhjem.org> <20040429165802.GA18748@suse.de> <1083258570.3686.38.camel@lade.trondhjem.org> <20040429235018.GC4843@sgi.com> <1083285820.14910.77.camel@lade.trondhjem.org> <4091B12C.FBB1FF34@melbourne.sgi.com> <20040430083445.GB29672@suse.de> <4092129C.34484C9B@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJTt0-0001kT-9P
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 02:00:46 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BJTsz-0008RX-Rh
	for nfs@lists.sourceforge.net; Fri, 30 Apr 2004 02:00:46 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <4092129C.34484C9B@melbourne.sgi.com>
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

On Fri, Apr 30, 2004 at 06:47:24PM +1000, Greg Banks wrote:
> So in the case where "subtree_check" is on and the client sends a
> file handle to a file in a tree which has been unexported, a server
> with the patch will incorrectly send ACCES instead of STALE.

When we get there, we have already found a connected, valid dentry. We
also have an export entry, which was specified by the client. If we don't
have either, we'll error mout with ESTALE long before.

All that's left to do at this point is make sure the dentry

 a)	actually resides below the exported inode
 b)	all intermediate directories have +x for the caller

So the only case where this patch incorrectly(?) returns EACCESS is if
the specified dentry does not reside below the exported dentry.

So yes, the cleaner approach is probably to change nfsd_acceptable.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
