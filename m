Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62129 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755115Ab2DEQau convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 12:30:50 -0400
Received: by pbcun15 with SMTP id un15so1731583pbc.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 Apr 2012 09:30:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F42D05F.802@tonian.com>
References: <4F42D05F.802@tonian.com>
Date: Thu, 5 Apr 2012 19:25:55 +0300
Message-ID: <CABpMAyLbfALnPK8S4Da8Og6c3AU0DYyhZTB6YhKBcOysLm_uHg@mail.gmail.com>
Subject: Re: 3.3-rc1 pnfs client oops
From: Idan Kedar <idank@tonian.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 21, 2012 at 12:59 AM, Benny Halevy <bhalevy@tonian.com> wrote:
> After running a Connectathon test that reported the following:
> rmdir: failed to remove `/mnt/10.41.40.52': Device or resource busy
>
> I umounted /mnt/10.41.40.52 and ran the test again.
> The client immediately oopsed with the report below.
> The problem seems to have occurred in _deviceid_purge_client:
>
>        while (!hlist_empty(&tmp)) {
>                d = hlist_entry(tmp.first, struct nfs4_deviceid_node, tmpnode);
>                hlist_del(&d->tmpnode);
>                if (atomic_dec_and_test(&d->ref))
>                        d->ld->free_deviceid_node(d);
>                               ^^^^^^^^^^^^^^^^^^^^^
>        }
>
> The machine code is:
>                        d->ld->free_deviceid_node(d);
> ffffffff8103c0fa:       48 8b 43 10             mov    0x10(%rbx),%rax
> ffffffff8103c0fe:       4c 89 ff                mov    %r15,%rdi
> ffffffff8103c101:       ff 90 98 00 00 00     callq  *0x98(%rax)
>                                                ^^^^^^^^^^^^^^^^^^
>
> Feb 20 18:50:51 vmf2-bh kernel: nfs4filelayout_init: NFSv4 File Layout Driver Registering...
> Feb 20 19:02:42 vmf2-bh kernel: hrtimer: interrupt took 2549538 ns
> Feb 20 19:02:43 vmf2-bh kernel: nfs4filelayout_exit: NFSv4 File Layout Driver Unregistering...
> Feb 20 19:02:43 vmf2-bh kernel: nfs4filelayout_init: NFSv4 File Layout Driver Registering...
> Feb 20 19:02:43 vmf2-bh kernel: Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...
> Feb 20 19:02:43 vmf2-bh kernel: BUG: unable to handle kernel paging request at ffffffffa0060628
> Feb 20 19:02:43 vmf2-bh kernel: IP: [<ffffffffa01f7e0f>] nfs4_deviceid_purge_client+0x117/0x142 [nfs]
> Feb 20 19:02:43 vmf2-bh kernel: PGD 1a07067 PUD 1a0b063 PMD 2adfb067 PTE 0
> Feb 20 19:02:43 vmf2-bh kernel: Oops: 0000 [#1] SMP
> Feb 20 19:02:43 vmf2-bh kernel: CPU 0
> Feb 20 19:02:43 vmf2-bh kernel: Modules linked in: nfs_layout_nfsv41_files nfs nfsd lockd exportfs nfs_acl auth_rpcgss sunrpc iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi e1000 ipv6 autofs4 [last unloaded: nfs_layout_nfsv41_files]
> Feb 20 19:02:43 vmf2-bh kernel:
> Feb 20 19:02:43 vmf2-bh kernel: Pid: 2758, comm: 10.41.40.52-man Not tainted 3.3.0-rc1-pnfs-00144-g2cb2f65 #82 innotek GmbH VirtualBox
> Feb 20 19:02:43 vmf2-bh kernel: RIP: 0010:[<ffffffffa01f7e0f>]  [<ffffffffa01f7e0f>] nfs4_deviceid_purge_client+0x117/0x142 [nfs]
> Feb 20 19:02:43 vmf2-bh kernel: RSP: 0018:ffff88002482bd90  EFLAGS: 00010202
> Feb 20 19:02:43 vmf2-bh kernel: RAX: ffffffffa0060590 RBX: ffff88002e39bac8 RCX: 0000000000000040
> Feb 20 19:02:43 vmf2-bh kernel: RDX: ffff88002482bd98 RSI: 0000000000000008 RDI: ffff88002e39bab8
> Feb 20 19:02:43 vmf2-bh kernel: RBP: ffff88002482bdd0 R08: ffff88002482bd30 R09: dead000000100100
> Feb 20 19:02:43 vmf2-bh kernel: R10: dead000000200200 R11: ffff880024f47a18 R12: 0000000000000014
> Feb 20 19:02:43 vmf2-bh kernel: R13: ffff880024f47a18 R14: ffff88002482bd98 R15: ffff88002e39bab8
> Feb 20 19:02:43 vmf2-bh kernel: FS:  0000000000000000(0000) GS:ffff880030800000(0000) knlGS:0000000000000000
> Feb 20 19:02:43 vmf2-bh kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Feb 20 19:02:43 vmf2-bh kernel: CR2: ffffffffa0060628 CR3: 000000002ad5d000 CR4: 00000000000006f0
> Feb 20 19:02:43 vmf2-bh kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> Feb 20 19:02:43 vmf2-bh kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Feb 20 19:02:43 vmf2-bh kernel: Process 10.41.40.52-man (pid: 2758, threadinfo ffff88002482a000, task ffff88002d090000)
> Feb 20 19:02:43 vmf2-bh kernel: Stack:
> Feb 20 19:02:43 vmf2-bh kernel: ffff88002482bda0 0000000000000000 ffff88002482bdd0 ffff880024f47a18
> Feb 20 19:02:43 vmf2-bh kernel: ffff880024f47b10 ffff880024f47b10 0000000000000004 0000000000000000
> Feb 20 19:02:43 vmf2-bh kernel: ffff88002482be30 ffffffffa01f6a8c ffff880024f47a18 0000000000000000
> Feb 20 19:02:43 vmf2-bh kernel: Call Trace:
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa01f6a8c>] pnfs_destroy_all_layouts+0x37/0x1e8 [nfs]
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa00a574f>] ? put_rpccred+0x3d/0x103 [sunrpc]
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa01eff58>] nfs4_run_state_manager+0x1a2/0x531 [nfs]
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffffa01efdb6>] ? nfs4_do_reclaim+0x47a/0x47a [nfs]
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff8105ce1f>] kthread+0xaf/0xb7
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff8108c99e>] ? trace_hardirqs_on+0xd/0xf
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff814d4c74>] kernel_thread_helper+0x4/0x10
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff814ccdb4>] ? retint_restore_args+0x13/0x13
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff8105cd70>] ? __init_kthread_worker+0x5a/0x5a
> Feb 20 19:02:43 vmf2-bh kernel: [<ffffffff814d4c70>] ? gs_change+0x13/0x13
> Feb 20 19:02:43 vmf2-bh kernel: Code: 10 00 00 00 ad de 49 ba 00 02 20 00 00 00 ad de 48 8d 7b 38 4c 89 0b 4c 89 53 08 e8 c8 fa ff ff 85 c0 74 0d 48 8b 43 10 4c 89 ff <ff> 90 98 00 00 00 48 8b 5d c8 48 85 db 75 ab 49 ff c4 49 83 fc
> Feb 20 19:02:43 vmf2-bh kernel: RIP  [<ffffffffa01f7e0f>] nfs4_deviceid_purge_client+0x117/0x142 [nfs]
> Feb 20 19:02:43 vmf2-bh kernel: RSP <ffff88002482bd90>
> Feb 20 19:02:43 vmf2-bh kernel: CR2: ffffffffa0060628
> Feb 20 19:02:43 vmf2-bh kernel: ---[ end trace 810fae7fe0f28793 ]---
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

reproduced the bug on RHEL 6.2 (2.6.32-220.el6.x86_64). the netconsole
output might be useful:

nfs4filelayout_init: NFSv4 File Layout Driver Registering...
find_pnfs_driver_locked: Searching for id 1, found (null)
pnfs_register_layoutdriver Registering id:1 name:LAYOUT_NFSV4_1_FILES
NFS: nfs mount opts='minorversion=1,addr=192.168.136.180,clientaddr=192.168.136.96'
NFS:   parsing nfs mount option 'minorversion=1'
NFS:   parsing nfs mount option 'addr=192.168.136.180'
NFS:   parsing nfs mount option 'clientaddr=192.168.136.96'
NFS: MNTPATH: '/'
--> nfs4_try_mount()
--> nfs4_create_server()
--> nfs4_init_server()
--> nfs4_set_client()
--> nfs_get_client(idank-mds,v4)
--> nfs_get_client() = ffff8800373ab800 [share]
<-- nfs4_set_client() = 0 [new ffff8800373ab800]
<-- nfs4_init_server() = 0
--> nfs4_get_rootfh()
--> nfs41_call_sync_prepare data->seq_server ffff88007a530400
--> nfs4_setup_sequence clp ffff8800373ab800 session ffff880079411000 sr_slot -1
--> nfs41_setup_sequence
--> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
<-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0
<-- nfs41_setup_sequence slotid=0 seqid=5387
<-- nfs4_setup_sequence status=0
encode_compound: tag=
encode_sequence: sessionid=1333638848:3:3:0 seqid=5387 slotid=0
max_slotid=0 cache_this=0
nfs41_sequence_done: Error -10052 free the slot
nfs4_free_slot: free_slotid 0 highest_used_slotid -1
nfs4_handle_exception ERROR: -10052 Reset session
nfs4_map_errors could not handle NFSv4 error 10052
--> nfs41_setup_sequence
--> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
<-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0
<-- nfs41_setup_sequence slotid=0 seqid=5388
encode_compound: tag=
encode_sequence: sessionid=1333638848:3:3:0 seqid=5388 slotid=0
max_slotid=0 cache_this=0
nfs41_sequence_done: Error -10052 free the slot
nfs4_free_slot: free_slotid 0 highest_used_slotid -1
--> nfs41_call_sync_prepare data->seq_server ffff88007a530400
--> nfs4_setup_sequence clp ffff8800373ab800 session ffff880079411000 sr_slot -1
--> nfs41_setup_sequence
nfs41_sequence_call_done ERROR -10052
--> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
<-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0
<-- nfs41_setup_sequence slotid=0 seqid=5389
<-- nfs4_setup_sequence status=0
encode_compound: tag=
encode_sequence: sessionid=1333638848:3:3:0 seqid=5389 slotid=0
max_slotid=0 cache_this=0
nfs41_sequence_call_done rpc_cred ffff88007dd765c0
nfs41_sequence_done: Error -10052 free the slot
nfs4_free_slot: free_slotid 0 highest_used_slotid -1
nfs4_handle_exception ERROR: -10052 Reset session
nfs4_map_errors could not handle NFSv4 error 10052
--> nfs41_call_sync_prepare data->seq_server ffff88007a530400
--> nfs4_setup_sequence clp ffff8800373ab800 session ffff880079411000 sr_slot -1
--> nfs41_setup_sequence
--> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
<-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0
<-- nfs41_setup_sequence slotid=0 seqid=5390
<-- nfs4_setup_sequence status=0
encode_compound: tag=
encode_sequence: sessionid=1333638848:3:3:0 seqid=5390 slotid=0
max_slotid=0 cache_this=0
nfs41_sequence_done: Error -10052 free the slot
<-- nfs41_sequence_call_done
nfs4_schedule_state_renewal: requeueing work. Lease period = 5
--> nfs_put_client({4})
<-- nfs4_proc_sequence status=-10052
nfs4_free_slot: free_slotid 0 highest_used_slotid -1
nfs4_check_drain_fc_complete COMPLETE: Session Fore Channel Drained
nfs4_handle_exception ERROR: -10052 Reset session
--> nfs4_proc_destroy_session
encode_compound: tag=
Got error -10052 from the server on DESTROY_SESSION. Session has been
destroyed regardless...
<-- nfs4_proc_destroy_session
--> nfs4_proc_create_session clp=ffff8800373ab800 session=ffff880079411000
nfs4_init_channel_attrs: Fore Channel : max_rqst_sz=266240
max_resp_sz=266240 max_ops=8 max_reqs=16
nfs4_init_channel_attrs: Back Channel : max_rqst_sz=4096
max_resp_sz=4096 max_resp_sz_cached=0 max_ops=2 max_reqs=1
encode_compound: tag=
<-- nfs4_proc_create_session
--> nfs4_proc_exchange_id
encode_compound: tag=
<-- nfs4_proc_exchange_id status= 0
--> nfs4_proc_create_session clp=ffff8800373ab800 session=ffff880079411000
nfs4_init_channel_attrs: Fore Channel : max_rqst_sz=266240
max_resp_sz=266240 max_ops=8 max_reqs=16
nfs4_init_channel_attrs: Back Channel : max_rqst_sz=4096
max_resp_sz=4096 max_resp_sz_cached=0 max_ops=2 max_reqs=1
encode_compound: tag=
slot table initialization returned 0
--> nfs4_reset_slot_table: max_reqs=16, tbl->max_slots 16
nfs4_reset_slot_table: tbl=ffff880079411040 slots=ffff8800373dbc40 max_slots=16
<-- nfs4_reset_slot_table: return 0
--> nfs4_reset_slot_table: max_reqs=1, tbl->max_slots 1
nfs4_reset_slot_table: tbl=ffff880079411170 slots=ffff88007d32d900 max_slots=1
<-- nfs4_reset_slot_table: return 0
slot table reset returned 0
nfs4_proc_create_session client>seqid 2 sessionid 1333638848:4:4:0
<-- nfs4_proc_create_session
--> nfs4_proc_get_lease_time
--> nfs4_get_lease_time_prepare
--> nfs41_setup_sequence
--> nfs4_find_slot used_slots=0000 highest_used=-1 max_slots=16
<-- nfs4_find_slot used_slots=0001 highest_used=0 slotid=0
<-- nfs41_setup_sequence slotid=0 seqid=1
<-- nfs4_get_lease_time_prepare
encode_compound: tag=
encode_sequence: sessionid=1333638848:4:4:0 seqid=1 slotid=0
max_slotid=0 cache_this=0
Invoking bc_svc_process()
bc_svc_process() returned w/ error code= 0
decode_attr_lease_time: file size=90
decode_attr_maxfilesize: maxfilesize=0
decode_attr_maxread: maxread=1024
decode_attr_maxwrite: maxwrite=1024
decode_attr_time_delta: time_delta=0 0
decode_attr_pnfstype: bitmap is 0
decode_fsinfo: xdr returned 0!
--> nfs4_get_lease_time_done
nfs41_sequence_done: Error 0 free the slot
nfs4_free_slot: free_slotid 0 highest_used_slotid -1
nfs4_check_drain_fc_complete COMPLETE: Session Fore Channel Drained
<-- nfs4_get_lease_time_done
<-- nfs4_proc_get_lease_time return 0
nfs4_schedule_state_renewal: requeueing work. Lease period = 60
nfs4_map_errors could not handle NFSv4 error 10052
--> nfs41_call_sync_prepare data->seq_server ffff88007a530400
--> nfs4_setup_sequence clp ffff8800373ab800 session ffff880079411000 sr_slot -1
BUG: unable to handle kernel paging request at ffffffffa04c7a28
IP: [<ffffffffa0487ad4>] nfs4_deviceid_purge_client+0x114/0x140 [nfs]
PGD 1a87067 PUD 1a8b063 PMD 7b6d6067 PTE 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/module/nfs/initstate
CPU 1
Modules linked in: nfs_layout_nfsv41_files netconsole configfs nfs
fscache nfsd lockd nfs_acl auth_rpcgss exportfs autofs4 sunrpc
ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack
ip6table_filter ip6_tables ipv6 ext3 jbd ppdev parport_pc parport sg
microcode i2c_piix4 i2c_core e1000 ext4 mbcache jbd2 sr_mod cdrom
sd_mod crc_t10dif pata_acpi ata_generic ata_piix ahci dm_mirror
dm_region_hash dm_log dm_mod [last unloaded: nfs_layout_nfsv41_files]

Pid: 25879, comm: 192.168.136.180 Not tainted 2.6.32-220.el6.x86_64 #1
innotek GmbH VirtualBox
RIP: 0010:[<ffffffffa0487ad4>]  [<ffffffffa0487ad4>]
nfs4_deviceid_purge_client+0x114/0x140 [nfs]
RSP: 0018:ffff88007cc9de20  EFLAGS: 00010202
RAX: ffffffffa04c79c0 RBX: ffff8800373ab800 RCX: ffff88007a750040
RDX: dead000000100100 RSI: 0000000000000001 RDI: ffff88003734e840
RBP: ffff88007cc9de50 R08: ffff88007cc9dd68 R09: 00000000ffffffff
R10: 0000000000000000 R11: 0000000000000000 R12: ffffffffa049a5c8
R13: ffffffffa049a580 R14: ffff88007cc9de20 R15: ffff8800373ab920
FS:  0000000000000000(0000) GS:ffff880002300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: ffffffffa04c7a28 CR3: 0000000037bb2000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process 192.168.136.180 (pid: 25879, threadinfo ffff88007cc9c000, task
ffff88007a750040)
Stack:
 0000000000000000 ffff8800373ab800 ffff8800373ab800 ffff88007cc9de60
<0> ffff8800373ab920 ffffffffa0498f60 ffff88007cc9de90 ffffffffa0486805
<0> ffff88007cc9de60 ffff88007cc9de60 ffff88007cc9de90 ffff8800373ab800
Call Trace:
 [<ffffffffa0486805>] pnfs_destroy_all_layouts+0x35/0x100 [nfs]
 [<ffffffffa0480253>] nfs4_run_state_manager+0x2f3/0x5e0 [nfs]
 [<ffffffffa047ff60>] ? nfs4_run_state_manager+0x0/0x5e0 [nfs]
 [<ffffffff81090886>] kthread+0x96/0xa0
 [<ffffffff8100c14a>] child_rip+0xa/0x20
 [<ffffffff810907f0>] ? kthread+0x0/0xa0
 [<ffffffff8100c140>] ? child_rip+0x0/0x20
Code: 48 ba 00 01 10 00 00 00 ad de 48 b8 00 02 20 00 00 00 ad de 48
89 57 10 48 89 47 18 f0 ff 4f 48 0f 94 c0 84 c0 74 b8 48 8b 47 20 <ff>
50 68 48 8b 7d d0 48 85 ff 75 b1 49 83 c4 08 49 81 fc a0 a6
RIP  [<ffffffffa0487ad4>] nfs4_deviceid_purge_client+0x114/0x140 [nfs]
 RSP <ffff88007cc9de20>
CR2: ffffffffa04c7a28
---[ end trace 67ef070afff68202 ]---
Kernel panic - not syncing: Fatal exception
Pid: 25879, comm: 192.168.136.180 Tainted: G      D
----------------   2.6.32-220.el6.x86_64 #1
Call Trace:
 [<ffffffff814ec341>] ? panic+0x78/0x143
 [<ffffffff814f04d4>] ? oops_end+0xe4/0x100
 [<ffffffff8104230b>] ? no_context+0xfb/0x260
 [<ffffffff81042595>] ? __bad_area_nosemaphore+0x125/0x1e0
 [<ffffffff81042663>] ? bad_area_nosemaphore+0x13/0x20
 [<ffffffff81042d1d>] ? __do_page_fault+0x31d/0x480
 [<ffffffff814ed8c5>] ? schedule_timeout+0x215/0x2e0
 [<ffffffff81096907>] ? down_trylock+0x37/0x50
 [<ffffffff8106a475>] ? try_acquire_console_sem+0x15/0x60
 [<ffffffff814f248e>] ? do_page_fault+0x3e/0xa0
 [<ffffffff814ef845>] ? page_fault+0x25/0x30
 [<ffffffffa0487ad4>] ? nfs4_deviceid_purge_client+0x114/0x140 [nfs]
 [<ffffffffa0486805>] ? pnfs_destroy_all_layouts+0x35/0x100 [nfs]
 [<ffffffffa0480253>] ? nfs4_run_state_manager+0x2f3/0x5e0 [nfs]
 [<ffffffffa047ff60>] ? nfs4_run_state_manager+0x0/0x5e0 [nfs]
 [<ffffffff81090886>] ? kthread+0x96/0xa0
 [<ffffffff8100c14a>] ? child_rip+0xa/0x20
 [<ffffffff810907f0>] ? kthread+0x0/0xa0
 [<ffffffff8100c140>] ? child_rip+0x0/0x20
