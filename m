From: Erik Walthinsen <omega@pdxcolo.net>
Subject: 2.6.5 NFS ready for production?
Date: Mon, 26 Apr 2004 10:38:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083001079.964.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIA3Q-0006my-3r
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 10:38:04 -0700
Received: from mail.pdxcolo.net ([64.146.134.17] helo=palantir.pdxcolo.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BIA3P-0001iB-R5
	for nfs@lists.sourceforge.net; Mon, 26 Apr 2004 10:38:03 -0700
Received: from omegacs.net ([216.99.212.251] helo=omicron.omegacs.net)
	by palantir.pdxcolo.net with asmtp (Exim 3.35 #1 (Debian))
	id 1BIA3O-0002GA-00
	for <nfs@lists.sourceforge.net>; Mon, 26 Apr 2004 10:38:02 -0700
To: nfs@lists.sourceforge.net
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

I'm trying to decide whether or not to even contemplate putting 2.6.5 on
our NAS server (single 2.4GHz Xeon, 512MB, 4x 200GB SATA on 3ware) to
gain the various I/O scheduling improvements, but obviously whether it's
even remotely possible depends primarily on whether NFS is up to it.

I have stock 2.6.5 on a test machine, and am getting *well* under
1MB/sec with bonnie++ over NFS on Gigabit (ttcp gets 18MB/sec, no jumbo
frames), compared to 20+MB/sec local (single old ATA disk).  Haven't
tried to pin down what precisely is causing the issue, but it begs the
question: should I even be considering 2.6's NFS as production-capable
yet?

TIA,

- Omega
  aka Erik Walthinsen
  omega@pdxcolo.net



-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
