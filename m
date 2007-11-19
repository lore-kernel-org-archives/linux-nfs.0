From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Mon, 19 Nov 2007 08:15:48 +0100
Message-ID: <64bb37e0711182315s1d159c80h11811acb07566f03__32100.298026535$1195459011$gmane$org@mail.gmail.com>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117180946.GA14055@elte.hu>
	<20071117101957.7562639d.akpm@linux-foundation.org>
	<64bb37e0711171140w5f1451e0qea081a4fbc7a45f7@mail.gmail.com>
	<20071117230508.GB25905@dyad>
	<64bb37e0711181044s75fd1081sdf44dac2e060d49a@mail.gmail.com>
	<1195413486.7893.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, steved@redhat.com,
	LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>, Ingo Molnar <mingo@elte.hu>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iu0rB-0000N3-7t
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 23:15:45 -0800
Received: from py-out-1112.google.com ([64.233.166.182])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iu0rH-000316-2h
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 23:15:51 -0800
Received: by py-out-1112.google.com with SMTP id a25so2720734pyi
	for <nfs@lists.sourceforge.net>; Sun, 18 Nov 2007 23:15:49 -0800 (PST)
In-Reply-To: <1195413486.7893.16.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 18, 2007 8:18 PM, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Sun, 2007-11-18 at 19:44 +0100, Torsten Kaiser wrote:
> > NFSv2/3 and NFSv4 share the same dentry_iput and so share the same
> > unlink and sillyrename logic.
> > But they do not share nfs_init_server()!
> >
> > I wonder why this doesn't blow up more violently, but only hangs...
> >
> > But as I don't know if it is correct to add the workqueue
> > initialization to nfs4_init_server() or remove the nfs_sb_active /
> > nfs_sb_deactive for the NFSv4 case, I can't offer a patch to fix this.
> >
> > Torsten
>
> I had already fixed that one in my own stack. Attached are the 3 patches
> that I've got. 1 from SteveD, 2 fixes.
>

Moving the init_waitqueue_head() like patch
linux-2.6.24-006-fix_to_fix_sillyrename_bug_on_umount.dif and applying
linux-2.6.24-007-fix_nfs_free_unlinkdata.dif lets my testcase work.
Also lockdep no longer complains about the non-static key.

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

