From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: 2.4.19 NFSALL performance oddity
Date: 04 Oct 2002 21:48:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1033793310.4626.0.camel@camp4.serpentine.com>
References: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net>
	<shsy99ddayi.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl092-013-071.sfo1.dsl.speakeasy.net ([66.92.13.71] helo=pelerin.serpentine.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xgrg-0001KH-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Oct 2002 21:48:32 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsy99ddayi.fsf@charged.uio.no>
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

On Fri, 2002-10-04 at 16:46, Trond Myklebust wrote:

> Have you enabled CONFIG_HIGHMEM? If so, could you please try disabling
> it.

What's the issue with CONFIG_HIGHMEM, and on which machine should it be
expected to make a difference?

	<b


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
