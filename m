From: Olaf Kirch <okir@suse.de>
Subject: Re: Linux' NFS locking b0rken?
Date: Thu, 27 May 2004 18:14:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040527161412.GA19288@suse.de>
References: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov> <1085523068.12612.58.camel@lade.trondhjem.org> <20040526075058.GA7463@suse.de> <1085587441.3763.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>,
	Dan Stromberg <strombrg@dcs.nac.uci.edu>,
	Jeffrey Layton <jtlayton@poochiereds.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTNXC-0006wb-Al
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 09:15:10 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BTNXB-0003Z8-Jx
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 09:15:09 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085587441.3763.4.camel@lade.trondhjem.org>
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

On Wed, May 26, 2004 at 12:04:01PM -0400, Trond Myklebust wrote:
> Sure we could. The question is whether or not there are any applications
> out there that set both flock and fcntl locks? They would break with
> such a scheme.

Don't they deserve to break?

I'd rather make flock work over NFS (and have one FAQ less to deal with),
than supporting patently broken apps.

We could create a mount option or even better a lockd module option to
make the old behavior selectable for those that need it.

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
