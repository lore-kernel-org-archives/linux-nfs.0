From: Olaf Kirch <okir@suse.de>
Subject: Re: Linux' NFS locking b0rken?
Date: Wed, 26 May 2004 09:50:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040526075058.GA7463@suse.de>
References: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov> <1085523068.12612.58.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>,
	Dan Stromberg <strombrg@dcs.nac.uci.edu>,
	Jeffrey Layton <jtlayton@poochiereds.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BStBq-000495-R5
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 00:51:06 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BStBq-0007Wf-Ft
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 00:51:06 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085523068.12612.58.camel@lade.trondhjem.org>
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

On Tue, May 25, 2004 at 06:11:08PM -0400, Trond Myklebust wrote:
> Any program which relies on the fact that BSD locks are inherited by
> child processes will fail to work correctly with you wrapper (because
> fcntl() locks are not inherited).

Shouldn't it be possible to map flock locks onto the NLM interface
if we simply record the PID of the process originally requesting
the lock, and reuse that pid in all future operations? All the
flock semantics are provided by fs/locks.c already; all the
NLM client needs to do is to formulate appropriate NLM calls
for lock type changes (SH->EX and vice versa), and unlocks.

Really the only gotcha is that subsequent calls on an existing
lock use the same PID as the original call, so that the server
lockd can match up the request with its existing list of locks.

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
