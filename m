From: John Nitis <jnitis@ati.com>
Subject: RHEL3 Update 1 and NetApp NFS freeze issues
Date: Thu, 9 Sep 2004 17:48:23 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5D5AD1BFE69EDE4283AE056291B89499074861ED@ca00exh03.ca.atitech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5ZcR-0000DR-TZ
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 17:50:27 -0700
Received: from fwsc1.ati.com ([64.208.50.5] helo=atitech.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5ZcN-0005PI-FA
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 17:50:24 -0700
Received: from ca00exh01.ca.atitech.com (ca00exh01.ca.atitech.com [172.16.130.19])
	by atitech.com (8.9.3/8.9.3) with ESMTP id RAA29595
	for <nfs@lists.sourceforge.net>; Thu, 9 Sep 2004 17:47:30 -0700 (PDT)
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

Greetings,

This is a bit of a stab in the dark but I thought this might be a good forum
to ask for input as it has both Linux NFS experts and a NetApp expert who
are regular contributors.  We are unsure what the cause of the problem is
(even whether it's hardware or software) but one of our focuses is NFS
hangs.

Our problem is this, essentially we have an entire rack of machines (57 of
them) that lock up on a very regular basis.  They respond to ping but do not
respond to telnet, ssh, etc.  When you plug in a VGA monitor/PS2 keyboard
the screen pops up but you can't login.  When you hit enter it just echoes
back a linefeed on the screen.  A small percentage of them kernel panic.
They are all running RHEL3 WS with Update 1 installed and they're talking to
NetApp Filers with NFS via TCP.  (Same thing happened with NFS via UDP,
however it's *somewhat* less frequent with NFS via TCP).

We have "top" and "ps augxww" output logging to a file once per minute and
some of them show excessive load averages before they freeze with many
processes stuck in D (uninterruptible sleep or disk wait).  If you catch
these before the load average gets too high you can tell that a mount has
locked up (df hangs after displaying a few mounts and you can't access the
mount that's locked up).  Each new process that gets stuck adds 1 to the
load average.  The machine locks up in exactly the same way when we yank the
Ethernet cable from the box.

Previous to switching to NFS via TCP the "retrans" counter shown via nfsstat
was an extremely high percentage of total rpc calls.  Our NetApps are
extremely busy with hundreds of Linux clients pounding them with
reads/writes.  These machines are used in an EDA/engineering environment
where we have hundreds of Linux clients accessing a set of NetApp Filers via
Ethernet.  In this case the machines which crash are Opteron boxes with
Broadcom NICs using the tg3 driver.  We have RHEL3 Intel Xeon machines which
don't exhibit this problem as well as hundreds of RH7.2/7.3 clients which
don't exhibit the problem.

I've searched the list and seen much talk of NFS patches and whatnot, would
any of these be helpful to us?

Does anyone have any ideas as to what might be the problem or how we might
go about debugging it further?  I've recently set the debugging levels to
"10" in /proc/sys/sunrpc/rpc_debug and /proc/sys/sunrpc/nfs_debug to see if
that will garner some information.  A few details follow below.

Thanks very much,

John


OS version:

Red Hat Enterprise Linux WS release 3 (Taroon Update 1)

Kernel version:

Linux lscsbr3-1 2.4.21-9.ELsmp #1 SMP Thu Jan 8 16:52:31 EST 2004 x86_64
x86_64 x86_64 GNU/Linux

DataONTAP version:

6.4.1 and one filer running 6.5.1R1



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
