From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: RE: 2.4.19 NFSALL performance oddity
Date: 09 Oct 2002 10:03:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1034183029.19855.2.camel@plokta.s8.com>
References: <5CA6F03EF05E0046AC5594562398B91653BCAE@poexmb3.conoco.net>
	<15778.2247.997239.729461@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from server.s8.com ([66.77.12.139])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zKFl-00034o-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 10:04:09 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <15778.2247.997239.729461@charged.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Mon, 2002-10-07 at 15:20, Trond Myklebust wrote:

> FYI: I updated 2.4.19-NFS_ALL on Saturday with a couple of
> bugfixes. Among them was one which fixes a queueing bottleneck when a
> timeout+resend occurs.

We've tried to reproduce Roger's numbers locally, using a patched 2.4.19
NFS_ALL server with 2G of RAM and a Red Hat 7.3 client, over 100baseT.

We could not reproduce the bad performance he's seeing.  Bonnie++ is
giving perfectly respectable numbers.

	<b



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
