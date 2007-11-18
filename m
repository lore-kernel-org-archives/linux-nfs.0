From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: [NFS] [BUG] 2.6.24-rc2-mm1 - kernel bug on nfs v4
Date: Sun, 18 Nov 2007 19:44:19 +0100
Message-ID: <64bb37e0711181044s75fd1081sdf44dac2e060d49a__1152.00333898446$1195417102$gmane$org@mail.gmail.com>
References: <473DA608.1020804@linux.vnet.ibm.com>
	<64bb37e0711170953p67d1be49lf4eaa190d662e2b4@mail.gmail.com>
	<20071117180946.GA14055@elte.hu>
	<20071117101957.7562639d.akpm@linux-foundation.org>
	<64bb37e0711171140w5f1451e0qea081a4fbc7a45f7@mail.gmail.com>
	<20071117230508.GB25905@dyad>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, steved@redhat.com,
	LKML <linux-kernel@vger.kernel.org>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	linuxppc-dev-mnsaURCQ41sdnm+yROfE0A@public.gmane.org, nfs@lists.sourceforge.net,
	Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jan Blunck <jblunck@suse.de>, Ingo Molnar <mingo@elte.hu>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: "Peter Zijlstra" <a.p.zijlstra@chello.nl>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Itp7w-0003UX-GC
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 10:44:16 -0800
Received: from py-out-1112.google.com ([64.233.166.180])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Itp81-0006VU-Au
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 10:44:22 -0800
Received: by py-out-1112.google.com with SMTP id a25so2408057pyi
	for <nfs@lists.sourceforge.net>; Sun, 18 Nov 2007 10:44:19 -0800 (PST)
In-Reply-To: <20071117230508.GB25905@dyad>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Nov 18, 2007 12:05 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> I've been staring at this NFS code for a while an can't make any sense
> out of it. It seems to correctly initialize the waitqueue. So this would
> indicate corruption of some sort.

No, it does not "correctly" initialize the waitqueue. It doesn't even
try to initialize it.

I now found the guilty patch and what is wrong with it.

nfs-stop-sillyname-renames-and-unmounts-from-racing.patch adds:

@@ -110,8 +112,22 @@ struct nfs_server {
                                                   filesystem */
 #endif
        void (*destroy)(struct nfs_server *);
+
+       atomic_t active; /* Keep trace of any activity to this server */
+       wait_queue_head_t active_wq;  /* Wait for any activity to stop  */

and tries to initialize it:
@@ -593,6 +593,10 @@ static int nfs_init_server(struct nfs_server *server,
        server->namelen  = data->namlen;
        /* Create a client RPC handle for the NFSv3 ACL management interface */
        nfs_init_server_aclclient(server);
+
+       init_waitqueue_head(&server->active_wq);
+       atomic_set(&server->active, 0);
+

and then uses it via nfs_sb_active and nfs_sb_deactive:

@@ -29,6 +29,7 @@ struct nfs_unlinkdata {
 static void
 nfs_free_unlinkdata(struct nfs_unlinkdata *data)
 {
+       nfs_sb_deactive(NFS_SERVER(data->dir));
        iput(data->dir);
        put_rpccred(data->cred);
        kfree(data->args.name.name);
@@ -151,6 +152,7 @@ static int nfs_do_call_unlink(struct dentry
*parent, struct inode *dir, struct n
                nfs_dec_sillycount(dir);
                return 0;
        }
+       nfs_sb_active(NFS_SERVER(dir));
        data->args.fh = NFS_FH(dir);
        nfs_fattr_init(&data->res.dir_attr);


But it does not notice this:
struct dentry_operations nfs_dentry_operations = {
        .d_revalidate   = nfs_lookup_revalidate,
        .d_delete       = nfs_dentry_delete,
        .d_iput         = nfs_dentry_iput,
};
struct dentry_operations nfs4_dentry_operations = {
        .d_revalidate   = nfs_open_revalidate,
        .d_delete       = nfs_dentry_delete,
        .d_iput         = nfs_dentry_iput,
};

NFSv2/3 and NFSv4 share the same dentry_iput and so share the same
unlink and sillyrename logic.
But they do not share nfs_init_server()!

I wonder why this doesn't blow up more violently, but only hangs...

But as I don't know if it is correct to add the workqueue
initialization to nfs4_init_server() or remove the nfs_sb_active /
nfs_sb_deactive for the NFSv4 case, I can't offer a patch to fix this.

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

