From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [GIT] Please pull  fixes for 2.6.23-rc5 nfs client
Date: Sat, 01 Sep 2007 11:24:36 -0400
Message-ID: <1188660276.6721.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755530AbXIAPYz@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi Linus,

Please pull from the "for_linus" branch of the repository at

   git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git for_linus

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/file.c          |    2 +-
 fs/nfs/namespace.c     |    2 +-
 fs/nfs/nfs4proc.c      |    4 ++--
 fs/nfs/super.c         |   20 ++++++++++----------
 fs/nfs/write.c         |   44 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h |    1 +
 6 files changed, 59 insertions(+), 14 deletions(-)

commit 1b3b4a1a2deb7d3e5d66063bd76304d840c966b3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Aug 28 10:29:36 2007 -0400

    NFS: Fix a write request leak in nfs_invalidate_page()
    
    Ryusuke Konishi says:
    
    The recent truncate_complete_page() clears the dirty flag from a page
    before calling a_ops->invalidatepage(),
    ^^^^^^
    static void
    truncate_complete_page(struct address_space *mapping, struct page *page)
    {
            ...
            cancel_dirty_page(page, PAGE_CACHE_SIZE);  <--- Inserted here at
    kernel 2.6.20
    
            if (PagePrivate(page))
                    do_invalidatepage(page, 0);   ---> will call
    a_ops->invalidatepage()
            ...
    }
    
    and this is disturbing nfs_wb_page_priority() from calling
    nfs_writepage_locked() that is expected to handle the pending
    request (=nfs_page) associated with the page.
    
    int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
    {
            ...
            if (clear_page_dirty_for_io(page)) {
                    ret = nfs_writepage_locked(page, &wbc);
                    if (ret < 0)
                            goto out;
            }
            ...
    }
    
    Since truncate_complete_page() will get rid of the page after
    a_ops->invalidatepage() returns, the request (=nfs_page) associated
    with the page becomes a garbage in nfs_inode->nfs_page_tree.
    ------------------------
    
    Fix this by ensuring that nfs_wb_page_priority() recognises that it may
    also need to clear out non-dirty pages that have an nfs_page associated
    with them.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 7d1cca72994c0e910ca443076dcfcfd473871dda
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Aug 29 17:59:03 2007 -0400

    NFS: change NFS mount error return when hostname/pathname too long
    
    According to the mount(2) man page, the proper error return code for the
    mount(2) system call when the special device name or the mounted-on
    directory name is too long is ENAMETOOLONG.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 350c73af6af51ae7654dad91874c0d30dd13bbbe
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Aug 29 17:59:01 2007 -0400

    NFS: Off-by-one length error in string handling
    
    The hostname was getting truncated in the new text-based NFS mount API.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fdc6e2c8c0dc0ac702fca0b802f5d9ae99a54bb6
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Aug 29 17:58:59 2007 -0400

    NFS: Return a real error code from mount(2)
    
    Don't filter the return code from the in-kernel rpcbind or NFS mount
    clients.  Return the real error code so that callers of the new NFS
    text-based mount API can apply a useful retry strategy.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit fdb66ff4ace3c4e18809b9b71dfcce1692143147
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Wed Aug 29 17:58:57 2007 -0400

    NFS: mount option parser chokes on proto=
    
    The new text-based NFS mount option parsing logic doesn't recognize any
    valid transport protocols due to a silly mistake in the protocol token
    matching logic.  This prevents basic mount requests such as:
    
       mount.nfs server:/export /mnt -o proto=tcp
    
    from working with the new text-based NFS mount API.
    
    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit deee9369b993b52a8e2f25683b4a67be7a65e8ae
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Aug 27 11:33:00 2007 -0400

    NFSv4: Ensure that we pass the correct dentry to nfs4_intent_set_file
    
    This patch fixes an Oops that was reported by Gabriel Barazer.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 65bbf6bdbba0f74e254f706bfb00fe533974f4f1
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Aug 27 09:57:46 2007 -0400

    NFSv4: Fix a typo in _nfs4_do_open_reclaim
    
    This should fix the following Oops reported by Jeff Garzik:
    
    kernel BUG at fs/nfs/nfs4xdr.c:1040!
    invalid opcode: 0000 [1] SMP
    CPU 0
    Modules linked in: nfs lockd sunrpc af_packet
    ipv6 cpufreq_ondemand acpi_cpufreq battery floppy nvram sg snd_hda_intel
    ata_generic snd_pcm_oss snd_mixer_oss snd_pcm i2c_i801 snd_page_alloc e1000
    firewire_ohci ata_piix i2c_core sr_mod cdrom sata_sil ahci libata sd_mod
    scsi_mod ext3 jbd ehci_hcd uhci_hcd
    Pid: 16353, comm: 10.10.10.1-recl Not tainted 2.6.23-rc3 #1
    RIP: 0010:[<ffffffff88240980>] [<ffffffff88240980>] :nfs:encode_open+0x1c0/0x330
    RSP: 0018:ffff8100467c5c60  EFLAGS: 00010202
    RAX: ffff81000f89b8b8 RBX: 00000000697a6f6d RCX: ffff81000f89b8b8
    RDX: 0000000000000004 RSI: 0000000000000004 RDI: ffff8100467c5c80
    RBP: ffff8100467c5c80 R08: ffff81000f89bc30 R09: ffff81000f89b83f
    R10: 0000000000000001 R11: ffffffff881e79e0 R12: ffff81003cbd1808
    R13: ffff81000f89b860 R14: ffff81005fc984e0 R15: ffffffff88240af0
    FS:  0000000000000000(0000) GS:ffffffff8052a000(0000) knlGS:0000000000000000
    CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
    CR2: 00002adb9e51a030 CR3: 000000007ea7e000 CR4: 00000000000006e0
    DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
    DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
    Process 10.10.10.1-recl (pid: 16353, threadinfo ffff8100467c4000, task ffff8100038ce780)
    Stack:  ffff81004aeb6a40 ffff81003cbd1808 ffff81003cbd1808 ffffffff88240b5d
     ffff81000f89b8bc ffff81005fc984e8 ffff81000f89bc30 ffff81005fc984e8
     0000000300000000 0000000000000000 0000000000000000 ffff81003cbd1800
    Call Trace:
     [<ffffffff88240b5d>] :nfs:nfs4_xdr_enc_open_noattr+0x6d/0x90
     [<ffffffff881e74b7>] :sunrpc:rpcauth_wrap_req+0x97/0xf0
     [<ffffffff88240af0>] :nfs:nfs4_xdr_enc_open_noattr+0x0/0x90
     [<ffffffff881df57a>] :sunrpc:call_transmit+0x18a/0x290
     [<ffffffff881e5e7b>] :sunrpc:__rpc_execute+0x6b/0x290
     [<ffffffff881dff76>] :sunrpc:rpc_do_run_task+0x76/0xd0
     [<ffffffff882373f6>] :nfs:_nfs4_proc_open+0x76/0x230
     [<ffffffff88237a2e>] :nfs:nfs4_open_recover_helper+0x5e/0xc0
     [<ffffffff88237b74>] :nfs:nfs4_open_recover+0xe4/0x120
     [<ffffffff88238e14>] :nfs:nfs4_open_reclaim+0xa4/0xf0
     [<ffffffff882413c5>] :nfs:nfs4_reclaim_open_state+0x55/0x1b0
     [<ffffffff882417ea>] :nfs:reclaimer+0x2ca/0x390
     [<ffffffff88241520>] :nfs:reclaimer+0x0/0x390
     [<ffffffff8024e59b>] kthread+0x4b/0x80
     [<ffffffff8020cad8>] child_rip+0xa/0x12
     [<ffffffff8024e550>] kthread+0x0/0x80
     [<ffffffff8020cace>] child_rip+0x0/0x12
    
    
    Code: 0f 0b eb fe 48 89 ef c7 00 00 00 00 02 be 08 00 00 00 e8 79
    RIP  [<ffffffff88240980>] :nfs:encode_open+0x1c0/0x330
     RSP <ffff8100467c5c60>
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 560aef74503e928f44ddbf481b8b02d9cef37dbf
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Aug 27 09:14:56 2007 -0400

    NFS: Fix use of cancel_delayed_work_sync in nfs_release_automount_timer
    
    Doh! We can't use cancel_delayed_work_sync because we may have been called
    from an unmount that was being performed by nfs_automount_task.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c87dc71..579cf8a 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -316,7 +316,7 @@ static void nfs_invalidate_page(struct page *page, unsigned long offset)
 	if (offset != 0)
 		return;
 	/* Cancel any unstarted writes on this page */
