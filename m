From: "David B. Ritch" <dritch@hpti.com>
Subject: NFS_All on alpha
Date: 03 Sep 2002 17:03:11 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1031086991.5196.53.camel@twitch>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sl-highp1-1-0.sprintlink.net ([144.228.5.138] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mKpO-0008LJ-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Sep 2002 14:03:14 -0700
To: NFS mailing list <nfs@lists.sourceforge.net>
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

I applied the nfs_all patch from
http://www.fys.uio.no/~trondmy/src/2.4.19/ to a linux-2.4.19 kernel, and
ran into trouble compiling.

In particular, the linux-2.4.19-02-fix_kmap2.dif patch defines a
conflicting type for xdr_shift_buf's second argument.  In
linux-2.4.19/include/linux/sunrpc/xdr.h, it is defined to be of type
unsigned int, and in linux-2.4.19/net/sunrpc/xdr.c, it is defined to be
of type size_t.

Size_t is defined to be __kernel_size_t in /usr/include/linux/types.h,
which is defined to be unsigned long in /usr/include/asm/posix_types.h.

On an IA32 architecture, unsigned long and unsigned int are the same, so
this is not a big deal.  However, on an alpha, a long is 64 bits,
whereas an int is only 32 bits.

Should xdr_shift_buf take an int or a long?  Are there any other known
problems for a 64-bit architecture in the nfs_all patches?

Thank you,

dbr
-- 
David B. Ritch
High Performance Technologies, Inc.


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
