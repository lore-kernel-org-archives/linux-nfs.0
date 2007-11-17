From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sat, 17 Nov 2007 20:18:49 +0100
Message-ID: <64bb37e0711171118t73a7c619p1117a5b150f369b7__36412.4718624682$1195327174$gmane$org@mail.gmail.com>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<1195325920.7484.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItTBq-0001Gf-DM
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 11:18:50 -0800
Received: from py-out-1112.google.com ([64.233.166.182])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItTBv-0002Pb-48
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 11:18:56 -0800
Received: by py-out-1112.google.com with SMTP id a25so1946027pyi
	for <nfs@lists.sourceforge.net>; Sat, 17 Nov 2007 11:18:50 -0800 (PST)
In-Reply-To: <1195325920.7484.1.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 17, 2007 7:58 PM, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
> On Sat, 2007-11-17 at 18:53 +0100, Torsten Kaiser wrote:
> > On Nov 16, 2007 3:15 PM, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> > > Hi Andrew,
> > >
> > > The kernel enters the xmon state while running the file system
> > > stress on nfs v4 mounted partition.
> > [snip]
> > > 0:mon> t
> > > [c0000000dbd4fb50] c000000000069768 .__wake_up+0x54/0x88
> > > [c0000000dbd4fc00] d00000000086b890 .nfs_sb_deactive+0x44/0x58 [nfs]
> > > [c0000000dbd4fc80] d000000000872658 .nfs_free_unlinkdata+0x2c/0x74 [nfs]
> > > [c0000000dbd4fd10] d000000000598510 .rpc_release_calldata+0x50/0x74 [sunrpc]
> > > [c0000000dbd4fda0] c00000000008d960 .run_workqueue+0x10c/0x1f4
> > > [c0000000dbd4fe50] c00000000008ec70 .worker_thread+0x118/0x138
> > > [c0000000dbd4ff00] c0000000000939f4 .kthread+0x78/0xc4
> > > [c0000000dbd4ff90] c00000000002b060 .kernel_thread+0x4c/0x68
>
> Could you try with the attached patch.
[snip]
> Fix is to move the call to nfs_sb_deactive() into
> nfs_async_unlink_release().

I realley doubt that will fix it.

My stacktrace was like:
run_workqueue
called: rpc_async_schedule
  that called: rpc_release_calldata
    which points to: nfs_async_unlink_release
       that called: nfs_free_unlinkdata

So it does not matter for me if nfs_sb_deactive is called one step earlier.

Currently building with SLAB instead SLUB to see if lockdep tells something...

Torsten

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

