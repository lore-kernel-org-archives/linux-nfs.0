From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sat, 17 Nov 2007 13:58:40 -0500
Message-ID: <1195325920.7484.1.camel__35856.619620654$1195326019$gmane$org@localhost.localdomain>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-JB8J0Rnqj+uhc3kuo5ga"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItSsk-0007u7-24
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:59:06 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ItSso-0001DY-HQ
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 10:59:12 -0800
In-Reply-To: <64bb37e0711170953p67d1be49lf4eaa190d662e2b4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--=-JB8J0Rnqj+uhc3kuo5ga
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sat, 2007-11-17 at 18:53 +0100, Torsten Kaiser wrote:
> On Nov 16, 2007 3:15 PM, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> > Hi Andrew,
> >
> > The kernel enters the xmon state while running the file system
> > stress on nfs v4 mounted partition.
> [snip]
> > 0:mon> t
> > [c0000000dbd4fb50] c000000000069768 .__wake_up+0x54/0x88
> > [c0000000dbd4fc00] d00000000086b890 .nfs_sb_deactive+0x44/0x58 [nfs]
> > [c0000000dbd4fc80] d000000000872658 .nfs_free_unlinkdata+0x2c/0x74 [nfs]
> > [c0000000dbd4fd10] d000000000598510 .rpc_release_calldata+0x50/0x74 [sunrpc]
> > [c0000000dbd4fda0] c00000000008d960 .run_workqueue+0x10c/0x1f4
> > [c0000000dbd4fe50] c00000000008ec70 .worker_thread+0x118/0x138
> > [c0000000dbd4ff00] c0000000000939f4 .kthread+0x78/0xc4
> > [c0000000dbd4ff90] c00000000002b060 .kernel_thread+0x4c/0x68

Could you try with the attached patch.

Cheers
  Trond

--=-JB8J0Rnqj+uhc3kuo5ga
Content-Disposition: inline;
	filename=linux-2.6.24-007-fix_nfs_free_unlinkdata.dif
Content-Type: message/rfc822; name=linux-2.6.24-007-fix_nfs_free_unlinkdata.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 17 Nov 2007 13:52:36 -0500
Subject: NFS: Fix nfs_free_unlinkdata()
Message-Id: <1195325920.7484.2.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

We should really only be calling nfs_sb_deactive() at the end of an RPC
call, to balance the nfs_sb_active() call in nfs_do_call_unlink(). OTOH,
nfs_free_unlinkdata() can be called from a variety of other situations.

Fix is to move the call to nfs_sb_deactive() into
nfs_async_unlink_release().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/unlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index b97d3bb..c90862a 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -31,7 +31,6 @@ struct nfs_unlinkdata {
 static void
 nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
-	nfs_sb_deactive(NFS_SERVER(data->dir));
 	iput(data->dir);
 	put_rpccred(data->cred);
 	kfree(data->args.name.name);
@@ -116,6 +115,7 @@ static void nfs_async_unlink_release(void *calldata)
 	struct nfs_unlinkdata	*data = calldata;
 
 	nfs_dec_sillycount(data->dir);
+	nfs_sb_deactive(NFS_SERVER(data->dir));
 	nfs_free_unlinkdata(data);
 }
 

--=-JB8J0Rnqj+uhc3kuo5ga
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--=-JB8J0Rnqj+uhc3kuo5ga
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--=-JB8J0Rnqj+uhc3kuo5ga--



