From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Thu, 05 Feb 2004 09:56:47 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <402178AF.4180DDC8@melbourne.sgi.com>
References: <40209B6D.56ED461E@melbourne.sgi.com> <Pine.LNX.4.58.0402042209030.26014@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoVxC-0002eP-2c
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 14:57:06 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AoVxB-0000x1-KO
	for nfs@lists.sourceforge.net; Wed, 04 Feb 2004 14:57:05 -0800
To: raven@themaw.net
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

raven@themaw.net wrote:
> 
> This message has occasionally been seen for a very log time when using
> autofs but I've never seen an oops follow it???

Good luck, I guess.  The oopses aren't deterministic, but on an Altix I
get them seconds to minutes after one of every few dozen umounts which
give the message.

The failure mode is that the NFS inode of the parent dir of the silly
renamed file remains used (i_count=1 for the leaked dentry) but i_sb points
to freed memory.  This memory gets reused and overwritten with what appears
to be ASCII strings.  Later, prune_dcache comes along and tries to get rid
of the inode, and iput dies while trying to call inode->i_sb->s_op->put_inode.
I've seen three different stack traces in oopses, all going through
prune_dcache.

> About the only thing that I'm sure of is that this happens at umount time
> in autofs, and with my latest code, only when there is a accompanying
> directory removal.

There may well be another similar bug as well.

> This is very hard to trigger so testing is difficult.

You could try turning the autofs expiry timer down to <5 sec and doing
lots of automount/create/delete/umount cycles.  FWIW, it may be relevant
that for my tests the NFS server was a lot slower than the client and
was only connected by 100BaseT.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
