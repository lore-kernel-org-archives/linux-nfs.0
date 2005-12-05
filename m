From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS over localhost?
Date: Mon, 05 Dec 2005 11:25:41 -0500
Message-ID: <1133799941.8027.92.camel@lade.trondhjem.org>
References: <Pine.LNX.4.44.0512051623290.19000-100000@lothlorien.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EjJA9-0000Te-3b
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 08:26:01 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EjJA6-0006c5-9j
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 08:26:01 -0800
To: Helge Bahmann <hcb@chaoticmind.net>
In-Reply-To: <Pine.LNX.4.44.0512051623290.19000-100000@lothlorien.local>
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

On Mon, 2005-12-05 at 16:41 +0100, Helge Bahmann wrote:
> On Mon, 5 Dec 2005 Trond Myklebust wrote:
> 
> > No, that kind of deadlock is not _supposed_ to happen, but it is very
> > hard to avoid. Doing loopback mounts will always confuse the VM.
> 
> okay I understand... "Don't do that" then, at least for the moment.
> 
> > A setup in which client and server are not the same should be a lot more
> > stable, but there are scenarios where deadlocks can occur there too.
> 
> The way you phrased it really bothers me because it almost sounds like
> "expect some completely random lockups and deal with them" :) Could you
> narrow down a little bit more under what conditions such deadlocks can
> occur?
> 
> e.g. something like "it can only happen if the clients are generating
> writes faster than the server can commit to disk AND the server does have
> insufficient RAM to handle a load spike" would be very reassuring.

Problems should in principle be more or less independent of the speed at
which the client can generate writes. A modern CPU can probably write to
every page in memory before you've even got a reply from your server.

It is therefore more a question of "can I trick the VM into exhausting
some critical resource?". For NFS, the critical resources include things
like: memory for the networking stack, memory for the auxiliary daemons
rpc.gssd and rpc.idmapd, etc.

Most other things should be possible to treat by twiddling the knobs
in /proc/sys/vm/.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
