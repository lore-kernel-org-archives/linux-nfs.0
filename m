From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel bug problem.
Date: 07 Oct 2003 01:46:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsbrsty4zq.fsf@charged.uio.no>
References: <04c801c38c91$d020c160$6401a8c0@Matt>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A6kgH-0004KJ-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Oct 2003 22:46:45 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A6kgF-0007eL-R5
	for nfs@lists.sourceforge.net; Mon, 06 Oct 2003 22:46:44 -0700
To: "Matt Heaton" <admin@0catch.com>
In-Reply-To: <04c801c38c91$d020c160$6401a8c0@Matt>
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

>>>>> " " =3D=3D Matt Heaton <admin@0catch.com> writes:

     > Oct=A0 4 06:29:18 catchusers2 kernel: kernel BUG at
     > ll_rw_blk.c:1192!

     > I am wondering=A0if this is NFS related?=A0

No. NFS is not a block device. That looks more like it might be
another XFS bug...

Cheers
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
