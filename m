From: rnews@tasking.nl
Subject: Re: Stopping NFS, ip address take over, zero-copy NFS for 2.4.21, and misc
Date: Fri, 19 Sep 2003 15:35:54 -0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1342.3f6b225a.98593@altium.nl>
References: <1063900790.8031.9644.camel@localhost.localdomain>
Reply-To: dick.streefland@altium.nl (Dick Streefland)
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0NJZ-0000fT-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 08:36:57 -0700
Received: from ns.tasking.nl ([195.193.207.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A0NJY-0000wi-Ei
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 08:36:56 -0700
Received: (from root@localhost) by ns.tasking.nl (8.9.3c/8.6.12) id RAA18642 for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 17:36:49 +0200 (MET DST)
Received: by ns.tasking.nl (TUNIX txp2/smap)
	for <nfs@lists.sourceforge.net> id sma017919; Fri, 19 Sep 03 17:36:07 +0200
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
| 
| What am I missing?

You should migrate the appropriate entries from /var/lib/nfs/rmtab to
the new server. Also, when the new server uses a different device
number, you need to use the "fsid" option in /etc/exports, to avoid
changes in the NFS file handles.

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
