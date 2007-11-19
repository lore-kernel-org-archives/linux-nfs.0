From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Mon, 19 Nov 2007 19:24:19 +0100
Message-ID: <64bb37e0711191024m426e8c2cqe1fb968ac3a9dff0__43563.4436122656$1195500494$gmane$org@mail.gmail.com>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117180946.GA14055@elte.hu>
	<20071117101957.7562639d.akpm@linux-foundation.org>
	<64bb37e0711171140w5f1451e0qea081a4fbc7a45f7@mail.gmail.com>
	<20071117230508.GB25905@dyad>
	<64bb37e0711181044s75fd1081sdf44dac2e060d49a@mail.gmail.com>
	<1195413486.7893.16.camel@heimdal.trondhjem.org>
	<64bb37e0711182315s1d159c80h11811acb07566f03@mail.gmail.com>
	<20071119010002.9387d36b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jan Blunck <jblunck@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, steved@redhat.com,
	LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>, Ingo Molnar <mingo@elte.hu>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuBIA-0006K3-Ps
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 10:24:18 -0800
Received: from py-out-1112.google.com ([64.233.166.176])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuBID-0000fo-Gp
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 10:24:24 -0800
Received: by py-out-1112.google.com with SMTP id a25so3064904pyi
	for <nfs@lists.sourceforge.net>; Mon, 19 Nov 2007 10:24:20 -0800 (PST)
In-Reply-To: <20071119010002.9387d36b.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 19, 2007 10:00 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 19 Nov 2007 08:15:48 +0100 "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> > On Nov 18, 2007 8:18 PM, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > > I had already fixed that one in my own stack. Attached are the 3 patches
> > > that I've got. 1 from SteveD, 2 fixes.
> >
> > Moving the init_waitqueue_head() like patch
> > linux-2.6.24-006-fix_to_fix_sillyrename_bug_on_umount.dif and applying
> > linux-2.6.24-007-fix_nfs_free_unlinkdata.dif lets my testcase work.
> > Also lockdep no longer complains about the non-static key.
>
> Thanks.
>
> To avoid goofups, could you please send the full fix against 2.6.24-rc2-mm1?

Umm... As I applied this changes manually there is a not insignificant
change of goofups on my part...

For the hang problem I think Tronds suggestion with replacing the
patches from -mm with fresh versions would be the best.


Anyway, currently I have the patch from
http://lkml.org/lkml/2007/11/16/74 to fix the can't-create-files-bug.

To fix the hang bug I used Tronds
linux-2.6.24-007-fix_nfs_free_unlinkdata.dif and the first two hunks
from linux-2.6.24-006-fix_to_fix_sillyrename_bug_on_umount.dif.

Torsten

The needed 2 hunks for reference:

--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -594,9 +594,6 @@ static int nfs_init_server(struct nfs_server *server,
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
 	nfs_init_server_aclclient(server);

-	init_waitqueue_head(&server->active_wq);
-	atomic_set(&server->active, 0);
-
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;

@@ -736,6 +733,9 @@ static struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->client_link);
 	INIT_LIST_HEAD(&server->master_link);

+	init_waitqueue_head(&server->active_wq);
+	atomic_set(&server->active, 0);
+
 	server->io_stats = nfs_alloc_iostats();
 	if (!server->io_stats) {
 		kfree(server);

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

