From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs: clear_commit_release incorrectly handle truncated
 page
Date: Tue, 02 Feb 2010 11:17:15 -0500
Message-ID: <1265127435.3177.47.camel@localhost>
References: <87hbpzhqlp.fsf@openvz.org> <1265123045.3177.21.camel@localhost>
	 <87eil3pszw.fsf@openvz.org> <1265124999.3177.27.camel@localhost>
	 <87mxzrk4wk.fsf@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Dmitry Monakhov <dmonakhov@openvz.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39433 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756130Ab0BBQRU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2010 11:17:20 -0500
In-Reply-To: <87mxzrk4wk.fsf@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-02-02 at 18:56 +0300, Dmitry Monakhov wrote: 
> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> 
> > On Tue, 2010-02-02 at 18:17 +0300, Dmitry Monakhov wrote: 
> >> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> >> 
> >> > On Tue, 2010-02-02 at 13:36 +0300, Dmitry Monakhov wrote: 
> >> >> After page was truncated it lost it's mapping, this result in null
> >> >> pointer dereference on bdi_stat update. In fact we have to decrement
> >> >> bdi_stat even for truncated pages, so let's pass correct mapping in
> >> >> function arguments. Patch against linux-2.6
> >> >> ##TEST_CASE
> >> >> /*
> >> >> Tast case for bug in nfs_clear_request_commit()
> >> >> caused by null pointer dereference in case of truncated page.
> >> >> It takes less than 10 minutes to reproduce the bug.
> >> >
> >> > Something is wrong here. nfs_release_page() returns '0' if the 
> >> > page has an associated write request (i.e. PagePrivate is set), and so
> >> > both invalidate_complete_page() and invalidate_complete_page2() will
> >> > fail.
> >> >
> >> > So what is truncating the page?
> >> truncate_inode_page()
> >>   truncate_complete_page()
> >>     if (page_has_private(page))
> >>        do_invalidatepage()
> >>          ->nfs_invalidate_page()
> >
> > do_invalidate_page() is called before remove_from_page_cache(), so
> > page->mapping should still be set.
> Yes nfs_invalidate_page() happens before, but nfs_clear_commit_release()
> is called from rpc task after page was removed from page-cache.
> I've add following debug code in to nfs_clear_commit_release()
> + printk("page private index flags")
> + BUG_ON(!page->mapping);
> And have got following output:
> 
>  page:c5c790e0 private:f109b700  index:97656 fl:8000082c
>  ------------[ cut here ]------------
>  kernel BUG at fs/nfs/write.c:456!
>  invalid opcode: 0000 [#1] SMP 
>  last sysfs file: /sys/devices/pci0000:00/0000:00:1b.0/sound/card0/controlC0/uevent
>  Modules linked in: nfs lockd nfs_acl auth_rpcgss sunrpc binfmt_misc kvm_intel kvm radeon ttm drm_kms_helper drm i2c_algo_bit quota_v2 quota_tree snd_hda_codec_analog snd_hda_intel snd_hda_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy thinkpad_acpi snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event arc4 snd_seq iwl3945 snd_timer iwlcore snd_seq_device iptable_filter tpm_tis snd pcmcia mac80211 yenta_socket soundcore ip_tables tpm led_class psmouse rsrc_nonstatic snd_page_alloc tpm_bios x_tables nvram serio_raw sierra cfg80211 pcmcia_core raid10 raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid1 raid0 multipath linear intel_agp video output e1000e agpgart [last unloaded: nfs]
>  
>  Pid: 3646, comm: nfsiod Not tainted 2.6.33-rc4 #47 2623DDU/2623DDU
>  EIP: 0060:[<fc87ce57>] EFLAGS: 00010282 CPU: 0
>  EIP is at nfs_clear_request_commit+0xf7/0x100 [nfs]
>  EAX: 00000049 EBX: c5c790e0 ECX: c05a9a8f EDX: 05764000
>  ESI: f10d9c00 EDI: fc8968f8 EBP: c49fbebc ESP: c49fbea0
>   DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>  Process nfsiod (pid: 3646, ti=c49fa000 task=f5e3d580 task.ti=c49fa000)
>  Stack:
>   fc89b544 c5c790e0 f109b700 00017d78 8000082c f109b700 f10d9c00 c49fbefc
>  <0> fc87cee8 00000002 00000001 00000000 c01bd123 00000046 c49fbf00 f5e3d580
>  <0> f10d9d28 f10d9d30 00000000 f10d9c00 f10d9c04 f10d9c00 fc8968f8 c49fbf04
>  Call Trace:
>   [<fc87cee8>] ? nfs_commit_release+0x88/0x1a0 [nfs]
>   [<c01bd123>] ? probe_workqueue_execution+0x33/0xa0
>   [<f83ebc43>] ? rpc_release_calldata+0x13/0x20 [sunrpc]
>   [<f83ebdc1>] ? rpc_free_task+0x41/0x70 [sunrpc]
>   [<c015c2c6>] ? worker_thread+0x136/0x300
>   [<f83ebea0>] ? rpc_async_release+0x10/0x20 [sunrpc]
>   [<c015c327>] ? worker_thread+0x197/0x300
>   [<c015c2c6>] ? worker_thread+0x136/0x300
>   [<f83ebe90>] ? rpc_async_release+0x0/0x20 [sunrpc]
>   [<c015ffb0>] ? autoremove_wake_function+0x0/0x40
>   [<c015c190>] ? worker_thread+0x0/0x300
>   [<c015fbd4>] ? kthread+0x74/0x80
>   [<c015fb60>] ? kthread+0x0/0x80
>   [<c010353a>] ? kernel_thread_helper+0x6/0x10
>  Code: 0b eb fe 0f 0b eb fe 8b 03 89 44 24 10 8b 43 14 89 44 24 0c 8b 43 0c 89 5c 24 04 89 44 24 08 c7 04 24 44 b5 89 fc e8 2b 95 d2 c3 <0f> 0b eb fe 0f 0b eb fe 90 55 89 e5 57 56 53 83 ec 2c 0f 1f 44 
>  EIP: [<fc87ce57>] nfs_clear_request_commit+0xf7/0x100 [nfs] SS:ESP 0068:c49fbea0
>  ---[ end trace a852f1835725d3b2 ]---

Hmm.... There is a known problem with a reference leak in
nfs_wb_page_cancel() (I've queued up a fix for 2.6.33 in the 'bugfixes'
branch of my git tree already). What happens when you apply the
following patch?

Cheers
   Trond
------------------------------------------------------------------------------------- 
NFS: Fix a reference leak in nfs_wb_cancel_page()

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/write.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..dac8d76 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1541,6 +1541,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 			break;
 		}
 		ret = nfs_wait_on_request(req);
+		nfs_release_request(req);
 		if (ret < 0)
 			goto out;
 	}


