From: rnews@tasking.nl
Subject: Re: Stopping NFS, ip address take over, zero-copy NFS for 2.4.21, and misc
Date: Fri, 19 Sep 2003 09:04:46 -0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <291.3f6ac6ae.b6b79@altium.nl>
References: <1063900790.8031.9644.camel@localhost.localdomain>
Reply-To: dick.streefland@altium.nl (Dick Streefland)
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0HD6-0002zL-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 02:05:52 -0700
Received: from ns.tasking.nl ([195.193.207.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A0HD5-00012o-5p
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 02:05:51 -0700
Received: (from root@localhost) by ns.tasking.nl (8.9.3c/8.6.12) id LAA25700 for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 11:05:40 +0200 (MET DST)
Received: by ns.tasking.nl (TUNIX txp2/smap)
	for <nfs@lists.sourceforge.net> id sma024617; Fri, 19 Sep 03 11:04:51 +0200
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Chris Worley <cworley@lnxi.com> wrote:
| 2) IP address takeover between NFS servers.
| 
| With NFS stateless, and not running lock servers, I thought a simple IP
| address takeover scheme (when an I/O server goes down, another just adds
| the failed server's IP address as a virtual interface) would allow
| clients to immediately renegotiate with the same IP address pointing to
| another NFS server (serving the same partitions).  The take-over is
| successful: the clients can communicate with the new I/O server, but I
| get "permission denied" (as root or otherwise) on the NFS mounted
| partitions most of the time (sometimes it works).

You need to migrate the entries in /var/lib/nfs/rmtab to the new
machine. Also, when the device number on the new machine differs
from the device number on the old machine, you need to use the "fsid"
option in /etc/exports, to make sure the file handles don't change.

-- 
Dick Streefland                      ////                      Altium BV
dick.streefland@altium.nl           (@ @)          http://www.altium.com
--------------------------------oOO--(_)--OOo---------------------------



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
