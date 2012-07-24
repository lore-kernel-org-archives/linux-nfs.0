Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-in.ebuddy.com ([194.151.176.130]:29198 "EHLO hq.ebuddy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932247Ab2GXTEL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jul 2012 15:04:11 -0400
From: Taylan Develioglu <tdevelioglu@ebuddy.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Tue, 24 Jul 2012 20:58:43 +0200
Subject: rpc_exit_task warning.
Message-ID: <FF1DF58D04F11D4291D09795D1A4EF16180E4C4AD8@SRV-MAIL>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We just deployed a new nfs server and have about a hundred clients connected but are getting repeated kernel warnings on the server:

Clients and servers run 3.2.18 and 3.2.20 respectively. We do not use any security options.

I don't really have time to debug this, but I felt I should report it.

- Client
  ii  libevent-1.4-2                      1.4.13-stable-1
  ii  util-linux                          2.17.2-9
  ii  linux-image-3.2.0-0.bpo.2-amd64     3.2.18-1~bpo60+1
  ii  nfs-common                          1:1.2.2-4squeeze2

- Server
  ii  libevent-1.4-2                      1.4.13-stable-1
  ii  util-linux                          2.17.2-9
  ii  linux-image-3.2.0-0.bpo.2-amd64     3.2.20-1~bpo60+1
  ii  libnfsidmap2                        0.24-1~bpo60+1               
  ii  nfs-common                          1:1.2.5-4~bpo60+1            
  ii  nfs-kernel-server                   1:1.2.5-4~bpo60+1            

exportfs -v
/var/www/pictures
                x.x.x.x/22(rw,async,wdelay,root_squash,all_squash,no_subtree_check,anonuid=33,anongid=33)
/var/www/pictures
                10.40.0.0/23(rw,async,wdelay,root_squash,all_squash,no_subtree_check,anonuid=33,anongid=33)

----------------------------------------------------------------------------------------
[ 1913.662849] WARNING: at /build/buildd-linux_3.2.20-1~bpo60+1-amd64-tQMw4f/linux-3.2.20/net/sunrpc/sched.c:630 rpc_exit_task+0x40/0x7a [sunrpc]()
[ 1913.662851] Hardware name: X8STi
[ 1913.662852] Modules linked in: nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc hmac drbd lru_cache cn ipmi_si ipmi_devintf ipmi_msghandler loop tpm_tis tpm parport_pc i2c_i801 i7core_edac i2c_core snd_pcm snd_timer snd ioatdma soundcore tpm_bios snd_page_alloc parport edac_core dca pcspkr psmouse processor serio_raw thermal_sys evdev joydev button ext4 mbcache jbd2 crc16 dm_mod sg sr_mod cdrom ses enclosure sd_mod crc_t10dif usb_storage usbhid hid uas uhci_hcd mptsas mptscsih mptbase scsi_transport_sas ahci libahci ehci_hcd libata usbcore aacraid usb_common scsi_mod e1000e [last unloaded: scsi_wait_scan]
[ 1913.662902] Pid: 11, comm: kworker/0:1 Tainted: G        W    3.2.0-0.bpo.2-amd64 #1
[ 1913.662904] Call Trace:
[ 1913.662909]  [<ffffffff810498ac>] ? warn_slowpath_common+0x78/0x8c
[ 1913.662916]  [<ffffffffa0327871>] ? rpc_exit_task+0x40/0x7a [sunrpc]
[ 1913.662922]  [<ffffffffa0327ddb>] ? __rpc_execute+0x71/0x23f [sunrpc]
[ 1913.662928]  [<ffffffffa0327fe1>] ? rpc_execute+0x38/0x38 [sunrpc]
[ 1913.662981]  [<ffffffff8105f96c>] ? process_one_work+0x1cc/0x2ea
[ 1913.662985]  [<ffffffff8105fbb7>] ? worker_thread+0x12d/0x247
[ 1913.662987]  [<ffffffff8105fa8a>] ? process_one_work+0x2ea/0x2ea
[ 1913.662990]  [<ffffffff8105fa8a>] ? process_one_work+0x2ea/0x2ea
[ 1913.662993]  [<ffffffff810633c5>] ? kthread+0x7a/0x82
[ 1913.662998]  [<ffffffff8136ca74>] ? kernel_thread_helper+0x4/0x10
[ 1913.663000]  [<ffffffff8106334b>] ? kthread_worker_fn+0x147/0x147
[ 1913.663003]  [<ffffffff8136ca70>] ? gs_change+0x13/0x13
[ 1913.663005] ---[ end trace 7cee9f1fd80fe6ac ]---
----------------------------------------------------------------------------------------

Regards,

Taylan
