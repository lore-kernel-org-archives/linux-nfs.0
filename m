From: Skip Gaede <sgaede@attbi.com>
Subject: Gotchas with NFS Root filesystem?
Date: Sat, 22 Jun 2002 15:46:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200206221546.46925.sgaede@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc53.attbi.com ([204.127.198.39])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Lqt7-0001UM-00
	for <nfs@lists.sourceforge.net>; Sat, 22 Jun 2002 12:49:37 -0700
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Folks,

I have a Mac client that's running XFree86 (4.2.0) -query +
Mozilla and losing lots of size-2048 buffers. The rate loss
is approximately 1000 buffers/hour. I'm seeing this loss of
memory after I boot with an initrd, get an IP address with
dhclient and do a pivot_root onto the read-only NFS file
system.

I can also boot the the client to a bash prompt on the
 local hard drive and then run XFree86 -query + Mozilla as
 before. I went so far as to mung rc.sysinit and leave the
 local filesystem mounted RO and mount -t shm to /var and
 /tmp. Under these conditions, both with and without the
 local filesystem mounted RO, the size-2048 buffer
 utilization is nominal.

Anyone ever seen or heard of this before? Any thoughts on
how to isolate this to a root cause?

Thanks,
Skip

-------------------------------------------------------



-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
