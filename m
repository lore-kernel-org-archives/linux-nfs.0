From: Olaf Kirch <okir@suse.de>
Subject: Re: Linux' NFS locking b0rken?
Date: Thu, 27 May 2004 19:04:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040527170437.GA16548@suse.de>
References: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov> <1085523068.12612.58.camel@lade.trondhjem.org> <20040526075058.GA7463@suse.de> <1085587441.3763.4.camel@lade.trondhjem.org> <20040527161412.GA19288@suse.de> <1085675509.4074.26.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>,
	Dan Stromberg <strombrg@dcs.nac.uci.edu>,
	Jeffrey Layton <jtlayton@poochiereds.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTOLH-0001JW-CZ
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 10:06:55 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BTOLG-00012z-Lp
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 10:06:55 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085675509.4074.26.camel@lade.trondhjem.org>
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

On Thu, May 27, 2004 at 12:31:49PM -0400, Trond Myklebust wrote:
> That said, I believe that RHEL-3 at least is returning an error these
> days whenever you try to flock over NFS: I dunno if you are doing this
> at SuSE yet?

We did, on SLES8. Those were some silly third party patches we included
that changed flock to call the lock() function of the underlying FS.
The NFS lock function returns -ENOLCK in this case.

I don't know where this patch came from. Maybe it was GFS related.
I did have to handle a fair share of bug reports because of that.

But I think those broken movemails are not the issue; in fact this
change would actually _fix_ these apps to work over NFS, for the first
time. The only problematic apps would be those mixing flock and fcntl
on a single open file.

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
