From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: 2.4.19 NFSALL performance oddity
Date: 05 Oct 2002 21:16:48 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1033877808.18607.6.camel@camp4.serpentine.com>
References: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net>
	<shsy99ddayi.fsf@charged.uio.no>
	<1033793310.4626.0.camel@camp4.serpentine.com>
	<shsd6qovozl.fsf@charged.uio.no> <1033851316.29937.37.camel@plokta.s8.com>
	<15775.24289.796995.465654@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl092-013-071.sfo1.dsl.speakeasy.net ([66.92.13.71] helo=pelerin.serpentine.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17y2qb-0005tB-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Oct 2002 21:16:53 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <15775.24289.796995.465654@charged.uio.no>
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

On Sat, 2002-10-05 at 14:51, Trond Myklebust wrote:

> I've seen the behaviour on stock 2.4.19 and 2.4.20-preX.

That tends to rule out the block-highmem stuff, at least, since it's
been in since 2.4.20-pre2.

	<b


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
