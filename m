Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:59048 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137Ab2H1OoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Aug 2012 10:44:07 -0400
Message-ID: <503CD925.7050000@netapp.com>
Date: Tue, 28 Aug 2012 10:43:49 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Frank Nicholas <frank@nicholasfamilycentral.com>
CC: linux-nfs@vger.kernel.org,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: kernel BUG at fs/nfs/idmap.c:684!
References: <DE540E0D-0D1E-45CE-9968-DA9950497B07@nicholasfamilycentral.com> <0DDD46E4-9D32-4BA4-8BD8-22F347FC9E9B@nicholasfamilycentral.com>
In-Reply-To: <0DDD46E4-9D32-4BA4-8BD8-22F347FC9E9B@nicholasfamilycentral.com>
Content-Type: multipart/mixed;
 boundary="------------090302030102050102010401"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090302030102050102010401
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Thanks for the info, this looks like a problem we've already seen and (hopefully) fixed.  Can you try the attached patches?  They were recently added to stable, so I think that means they'll be in linux 3.5.4.

- Bryan

On 08/28/2012 08:49 AM, Frank Nicholas wrote:
> Additional information I probably should have included:
> 
> Linux martin 3.5.2-gentoo #1 SMP Fri Aug 24 09:35:54 EDT 2012 x86_64 Intel(R) Core(TM) i5-2400 CPU @ 3.10GHz GenuineIntel GNU/Linux
>  
> Gnu C                  4.6.3
> Gnu make               3.82
> binutils               2.22.90.20120727
> util-linux             2.21.2
> mount                  support
> module-init-tools      9
> e2fsprogs              1.42.5
> reiserfsprogs          3.6.21
> Linux C Library        2.15
> Dynamic linker (ldd)   2.15
> Procps                 UNKNOWN
> Net-tools              1.60_p20120127084908
> Kbd                    1.15.3wip
> Sh-utils               8.19
> Modules Loaded         vboxnetadp vboxnetflt vboxdrv
> 
> On Aug 28, 2012, at 8:42 AM, Frank Nicholas <frank@nicholasfamilycentral.com> wrote:
> 
>> The information included below is per the URL:
>> http://www.kernel.org/pub/linux/docs/lkml/reporting-bugs.html
>>
>> If different or additional information is needed, please let me know.
>>
>> Kernel version:
>> Linux martin 3.5.2-gentoo #1 SMP Fri Aug 24 09:35:54 EDT 2012 x86_64 Intel(R) Core(TM) i5-2400 CPU @ 3.10GHz GenuineIntel GNU/Linux
>> Linux version 3.5.2-gentoo (root@martin) (gcc version 4.6.3 (Gentoo 4.6.3 p1.3, pie-0.5.2) ) #1 SMP Fri Aug 24 09:35:54 EDT 2012
>> Problem also occurred in 3.5.1-gentoo.
>>
>> Modules:
>> Module                  Size  Used by
>> vboxnetadp             17542  0 
>> vboxnetflt             14893  0 
>> vboxdrv              1775582  2 vboxnetadp,vboxnetflt
>>
>> Bug trigger:
>> Solaris 11/11 (patched as of July, 2012) is serving NFS V4 to a Gentoo Linux system.  IDMAP is being used to manage users/groups.  "/etc/idmap.conf" is fairly generic except for the domain name.
>> The Gentoo "portage" tree is shared via NFS.  I initiate an 'emerge --sync'  and the condition occurs.  NFS no longer works.  The system will not restart or shut down due to the hang in NFS.  The system has to be hard powered off to clear the condition.  The bug does not trigger reliably.  The Solaris 11/11 NFS server & Gentoo Linux NFS client have been configured this way for more than a year.  
>>
>> Kernel log:
>> [160372.303310] ------------[ cut here ]------------
>> [160372.303353] kernel BUG at fs/nfs/idmap.c:684!
>> [160372.303392] invalid opcode: 0000 [#1] SMP 
>> [160372.303431] CPU 2 
>> [160372.303437] Modules linked in: vboxnetadp(O) vboxnetflt(O) vboxdrv(O)
>> [160372.303541] 
>> [160372.303572] Pid: 12852, comm: mount.nfs Tainted: G           O 3.5.2-gentoo #1 Gigabyte Technology Co., Ltd. Z68A-D3H-B3/Z68A-D3H-B3
>> [160372.303655] RIP: 0010:[<ffffffff81187e03>]  [<ffffffff81187e03>] nfs_idmap_legacy_upcall+0x323/0x330
>> [160372.303736] RSP: 0018:ffff8802421af5f8  EFLAGS: 00010282
>> [160372.303777] RAX: 0000000000000015 RBX: ffff8802ed9e5000 RCX: 0000000000000000
>> [160372.303847] RDX: 0000000000000005 RSI: ffff88026af757b9 RDI: ffff8802ed9e5017
>> [160372.303917] RBP: ffff88040d524740 R08: 000000000000003a R09: ffffffff81187b35
>> [160372.303987] R10: 00000000139c5e77 R11: 000000006138df6f R12: ffff88040b568410
>> [160372.304056] R13: ffff88040c3e5700 R14: 0000000000000015 R15: 0000000000000000
>> [160372.304128] FS:  00007f35102ca700(0000) GS:ffff88041fb00000(0000) knlGS:0000000000000000
>> [160372.304200] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [160372.304240] CR2: 00007f37a2b09880 CR3: 0000000236eae000 CR4: 00000000000407e0
>> [160372.304311] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> [160372.304382] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
>> [160372.304453] Process mount.nfs (pid: 12852, threadinfo ffff8802421ae000, task ffff8803e789be90)
>> [160372.304525] Stack:
>> [160372.304558]  ffff88026af757a4 ffff88026af757b9 ffff88040b568410 ffff8802ed9e59c0
>> [160372.304632]  ffff8802ed9e5540 ffffffff81526c0e 0000000000000000 ffffffff811ad2de
>> [160372.304707]  0000000000000000 ffff88040d53ae40 ffff88040c3e5700 ffff88040d53ae40
>> [160372.304781] Call Trace:
>> [160372.304819]  [<ffffffff811ad2de>] ? request_key_and_link+0x31e/0x450
>> [160372.304864]  [<ffffffff811ad465>] ? request_key_with_auxdata+0x15/0x60
>> [160372.304908]  [<ffffffff81187eeb>] ? nfs_idmap_request_key+0xdb/0x1c0
>> [160372.304951]  [<ffffffff811881a0>] ? nfs_idmap_lookup_id+0xe0/0x100
>> [160372.304995]  [<ffffffff811883a9>] ? nfs_map_string_to_numeric+0x29/0x90
>> [160372.305039]  [<ffffffff81182fcc>] ? decode_getfattr_attrs+0xb2c/0xb50
>> [160372.305082]  [<ffffffff8118307d>] ? decode_getfattr_generic.constprop.96+0x8d/0xe0
>> [160372.305155]  [<ffffffff811834b0>] ? nfs4_xdr_dec_link+0xf0/0xf0
>> [160372.305197]  [<ffffffff81183529>] ? nfs4_xdr_dec_lookup_root+0x79/0x80
>> [160372.305240]  [<ffffffff811834b0>] ? nfs4_xdr_dec_link+0xf0/0xf0
>> [160372.305285]  [<ffffffff81414d68>] ? rpcauth_unwrap_resp+0x58/0x60
>> [160372.305328]  [<ffffffff8140bed3>] ? call_decode+0x333/0x430
>> [160372.305370]  [<ffffffff81413776>] ? __rpc_execute+0x46/0x1e0
>> [160372.305412]  [<ffffffff810571f8>] ? wake_up_bit+0x18/0x40
>> [160372.305454]  [<ffffffff8140d529>] ? rpc_run_task+0x69/0x90
>> [160372.305496]  [<ffffffff8140d65f>] ? rpc_call_sync+0x3f/0x70
>> [160372.306028]  [<ffffffff81174e5e>] ? _nfs4_lookup_root.isra.42+0xae/0xd0
>> [160372.306072]  [<ffffffff81174ec7>] ? nfs4_lookup_root+0x47/0x80
>> [160372.306115]  [<ffffffff81179c10>] ? nfs4_proc_get_rootfh+0x30/0xd0
>> [160372.306158]  [<ffffffff8115e148>] ? nfs4_get_rootfh+0x28/0xc0
>> [160372.306200]  [<ffffffff8140cd21>] ? rpc_register_client+0x41/0x70
>> [160372.306243]  [<ffffffff81413fdb>] ? rpciod_up+0xb/0x20
>> [160372.306283]  [<ffffffff8140ce97>] ? rpc_clone_client+0x147/0x1c0
>> [160372.306326]  [<ffffffff81158290>] ? nfs4_server_common_setup+0x90/0x170
>> [160372.306369]  [<ffffffff811594fe>] ? nfs4_create_server+0x14e/0x2b0
>> [160372.306413]  [<ffffffff811625df>] ? nfs4_remote_mount+0x3f/0x90
>> [160372.306457]  [<ffffffff810d17da>] ? mount_fs+0x1a/0xd0
>> [160372.306500]  [<ffffffff810e92a3>] ? vfs_kern_mount+0x73/0x120
>> [160372.306542]  [<ffffffff81162720>] ? nfs_do_root_mount+0x90/0xe0
>> [160372.306584]  [<ffffffff81163bdf>] ? nfs_fs_mount+0x75f/0x970
>> [160372.306626]  [<ffffffff81163240>] ? nfs_fill_super+0x1d0/0x1d0
>> [160372.306669]  [<ffffffff81160720>] ? nfs_destroy_inode+0x20/0x20
>> [160372.306712]  [<ffffffff810d17da>] ? mount_fs+0x1a/0xd0
>> [160372.306753]  [<ffffffff810e92a3>] ? vfs_kern_mount+0x73/0x120
>> [160372.306795]  [<ffffffff810e9a93>] ? do_kern_mount+0x53/0x120
>> [160372.306838]  [<ffffffff810eb662>] ? do_mount+0x532/0x8a0
>> [160372.306880]  [<ffffffff810eb05a>] ? copy_mount_options+0xca/0x160
>> [160372.306922]  [<ffffffff810ebb0a>] ? sys_mount+0x9a/0x100
>> [160372.306965]  [<ffffffff8143e922>] ? system_call_fastpath+0x16/0x1b
>> [160372.307006] Code: b2 2f e9 c5 fd ff ff 90 66 c7 07 00 00 83 ea 02 48 83 c7 02 e9 72 fd ff ff 0f 1f 80 00 00 00 00 41 be f4 ff ff ff e9 22 fe ff ff <0f> 0b 66 66 2e 0f 1f 84 00 00 00 00 00 48 83 ec 58 48 89 7c 24 
>> [160372.307191] RIP  [<ffffffff81187e03>] nfs_idmap_legacy_upcall+0x323/0x330
>> [160372.307236]  RSP <ffff8802421af5f8>
>> [160372.307672] ---[ end trace fefc21185a0edeb6 ]---
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


--------------090302030102050102010401
Content-Type: text/x-patch;
 name="0001-NFS-Clear-key-construction-data-if-the-idmap-upcall-.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-NFS-Clear-key-construction-data-if-the-idmap-upcall-.pa";
 filename*1="tch"

>From c691555114d14a3e2302f0c3259ad78d6b403844 Mon Sep 17 00:00:00 2001
From: Bryan Schumaker <bjschuma@netapp.com>
Date: Tue, 7 Aug 2012 11:24:45 -0400
Subject: [PATCH 1/3] NFS: Clear key construction data if the idmap upcall
 fails

idmap_pipe_downcall already clears this field if the upcall succeeds,
but if it fails (rpc.idmapd isn't running) the field will still be set
on the next call triggering a BUG_ON().  This patch tries to handle all
possible ways that the upcall could fail and clear the idmap key data
for each one.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c            | 29 ++++++++++++++++++++++++++---
 include/linux/nfs_idmap.h |  1 +
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 66d0e85..c2b4004 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -324,6 +324,7 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 		ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
 					    name, namelen, type, data,
 					    data_size, idmap);
+		idmap->idmap_key_cons = NULL;
 		mutex_unlock(&idmap->idmap_mutex);
 	}
 	return ret;
