From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: RH 7.3 kernels and NFS performance
Date: Wed, 7 Aug 2002 08:45:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D1B4@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cT0H-0003UT-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 08:45:41 -0700
To: "'jeffrey.b.layton@lmco.com'" <jeffrey.b.layton@lmco.com>
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

hi jeff-

>    I remember reading on the list about the terrible NFS
> performance of the latest RH kernels. Would someone
> care to summarize this for me (UDP or TCP, etc.)? Also,
> does anyone have any rough estimates of the performance
> hit?

if you are referring to bad NFS client performance, this
is due to a bug in the Linux IP fragmentation logic which
causes it to send part of a fragmented packet, and drop
the rest, if it runs out of socket buffer space during
the fragmentation process.

thus it only affects NFS over UDP.

there is an easy workaround:  enlarge the size of the
RPC transport socket's buffers.  see the NFS FAQ for
instructions.

a bug was reported in the eepro100 driver too, and that
may have some effect on client performance.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
