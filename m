From: Olaf Kirch <okir@suse.de>
Subject: Re: Marking inodes as stale can be wrong
Date: Thu, 29 Apr 2004 23:28:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040429212837.GA23172@suse.de>
References: <20040429144012.GA15361@suse.de> <1083257096.3686.27.camel@lade.trondhjem.org> <20040429165802.GA18748@suse.de> <1083258570.3686.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJJ5E-0005Qz-Jm
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 14:28:40 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BJJ5E-0002yE-6I
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 14:28:40 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083258570.3686.38.camel@lade.trondhjem.org>
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

On Thu, Apr 29, 2004 at 01:09:30PM -0400, Trond Myklebust wrote:
> The correct workaround here is to advise people to *always* use
> "no_subtree_check" and then to look into fixing these problems in future
> revisions of the server, not the client.

I agree with that.

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
