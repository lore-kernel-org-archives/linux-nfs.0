From: "David B. Ritch" <dritch@hpti.com>
Subject: Re: mmap() and NFS server performance
Date: 14 Dec 2002 11:51:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1039884683.2767.29.camel@localhost>
References: <3DFA4C9A.50101@geodev.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pcp234914pcs.elictc01.md.comcast.net ([68.55.182.99] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18NFXM-00082e-00
	for <nfs@lists.sourceforge.net>; Sat, 14 Dec 2002 08:53:12 -0800
To: Matthew Mitchell <matthew@geodev.com>
In-Reply-To: <3DFA4C9A.50101@geodev.com>
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

When we moved some nfs clients from 2.4.18 to 2.4.20, we saw some
performance issues that initially appeared to be an nfs problem. 
However, it turned out that the upgrade apparently broke autonegotiation
between the NICs in the nodes and our network switches.  This did not
turn up immediately in network testing with tools such as netperf,
because we still had good one-way bandwidth with the nodes set to full
duplex and the switches set to half.  However, two-way traffic
immediately caused lots of problems.

I never trust autonegotiation, and turn it off whenever I can.

You may be experiencing a similar problem.

dbr

On Fri, 2002-12-13 at 16:09, Matthew Mitchell wrote:
> Hello,
> 
> We've noticed some interesting behavior regarding mmap file IO and were 
> wondering if anyone here had some clues as to what might be going on.

-- 
David B. Ritch
High Performance Technologies, Inc.


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