-	nfs_wb_page_priority(page->mapping->host, page, FLUSH_INVALIDATE);
+	nfs_wb_page_cancel(page->mapping->host, page);
 }
 
 static int nfs_release_page(struct page *page, gfp_t gfp)
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index aea76d0..acfc56f 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -176,7 +176,7 @@ static void nfs_expire_automounts(struct work_struct *work)
 void nfs_release_automount_timer(void)
 {
 	if (list_empty(&nfs_automount_list))
-		cancel_delayed_work_sync(&nfs_automount_task);
+		cancel_delayed_work(&nfs_automount_task);
 }
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 62b3ae2..4b90e17 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -646,7 +646,7 @@ static int _nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
 	if (delegation != NULL && (delegation->flags & NFS_DELEGATION_NEED_RECLAIM) != 0)
-		delegation_type = delegation->flags;
+		delegation_type = delegation->type;
 	rcu_read_unlock();
 	opendata->o_arg.u.delegation_type = delegation_type;
 	status = nfs4_open_recover(opendata, state);
@@ -1434,7 +1434,7 @@ nfs4_atomic_open(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 	}
 	res = d_add_unique(dentry, igrab(state->inode));
 	if (res != NULL)
-		dentry = res;
+		path.dentry = res;
 	nfs4_intent_set_file(nd, &path, state);
 	return res;
 }
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4613900..8ed5937 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -911,13 +911,13 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(string);
 
 			switch (token) {
-			case Opt_udp:
+			case Opt_xprt_udp:
 				mnt->flags &= ~NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = IPPROTO_UDP;
 				mnt->timeo = 7;
 				mnt->retrans = 5;
 				break;
-			case Opt_tcp:
+			case Opt_xprt_tcp:
 				mnt->flags |= NFS_MOUNT_TCP;
 				mnt->nfs_server.protocol = IPPROTO_TCP;
 				mnt->timeo = 600;
@@ -936,10 +936,10 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(string);
 
 			switch (token) {
-			case Opt_udp:
+			case Opt_xprt_udp:
 				mnt->mount_server.protocol = IPPROTO_UDP;
 				break;
-			case Opt_tcp:
+			case Opt_xprt_tcp:
 				mnt->mount_server.protocol = IPPROTO_TCP;
 				break;
 			default:
@@ -1153,20 +1153,20 @@ static int nfs_validate_mount_data(struct nfs_mount_data **options,
 		c = strchr(dev_name, ':');
 		if (c == NULL)
 			return -EINVAL;
-		len = c - dev_name - 1;
+		len = c - dev_name;
 		if (len > sizeof(data->hostname))
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		strncpy(data->hostname, dev_name, len);
 		args.nfs_server.hostname = data->hostname;
 
 		c++;
 		if (strlen(c) > NFS_MAXPATHLEN)
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		args.nfs_server.export_path = c;
 
 		status = nfs_try_mount(&args, mntfh);
 		if (status)
-			return -EINVAL;
+			return status;
 
 		/*
 		 * Translate to nfs_mount_data, which nfs_fill_super
@@ -1677,7 +1677,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 		/* while calculating len, pretend ':' is '\0' */
 		len = c - dev_name;
 		if (len > NFS4_MAXNAMLEN)
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		*hostname = kzalloc(len, GFP_KERNEL);
 		if (*hostname == NULL)
 			return -ENOMEM;
@@ -1686,7 +1686,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 		c++;			/* step over the ':' */
 		len = strlen(c);
 		if (len > NFS4_MAXPATHLEN)
-			return -EINVAL;
+			return -ENAMETOOLONG;
 		*mntpath = kzalloc(len + 1, GFP_KERNEL);
 		if (*mntpath == NULL)
 			return -ENOMEM;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ef97e0c..0d7a77c 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1396,6 +1396,50 @@ out:
 	return ret;
 }
 
+int nfs_wb_page_cancel(struct inode *inode, struct page *page)
+{
+	struct nfs_page *req;
+	loff_t range_start = page_offset(page);
+	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
+	struct writeback_control wbc = {
+		.bdi = page->mapping->backing_dev_info,
+		.sync_mode = WB_SYNC_ALL,
+		.nr_to_write = LONG_MAX,
+		.range_start = range_start,
+		.range_end = range_end,
+	};
+	int ret = 0;
+
+	BUG_ON(!PageLocked(page));
+	for (;;) {
+		req = nfs_page_find_request(page);
+		if (req == NULL)
+			goto out;
+		if (test_bit(PG_NEED_COMMIT, &req->wb_flags)) {
+			nfs_release_request(req);
+			break;
+		}
+		if (nfs_lock_request_dontget(req)) {
+			nfs_inode_remove_request(req);
+			/*
+			 * In case nfs_inode_remove_request has marked the
+			 * page as being dirty
+			 */
+			cancel_dirty_page(page, PAGE_CACHE_SIZE);
+			nfs_unlock_request(req);
+			break;
+		}
+		ret = nfs_wait_on_request(req);
+		if (ret < 0)
+			goto out;
+	}
+	if (!PagePrivate(page))
+		return 0;
+	ret = nfs_sync_mapping_wait(page->mapping, &wbc, FLUSH_INVALIDATE);
+out:
+	return ret;
+}
+
 int nfs_wb_page_priority(struct inode *inode, struct page *page, int how)
 {
 	loff_t range_start = page_offset(page);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 157dcb0..7250eea 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -431,6 +431,7 @@ extern int nfs_sync_mapping_range(struct address_space *, loff_t, loff_t, int);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_priority(struct inode *inode, struct page* page, int how);
+extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commit_alloc(void);
