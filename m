From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 2.4.20-rc1 NFS/TCP client (still) hangs running dbench
	2.0
Date: Sat, 2 Nov 2002 06:57:47 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D5503C@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, Andrew Ryan <andrewr@nam-shub.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187zix-0007yV-00
	for <nfs@lists.sourceforge.net>; Sat, 02 Nov 2002 06:58:07 -0800
To: "'trond.myklebust@fys.uio.no'" <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> >>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:
> 
>      > However, according to nfsstat -c's "Client rpc stats", I'm
>      > getting around a 10:1 ratio of retransmits to calls. That's
>      > bad. I get 0 retransmits when using 2.4.19+kmap1, and any
>      > previous kernel I've ever tried TCP mounting with. I checked
>      > 2.4.20rc1-vanilla and it does the same thing, so it's not the
>      > latest patch.
> 
> It is probably just the (known) accounting error in the 
> 'retransmit' statistics. Try applying the patch
> 
  http://www.fys.uio.no/~trondmy/src/2.4.20-pre9/linux-2.4.20-01-call_start.dif

> if it bothers you.

call_start changes the way RPCs are counted, not how retransmits are counted.

i suspect andrew is seeing partial transmits -- in 2.4.20-pre, partial
TCP transmissions are counted as retransmits.  in fact, it looks like the
patch i sent in august for 2.4.20-pre5 to fix xprt_write_space was never
applied to 2.4.  trond, can you ping marcelo on this?  it's a pretty
important performance enhancement that should be in 2.4.20.

> Note: the TCP timeout + retransmits will (unlike UDP) be of the order
> of 60 seconds, so if these were real retransmits, you'd be seeing a
> *very* noticeable slowdown...

except that mount is broken and sets a 6 second TCP retransmission default
rather than the standard value of 60 seconds.


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
