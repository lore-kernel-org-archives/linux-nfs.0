From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: 2.4.19 NFSALL performance oddity
Date: 05 Oct 2002 13:55:16 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1033851316.29937.37.camel@plokta.s8.com>
References: <5CA6F03EF05E0046AC5594562398B91653B9C0@poexmb3.conoco.net>
	<shsy99ddayi.fsf@charged.uio.no>
	<1033793310.4626.0.camel@camp4.serpentine.com>
	<shsd6qovozl.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from server.s8.com ([66.77.12.139])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xvxP-0000Aw-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Oct 2002 13:55:27 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsd6qovozl.fsf@charged.uio.no>
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

On Sat, 2002-10-05 at 09:18, Trond Myklebust wrote:

> I'm seeing major slowdowns, mainly on NFS reads, when I enable
> CONFIG_HIGHMEM. I haven't yet had time to investigate this.

I'll try to take a look on a local system in the next few days.  Are you
or Roger using Jens Axboe's block-highmem patch or any of the drivers it
touches?  Knowing this should help control for at least one variable.

	<b



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
