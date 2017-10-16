Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:46058 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752754AbdJPRH7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 13:07:59 -0400
Received: by mail-ua0-f193.google.com with SMTP id l40so10169106uah.2
        for <linux-nfs@vger.kernel.org>; Mon, 16 Oct 2017 10:07:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGL1N51N7stAqxBMWZBDMQQs+BnLGd2owA1sWfpdLLFRQ@mail.gmail.com>
References: <20171011170705.45533-1-trond.myklebust@primarydata.com> <CAN-5tyGL1N51N7stAqxBMWZBDMQQs+BnLGd2owA1sWfpdLLFRQ@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Mon, 16 Oct 2017 13:07:57 -0400
Message-ID: <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com>
Subject: Re: [PATCH v2] NFSv4.1: Fix up replays of interrupted requests
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 16, 2017 at 12:37 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Wed, Oct 11, 2017 at 1:07 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> If the previous request on a slot was interrupted before it was
>> processed by the server, then our slot sequence number may be out of whack,
>> and so we try the next operation using the old sequence number.
>>
>> The problem with this, is that not all servers check to see that the
>> client is replaying the same operations as previously when they decide
>> to go to the replay cache, and so instead of the expected error of
>> NFS4ERR_SEQ_FALSE_RETRY, we get a replay of the old reply, which could
>> (if the operations match up) be mistaken by the client for a new reply.
>>
>> To fix this, we attempt to send a COMPOUND containing only the SEQUENCE op
>> in order to resync our slot sequence number.
>>
>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>> ---
>>  fs/nfs/nfs4_fs.h  |   2 +-
>>  fs/nfs/nfs4proc.c | 146 +++++++++++++++++++++++++++++++++++++-----------------
>>  2 files changed, 101 insertions(+), 47 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index ac4f10b7f6c1..b547d935aaf0 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -464,7 +464,7 @@ extern void nfs_increment_open_seqid(int status, struct nfs_seqid *seqid);
>>  extern void nfs_increment_lock_seqid(int status, struct nfs_seqid *seqid);
>>  extern void nfs_release_seqid(struct nfs_seqid *seqid);
>>  extern void nfs_free_seqid(struct nfs_seqid *seqid);
>> -extern int nfs4_setup_sequence(const struct nfs_client *client,
>> +extern int nfs4_setup_sequence(struct nfs_client *client,
>>                                 struct nfs4_sequence_args *args,
>>                                 struct nfs4_sequence_res *res,
>>                                 struct rpc_task *task);
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index f90090e8c959..caa72efe02c9 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -96,6 +96,10 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
>>                             struct nfs_open_context *ctx, struct nfs4_label *ilabel,
>>                             struct nfs4_label *olabel);
>>  #ifdef CONFIG_NFS_V4_1
>> +static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>> +               struct rpc_cred *cred,
>> +               struct nfs4_slot *slot,
>> +               bool is_privileged);
>>  static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *,
>>                 struct rpc_cred *);
>>  static int nfs41_free_stateid(struct nfs_server *, const nfs4_stateid *,
>> @@ -644,13 +648,14 @@ static int nfs40_sequence_done(struct rpc_task *task,
>>
>>  #if defined(CONFIG_NFS_V4_1)
>>
>> -static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
>> +static void nfs41_release_slot(struct nfs4_slot *slot)
>>  {
>>         struct nfs4_session *session;
>>         struct nfs4_slot_table *tbl;
>> -       struct nfs4_slot *slot = res->sr_slot;
>>         bool send_new_highest_used_slotid = false;
>>
>> +       if (!slot)
>> +               return;
>>         tbl = slot->table;
>>         session = tbl->session;
>>
>> @@ -676,13 +681,18 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
>>                 send_new_highest_used_slotid = false;
>>  out_unlock:
>>         spin_unlock(&tbl->slot_tbl_lock);
>> -       res->sr_slot = NULL;
>>         if (send_new_highest_used_slotid)
>>                 nfs41_notify_server(session->clp);
>>         if (waitqueue_active(&tbl->slot_waitq))
>>                 wake_up_all(&tbl->slot_waitq);
>>  }
>>
>> +static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
>> +{
>> +       nfs41_release_slot(res->sr_slot);
>> +       res->sr_slot = NULL;
>> +}
>> +
>>  static int nfs41_sequence_process(struct rpc_task *task,
>>                 struct nfs4_sequence_res *res)
>>  {
>> @@ -710,13 +720,6 @@ static int nfs41_sequence_process(struct rpc_task *task,
>>         /* Check the SEQUENCE operation status */
>>         switch (res->sr_status) {
>>         case 0:
>> -               /* If previous op on slot was interrupted and we reused
>> -                * the seq# and got a reply from the cache, then retry
>> -                */
>> -               if (task->tk_status == -EREMOTEIO && interrupted) {
>> -                       ++slot->seq_nr;
>> -                       goto retry_nowait;
>> -               }
>>                 /* Update the slot's sequence and clientid lease timer */
>>                 slot->seq_done = 1;
>>                 clp = session->clp;
>> @@ -750,16 +753,16 @@ static int nfs41_sequence_process(struct rpc_task *task,
>>                  * The slot id we used was probably retired. Try again
>>                  * using a different slot id.
>>                  */
>> +               if (slot->seq_nr < slot->table->target_highest_slotid)
>> +                       goto session_recover;
>>                 goto retry_nowait;
>>         case -NFS4ERR_SEQ_MISORDERED:
>>                 /*
>>                  * Was the last operation on this sequence interrupted?
>>                  * If so, retry after bumping the sequence number.
>>                  */
>> -               if (interrupted) {
>> -                       ++slot->seq_nr;
>> -                       goto retry_nowait;
>> -               }
>> +               if (interrupted)
>> +                       goto retry_new_seq;
>>                 /*
>>                  * Could this slot have been previously retired?
>>                  * If so, then the server may be expecting seq_nr = 1!
>> @@ -768,10 +771,11 @@ static int nfs41_sequence_process(struct rpc_task *task,
>>                         slot->seq_nr = 1;
>>                         goto retry_nowait;
>>                 }
>> -               break;
>> +               goto session_recover;
>>         case -NFS4ERR_SEQ_FALSE_RETRY:
>> -               ++slot->seq_nr;
>> -               goto retry_nowait;
>> +               if (interrupted)
>> +                       goto retry_new_seq;
>> +               goto session_recover;
>>         default:
>>                 /* Just update the slot sequence no. */
>>                 slot->seq_done = 1;
>> @@ -781,6 +785,11 @@ static int nfs41_sequence_process(struct rpc_task *task,
>>         dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
>>  out_noaction:
>>         return ret;
>> +session_recover:
>> +       nfs4_schedule_session_recovery(session, res->sr_status);
>> +       goto retry_nowait;
>> +retry_new_seq:
>> +       ++slot->seq_nr;
>>  retry_nowait:
>>         if (rpc_restart_call_prepare(task)) {
>>                 nfs41_sequence_free_slot(res);
>> @@ -857,6 +866,17 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
>>         .rpc_call_done = nfs41_call_sync_done,
>>  };
>>
>> +static void
>> +nfs4_sequence_process_interrupted(struct nfs_client *client,
>> +               struct nfs4_slot *slot, struct rpc_cred *cred)
>> +{
>> +       struct rpc_task *task;
>> +
>> +       task = _nfs41_proc_sequence(client, cred, slot, true);
>> +       if (!IS_ERR(task))
>> +               rpc_put_task_async(task);
>> +}
>> +
>>  #else  /* !CONFIG_NFS_V4_1 */
>>
>>  static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
>> @@ -877,9 +897,32 @@ int nfs4_sequence_done(struct rpc_task *task,
>>  }
>>  EXPORT_SYMBOL_GPL(nfs4_sequence_done);
>>
>> +static void
>> +nfs4_sequence_process_interrupted(struct nfs_client *client,
>> +               struct nfs4_slot *slot, struct rpc_cred *cred)
>> +{
>> +       WARN_ON_ONCE(1);
>> +       slot->interrupted = 0;
>> +}
>> +
>>  #endif /* !CONFIG_NFS_V4_1 */
>>
>> -int nfs4_setup_sequence(const struct nfs_client *client,
>> +static
>> +void nfs4_sequence_attach_slot(struct nfs4_sequence_args *args,
>> +               struct nfs4_sequence_res *res,
>> +               struct nfs4_slot *slot)
>> +{
>> +       slot->privileged = args->sa_privileged ? 1 : 0;
>> +       args->sa_slot = slot;
>> +
>> +       res->sr_slot = slot;
>> +       res->sr_timestamp = jiffies;
>> +       res->sr_status_flags = 0;
>> +       res->sr_status = 1;
>> +
>> +}
>> +
>> +int nfs4_setup_sequence(struct nfs_client *client,
>>                         struct nfs4_sequence_args *args,
>>                         struct nfs4_sequence_res *res,
>>                         struct rpc_task *task)
>> @@ -897,29 +940,28 @@ int nfs4_setup_sequence(const struct nfs_client *client,
>>                 task->tk_timeout = 0;
>>         }
>>
>> -       spin_lock(&tbl->slot_tbl_lock);
>> -       /* The state manager will wait until the slot table is empty */
>> -       if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
>> -               goto out_sleep;
>> +       for (;;) {
>> +               spin_lock(&tbl->slot_tbl_lock);
>> +               /* The state manager will wait until the slot table is empty */
>> +               if (nfs4_slot_tbl_draining(tbl) && !args->sa_privileged)
>> +                       goto out_sleep;
>> +
>> +               slot = nfs4_alloc_slot(tbl);
>> +               if (IS_ERR(slot)) {
>> +                       /* Try again in 1/4 second */
>> +                       if (slot == ERR_PTR(-ENOMEM))
>> +                               task->tk_timeout = HZ >> 2;
>> +                       goto out_sleep;
>> +               }
>> +               spin_unlock(&tbl->slot_tbl_lock);
>>
>> -       slot = nfs4_alloc_slot(tbl);
>> -       if (IS_ERR(slot)) {
>> -               /* Try again in 1/4 second */
>> -               if (slot == ERR_PTR(-ENOMEM))
>> -                       task->tk_timeout = HZ >> 2;
>> -               goto out_sleep;
>> +               if (likely(!slot->interrupted))
>> +                       break;
>> +               nfs4_sequence_process_interrupted(client,
>> +                               slot, task->tk_msg.rpc_cred);
>>         }
>> -       spin_unlock(&tbl->slot_tbl_lock);
>>
>> -       slot->privileged = args->sa_privileged ? 1 : 0;
>> -       args->sa_slot = slot;
>> -
>> -       res->sr_slot = slot;
>> -       if (session) {
>> -               res->sr_timestamp = jiffies;
>> -               res->sr_status_flags = 0;
>> -               res->sr_status = 1;
>> -       }
>> +       nfs4_sequence_attach_slot(args, res, slot);
>>
>>         trace_nfs4_setup_sequence(session, args);
>>  out_start:
>> @@ -8135,6 +8177,7 @@ static const struct rpc_call_ops nfs41_sequence_ops = {
>>
>>  static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>>                 struct rpc_cred *cred,
>> +               struct nfs4_slot *slot,
>>                 bool is_privileged)
>>  {
>>         struct nfs4_sequence_data *calldata;
>> @@ -8148,15 +8191,18 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>>                 .callback_ops = &nfs41_sequence_ops,
>>                 .flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
>>         };
>> +       struct rpc_task *ret;
>>
>> +       ret = ERR_PTR(-EIO);
>>         if (!atomic_inc_not_zero(&clp->cl_count))
>> -               return ERR_PTR(-EIO);
>> +               goto out_err;
>> +
>> +       ret = ERR_PTR(-ENOMEM);
>>         calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
>> -       if (calldata == NULL) {
>> -               nfs_put_client(clp);
>> -               return ERR_PTR(-ENOMEM);
>> -       }
>> +       if (calldata == NULL)
>> +               goto out_put_clp;
>>         nfs4_init_sequence(&calldata->args, &calldata->res, 0);
>> +       nfs4_sequence_attach_slot(&calldata->args, &calldata->res, slot);
>>         if (is_privileged)
>>                 nfs4_set_sequence_privileged(&calldata->args);
>>         msg.rpc_argp = &calldata->args;
>> @@ -8164,7 +8210,15 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
>>         calldata->clp = clp;
>>         task_setup_data.callback_data = calldata;
>>
>> -       return rpc_run_task(&task_setup_data);
>> +       ret = rpc_run_task(&task_setup_data);
>> +       if (IS_ERR(ret))
>> +               goto out_err;
>> +       return ret;
>> +out_put_clp:
>> +       nfs_put_client(clp);
>> +out_err:
>> +       nfs41_release_slot(slot);
>> +       return ret;
>>  }
>>
>>  static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cred, unsigned renew_flags)
>> @@ -8174,7 +8228,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
>>
>>         if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
>>                 return -EAGAIN;
>> -       task = _nfs41_proc_sequence(clp, cred, false);
>> +       task = _nfs41_proc_sequence(clp, cred, NULL, false);
>>         if (IS_ERR(task))
>>                 ret = PTR_ERR(task);
>>         else
>> @@ -8188,7 +8242,7 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
>>         struct rpc_task *task;
>>         int ret;
>>
>> -       task = _nfs41_proc_sequence(clp, cred, true);
>> +       task = _nfs41_proc_sequence(clp, cred, NULL, true);
>>         if (IS_ERR(task)) {
>>                 ret = PTR_ERR(task);
>>                 goto out;
>> --
>
> Hi Trond,
>
> I get the following oops with this patch and triggering ctrl-c
>
> [  177.057878] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000020^M
> [  177.062500] IP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
> [  177.064119] PGD 0 P4D 0 ^M
> [  177.064896] Oops: 0002 [#1] SMP^M
> [  177.065765] Modules linked in: nfsv4 dns_resolver nfs rfcomm fuse
> xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter
> ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack
> ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc
> ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
> ip6table_mangle ip6table_security ip6table_raw iptable_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
> libcrc32c iptable_mangle iptable_security iptable_raw ebtable_filter
> ebtables ip6table_filter ip6_tables iptable_filter
> vmw_vsock_vmci_transport vsock bnep dm_mirror dm_region_hash dm_log
> dm_mod snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul
> crc32_pclmul ghash_clmulni_intel pcbc snd_ens1371 snd_ac97_codec
> aesni_intel ac97_bus crypto_simd snd_seq cryptd^M
> [  177.083060]  glue_helper snd_pcm uvcvideo ppdev videobuf2_vmalloc
> vmw_balloon videobuf2_memops videobuf2_v4l2 videobuf2_core btusb btrtl
> btbcm pcspkr btintel videodev bluetooth snd_rawmidi snd_timer
> snd_seq_device rfkill nfit sg snd ecdh_generic soundcore i2c_piix4
> libnvdimm shpchp vmw_vmci parport_pc parport nfsd auth_rpcgss nfs_acl
> lockd grace sunrpc ip_tables ext4 mbcache jbd2 sr_mod cdrom
> ata_generic sd_mod pata_acpi vmwgfx drm_kms_helper syscopyarea
> sysfillrect sysimgblt fb_sys_fops ttm ahci drm mptspi
> scsi_transport_spi mptscsih mptbase crc32c_intel libahci ata_piix
> libata serio_raw e1000 i2c_core^M
> [  177.094284] CPU: 3 PID: 57 Comm: kworker/3:1 Not tainted 4.14.0-rc2+ #40^M
> [  177.095712] Hardware name: VMware, Inc. VMware Virtual
> Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015^M
> [  177.097932] Workqueue: events nfs4_renew_state [nfsv4]^M
> [  177.099013] task: ffff8800718aae80 task.stack: ffffc90000aa8000^M
> [  177.100240] RIP: 0010:_nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
> [  177.101428] RSP: 0018:ffffc90000aabd68 EFLAGS: 00010246^M
> [  177.102577] RAX: ffff8800748e8340 RBX: ffff88003f5bd000 RCX:
> 0000000000000000^M
> [  177.104042] RDX: 00000000fffdf000 RSI: 0000000000000000 RDI:
> ffff8800748e8380^M
> [  177.105496] RBP: ffffc90000aabdf8 R08: 000000000001ee00 R09:
> ffff8800748e8340^M
> [  177.106944] R10: ffff8800748e8340 R11: 00000000000002bd R12:
> ffffc90000aabd90^M
> [  177.108510] R13: 0000000000000000 R14: 0000000000000000 R15:
> ffffffffa086b4d0^M
> [  177.109938] FS:  0000000000000000(0000) GS:ffff88007b6c0000(0000)
> knlGS:0000000000000000^M
> [  177.111644] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
> [  177.113498] CR2: 0000000000000020 CR3: 0000000072ba6001 CR4:
> 00000000001606e0^M
> [  177.115938] Call Trace:^M
> [  177.116701]  nfs41_proc_async_sequence+0x1d/0x60 [nfsv4]^M
> [  177.118266]  nfs4_renew_state+0x10b/0x1a0 [nfsv4]^M
> [  177.119628]  process_one_work+0x149/0x360^M
> [  177.120684]  worker_thread+0x4d/0x3c0^M
> [  177.121651]  kthread+0x109/0x140^M
> [  177.122505]  ? rescuer_thread+0x380/0x380^M
> [  177.123461]  ? kthread_park+0x60/0x60^M
> [  177.124338]  ret_from_fork+0x25/0x30^M
> [  177.125173] Code: e0 48 85 c0 0f 84 8e 00 00 00 0f b6 50 10 48 c7
> 40 08 00 00 00 00 48 c7 40 18 00 00 00 00 83 e2 fc 88 50 10 48 8b 15
> 93 0c 3d e1 <41> 80 66 20 fd 45 84 ed 4c 89 70 08 4c 89 70 18 c7 40 2c
> 00 00 ^M
> [  177.129700] RIP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4] RSP:
> ffffc90000aabd68^M
> [  177.131830] CR2: 0000000000000020^M
> [  177.132779] ---[ end trace 221b5aa4b7a47014 ]---^M
>
>> 2.13.6

Sorry I posted the rc2 oops not rc5 but it's the same.

Network trace reveals that server is not working properly (thus
getting Bruce's attention here).

Skipping ahead, the server replies to a SEQUENCE call with a reply
that has a count=5 operations but only has a sequence in it.

The flow of steps is the following.

Client sends
call COPY seq=16 slot=0 highslot=1(application at this point receives
a ctrl-c so it'll go ahead and close 2files it has opened)
call CLOSE  seq=1 slot=1 highslot=1
call SEQUENCE seq=16 slot=0 highslot=1
reply CLOSE OK
reply SEQUENCE ERR_DELAY
another call CLOSE seq=2 slot=1 and successful reply
reply COPY ..
call SEQUENCE seq=16 slot=0 highslot=0
reply SEQUENCE opcount=5

So I'm assuming server is replying from the reply cache for the COPY
seq=16 slot=0.. but it's only sending part of it back? Is that legit?

In any case, I think the client shouldn't be oops-ing.

[  138.136387] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000020^M
[  138.140134] IP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
[  138.141687] PGD 0 P4D 0 ^M
[  138.142462] Oops: 0002 [#1] SMP^M
[  138.143413] Modules linked in: nfsv4 dns_resolver nfs rfcomm fuse
xt_CHECKSUM ipt_MASQUERADE nf_nat_masquerade_ipv4 tun ip6t_rpfilter
ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack
ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc
ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
libcrc32c iptable_mangle iptable_security iptable_raw ebtable_filter
ebtables ip6table_filter ip6_tables iptable_filter
vmw_vsock_vmci_transport vsock bnep dm_mirror dm_region_hash dm_log
dm_mod snd_seq_midi snd_seq_midi_event coretemp crct10dif_pclmul
crc32_pclmul ghash_clmulni_intel pcbc uvcvideo snd_ens1371
snd_ac97_codec ac97_bus snd_seq ppdev videobuf2_vmalloc^M
[  138.158839]  btusb videobuf2_memops videobuf2_v4l2 videobuf2_core
aesni_intel btrtl nfit btbcm crypto_simd cryptd videodev snd_pcm
btintel glue_helper vmw_balloon libnvdimm bluetooth snd_rawmidi
snd_timer pcspkr snd_seq_device snd shpchp rfkill vmw_vmci sg
ecdh_generic soundcore i2c_piix4 parport_pc parport nfsd auth_rpcgss
nfs_acl lockd grace sunrpc ip_tables ext4 mbcache jbd2 sr_mod cdrom
sd_mod ata_generic pata_acpi vmwgfx drm_kms_helper syscopyarea
sysfillrect sysimgblt fb_sys_fops ttm drm ahci libahci crc32c_intel
ata_piix mptspi scsi_transport_spi serio_raw libata mptscsih e1000
mptbase i2c_core^M
[  138.169453] CPU: 3 PID: 541 Comm: kworker/3:3 Not tainted 4.14.0-rc5+ #41^M
[  138.170829] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015^M
[  138.172960] Workqueue: events nfs4_renew_state [nfsv4]^M
[  138.174020] task: ffff880033c80000 task.stack: ffffc90000d80000^M
[  138.175232] RIP: 0010:_nfs41_proc_sequence+0xdd/0x1a0 [nfsv4]^M
[  138.176392] RSP: 0018:ffffc90000d83d68 EFLAGS: 00010246^M
[  138.177444] RAX: ffff880073646200 RBX: ffff88002c944800 RCX:
0000000000000000^M
[  138.178932] RDX: 00000000fffd7000 RSI: 0000000000000000 RDI:
ffff880073646240^M
[  138.180357] RBP: ffffc90000d83df8 R08: 000000000001ee40 R09:
ffff880073646200^M
[  138.181955] R10: ffff880073646200 R11: 0000000000000139 R12:
ffffc90000d83d90^M
[  138.184014] R13: 0000000000000000 R14: 0000000000000000 R15:
ffffffffa08784d0^M
[  138.185439] FS:  0000000000000000(0000) GS:ffff88007b6c0000(0000)
knlGS:0000000000000000^M
[  138.187144] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033^M
[  138.188469] CR2: 0000000000000020 CR3: 0000000001c09003 CR4:
00000000001606e0^M
[  138.189952] Call Trace:^M
[  138.190478]  nfs41_proc_async_sequence+0x1d/0x60 [nfsv4]^M
[  138.191549]  nfs4_renew_state+0x10b/0x1a0 [nfsv4]^M
[  138.192555]  process_one_work+0x149/0x360^M
[  138.193367]  worker_thread+0x4d/0x3c0^M
[  138.194157]  kthread+0x109/0x140^M
[  138.194816]  ? rescuer_thread+0x380/0x380^M
[  138.195673]  ? kthread_park+0x60/0x60^M
[  138.196426]  ret_from_fork+0x25/0x30^M
[  138.197153] Code: e0 48 85 c0 0f 84 8e 00 00 00 0f b6 50 10 48 c7
40 08 00 00 00 00 48 c7 40 18 00 00 00 00 83 e2 fc 88 50 10 48 8b 15
b3 0e 3c e1 <41> 80 66 20 fd 45 84 ed 4c 89 70 08 4c 89 70 18 c7 40 2c
00 00 ^M
[  138.200991] RIP: _nfs41_proc_sequence+0xdd/0x1a0 [nfsv4] RSP:
ffffc90000d83d68^M
[  138.202431] CR2: 0000000000000020^M
[  138.203200] ---[ end trace b25c7be5ead1a406 ]---^M

>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
