From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.20-rc1 NFS/TCP client (still) hangs running dbench 2.0
Date: Fri, 1 Nov 2002 22:58:36 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15810.63756.640223.676492@charged.uio.no>
References: <3DC2E7B6.6090400@collab.net>
	<0211011318080N.01583@stinkpad060501>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187joY-00011b-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 13:58:50 -0800
To: Andrew Ryan <andrewr@nam-shub.com>
In-Reply-To: <0211011318080N.01583@stinkpad060501>
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

>>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:

     > However, according to nfsstat -c's "Client rpc stats", I'm
     > getting around a 10:1 ratio of retransmits to calls. That's
     > bad. I get 0 retransmits when using 2.4.19+kmap1, and any
     > previous kernel I've ever tried TCP mounting with. I checked
     > 2.4.20rc1-vanilla and it does the same thing, so it's not the
     > latest patch.

It is probably just the (known) accounting error in the 'retransmit'
statistics. Try applying the patch

  http://www.fys.uio.no/~trondmy/src/2.4.20-pre9/linux-2.4.20-01-call_start.dif

if it bothers you.

Note: the TCP timeout + retransmits will (unlike UDP) be of the order
of 60 seconds, so if these were real retransmits, you'd be seeing a
*very* noticeable slowdown...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