@@ -380,11 +381,13 @@ static const match_table_t nfs_idmap_tokens = {
 static int nfs_idmap_legacy_upcall(struct key_construction *, const char *, void *);
 static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
 				   size_t);
+static void idmap_release_pipe(struct inode *);
 static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
 
 static const struct rpc_pipe_ops idmap_upcall_ops = {
 	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= idmap_pipe_downcall,
+	.release_pipe	= idmap_release_pipe,
 	.destroy_msg	= idmap_pipe_destroy_msg,
 };
 
@@ -616,7 +619,8 @@ void nfs_idmap_quit(void)
 	nfs_idmap_quit_keyring();
 }
 
-static int nfs_idmap_prepare_message(char *desc, struct idmap_msg *im,
+static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
+				     struct idmap_msg *im,
 				     struct rpc_pipe_msg *msg)
 {
 	substring_t substr;
@@ -626,6 +630,7 @@ static int nfs_idmap_prepare_message(char *desc, struct idmap_msg *im,
 	memset(msg, 0, sizeof(*msg));
 
 	im->im_type = IDMAP_TYPE_GROUP;
+	im->im_private = idmap;
 	token = match_token(desc, nfs_idmap_tokens, &substr);
 
 	switch (token) {
@@ -674,7 +679,7 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 	if (!im)
 		goto out1;
 
-	ret = nfs_idmap_prepare_message(key->description, im, msg);
+	ret = nfs_idmap_prepare_message(key->description, idmap, im, msg);
 	if (ret < 0)
 		goto out2;
 
@@ -683,10 +688,12 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 
 	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
 	if (ret < 0)
-		goto out2;
+		goto out3;
 
 	return ret;
 
+out3:
+	idmap->idmap_key_cons = NULL;
 out2:
 	kfree(im);
 out1:
@@ -775,11 +782,27 @@ out_incomplete:
 static void
 idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
+	struct idmap_msg *im = msg->data;
+	struct idmap *idmap = (struct idmap *)im->im_private;
+	struct key_construction *cons;
+	if (msg->errno) {
+		cons = ACCESS_ONCE(idmap->idmap_key_cons);
+		idmap->idmap_key_cons = NULL;
+		complete_request_key(cons, msg->errno);
+	}
 	/* Free memory allocated in nfs_idmap_legacy_upcall() */
 	kfree(msg->data);
 	kfree(msg);
 }
 
+static void
+idmap_release_pipe(struct inode *inode)
+{
+	struct rpc_inode *rpci = RPC_I(inode);
+	struct idmap *idmap = (struct idmap *)rpci->private;
+	idmap->idmap_key_cons = NULL;
+}
+
 int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index ece91c5..8a645c7 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -59,6 +59,7 @@ struct idmap_msg {
 	char  im_name[IDMAP_NAMESZ];
 	__u32 im_id;
 	__u8  im_status;
+	void *im_private;
 };
 
 #ifdef __KERNEL__
-- 
1.7.11.4


--------------090302030102050102010401
Content-Type: text/x-patch;
 name="0002-NFS-return-ENOKEY-when-the-upcall-fails-to-map-the-n.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-NFS-return-ENOKEY-when-the-upcall-fails-to-map-the-n.pa";
 filename*1="tch"

>From 4e7849b721474af0acd265c055a88fae0ae47936 Mon Sep 17 00:00:00 2001
From: Bryan Schumaker <bjschuma@netapp.com>
Date: Tue, 7 Aug 2012 15:51:59 -0400
Subject: [PATCH 2/3] NFS: return -ENOKEY when the upcall fails to map the
 name

This allows the normal error-paths to handle the error, rather than
making a special call to complete_request_key() just for this instance.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/idmap.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index c2b4004..9864b48 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -756,9 +756,8 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 	}
 
 	if (!(im.im_status & IDMAP_STATUS_SUCCESS)) {
-		ret = mlen;
-		complete_request_key(cons, -ENOKEY);
-		goto out_incomplete;
+		ret = -ENOKEY;
+		goto out;
 	}
 
 	namelen_in = strnlen(im.im_name, IDMAP_NAMESZ);
@@ -775,7 +774,6 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 
 out:
 	complete_request_key(cons, ret);
-out_incomplete:
 	return ret;
 }
 
-- 
1.7.11.4


--------------090302030102050102010401--
