From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RHEL3 Update 1 and NetApp NFS freeze issues
Date: Thu, 09 Sep 2004 21:50:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1094781004.8363.10.camel@lade.trondhjem.org>
References: <5D5AD1BFE69EDE4283AE056291B89499074861ED@ca00exh03.ca.atitech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5aaH-0001yu-TR
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 18:52:17 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5aa9-00010F-7I
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 18:52:12 -0700
To: John Nitis <jnitis@ati.com>
In-Reply-To: <5D5AD1BFE69EDE4283AE056291B89499074861ED@ca00exh03.ca.atitech.com>
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

P=E5 to , 09/09/2004 klokka 20:48, skreiv John Nitis:

> Our problem is this, essentially we have an entire rack of machines (57 o=
f
> them) that lock up on a very regular basis.  They respond to ping but do =
not
> respond to telnet, ssh, etc.  When you plug in a VGA monitor/PS2 keyboard
> the screen pops up but you can't login.  When you hit enter it just echoe=
s
> back a linefeed on the screen.  A small percentage of them kernel panic.
> They are all running RHEL3 WS with Update 1 installed and they're talking=
 to
> NetApp Filers with NFS via TCP.  (Same thing happened with NFS via UDP,
> however it's *somewhat* less frequent with NFS via TCP).
>=20
> We have "top" and "ps augxww" output logging to a file once per minute an=
d
> some of them show excessive load averages before they freeze with many
> processes stuck in D (uninterruptible sleep or disk wait).  If you catch
> these before the load average gets too high you can tell that a mount has
> locked up (df hangs after displaying a few mounts and you can't access th=
e
> mount that's locked up).  Each new process that gets stuck adds 1 to the
> load average.  The machine locks up in exactly the same way when we yank =
the
> Ethernet cable from the box.
>=20
> Previous to switching to NFS via TCP the "retrans" counter shown via nfss=
tat
> was an extremely high percentage of total rpc calls.  Our NetApps are
> extremely busy with hundreds of Linux clients pounding them with
> reads/writes.  These machines are used in an EDA/engineering environment
> where we have hundreds of Linux clients accessing a set of NetApp Filers =
via
> Ethernet.  In this case the machines which crash are Opteron boxes with
> Broadcom NICs using the tg3 driver.  We have RHEL3 Intel Xeon machines wh=
ich
> don't exhibit this problem as well as hundreds of RH7.2/7.3 clients which
> don't exhibit the problem.

Hmm... Normally, a TCP mount should only retransmit very sporadically,
since the default value of timeo should be ~60 seconds. Are you perhaps
setting some value that is lower than the default?

Note that early versions of "amd" had a problem with the default value
too: they would set timeo=3D0.7 seconds irrespective of whether the client
was using UDP or TCP.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
