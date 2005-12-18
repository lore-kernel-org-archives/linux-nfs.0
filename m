From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: Re: lockd: couldn't create RPC handle for (host)
Date: Sun, 18 Dec 2005 15:00:52 -0500
Message-ID: <20051218200052.GA21665@tau.solarneutrino.net>
References: <20051216235841.GA20539@tau.solarneutrino.net> <1134797577.20929.2.camel@lade.trondhjem.org> <20051217055907.GC20539@tau.solarneutrino.net> <1134801822.7946.4.camel@lade.trondhjem.org> <20051217070222.GD20539@tau.solarneutrino.net> <1134847699.7950.25.camel@lade.trondhjem.org> <20051217194553.GE20539@tau.solarneutrino.net> <1134894836.7931.17.camel@lade.trondhjem.org> <20051218180150.GF20539@tau.solarneutrino.net> <1134934267.7966.37.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	ryan@tau.solarneutrino.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eo4iV-0005NN-UH
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 12:01:11 -0800
Received: from solarneutrino.net ([66.199.224.43] helo=tau.solarneutrino.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eo4iU-0001UT-MG
	for nfs@lists.sourceforge.net; Sun, 18 Dec 2005 12:01:12 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134934267.7966.37.camel@lade.trondhjem.org>
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

On Sun, Dec 18, 2005 at 02:31:07PM -0500, Trond Myklebust wrote:
> On Sun, 2005-12-18 at 13:01 -0500, Ryan Richter wrote:
> > Code: 48 39 78 18 75 1c 8b 86 8c 00 00 00 a8 01 74 12 83 c8 02 89 
> > RIP <ffffffff801dbd9e>{nlmclnt_mark_reclaim+62} RSP <ffff81007dfade70>
> > CR2: 0000000000000018
> 
> Looks like the global lock list is corrupted. Could you cat the contents
> of /proc/locks?

$ cat /proc/locks
1: POSIX  ADVISORY  WRITE 1657 00:0e:1771273 0 EOF
2: FLOCK  ADVISORY  WRITE 1486 00:0e:1770759 0 EOF
3: FLOCK  ADVISORY  WRITE 1478 00:0e:1770399 0 EOF

> > Every machine with a dead lockd has had this oops.  Other stuff that
> > looks related (these came after the oops, a few days later):
> 
> Those errors are unrelated. These errors come from the server.
> 
> > lockd: unexpected unlock status: 1
> > lockd: weird return 7 for CANCEL call
> 
> Error "7" is the equivalent of "ESTALE" (stale filehandle). That means
> either someone deleted the file you are trying to lock on the server, or
> that a bug caused nfsd  to somehow lose track of the file.
> 
> I suspect the Error "1" is related to the same issue.

Unfortunately I don't have a date stamp for these messages.  I think
they might be from my initial efforts to debug the problem - I deleted
some lock files once or twice.  None of the other machines had these
messages.

> 
> > > Finally, please do
> > > 
> > > echo 1 > /proc/sys/sunrpc/rpc_lockd
> > > then unmount one of your NFS partitions, and then mount it again.
> > 
> > That file doesn't exist.
> > 
> > $ ls /proc/sys/sunrpc 
> > nfs_debug  nfsd_debug  nlm_debug  rpc_debug  tcp_slot_table_entries
> > udp_slot_table_entries
> 
> Sorry, I meant 'nlm_debug'.

OK, I did that and unmounted and remounted the home directories.
There's still no lockd process.  I had someone using kde log in, and the
login hung for a couple of minutes but then proceeded - it didn't do
that before.  There were no kernel messages.

-ryan


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
