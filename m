From: Olaf Kirch <okir@suse.de>
Subject: Re: Marking inodes as stale can be wrong
Date: Thu, 29 Apr 2004 18:58:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040429165802.GA18748@suse.de>
References: <20040429144012.GA15361@suse.de> <1083257096.3686.27.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJErO-0005lm-4v
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 09:58:06 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BJErN-0006ry-Vd
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 09:58:06 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083257096.3686.27.camel@lade.trondhjem.org>
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

On Thu, Apr 29, 2004 at 12:44:56PM -0400, Trond Myklebust wrote:
> On Thu, 2004-04-29 at 10:40, Olaf Kirch wrote:
> > 	fh_verify did the subtree check, and found that
> > 	~/Mail was mode 700, and hence user nobody didn't
> > 	have x permissions on the directory. So it would
> > 	return ESTALE to the client.
> 
> This is a bug!

Yes, probably. Even though I'm not entirely sure NFSERR_ACCES is a valid
return for all NFS operations.

However, machines with 2.4 will be out there for a while, so the question
I'm asking myself is how to cope with those in the client.

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
