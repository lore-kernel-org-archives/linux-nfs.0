From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [PATCH 7/8] pnfs-submit: forgetful client (layouts)
Date: Tue, 8 Jun 2010 00:51:16 -0700
Message-ID: <AANLkTim0-Gb7a-YPTgtLHY3r4OVP2x-nasug6sd_zjt9@mail.gmail.com>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com>
	<1275945113-3436-2-git-send-email-batsakis@netapp.com>
	<1275945113-3436-3-git-send-email-batsakis@netapp.com>
	<1275945113-3436-4-git-send-email-batsakis@netapp.com>
	<1275945113-3436-5-git-send-email-batsakis@netapp.com>
	<1275945113-3436-6-git-send-email-batsakis@netapp.com>
	<1275945113-3436-7-git-send-email-batsakis@netapp.com>
	<1275945113-3436-8-git-send-email-batsakis@netapp.com>
	<4C0DF003.4010509@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56521 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab0FHHvS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jun 2010 03:51:18 -0400
Received: by gye5 with SMTP id 5so2871192gye.19
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jun 2010 00:51:17 -0700 (PDT)
In-Reply-To: <4C0DF003.4010509@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 8, 2010 at 12:23 AM, Benny Halevy <bhalevy@panasas.com> wro=
te:
> On Jun. 08, 2010, 0:11 +0300, Alexandros Batsakis <batsakis-HgOvQuBEEgRhl2p70BpVqQ@public.gmane.org=
m> wrote:
>> Forgetful client model:
>>
>> If we receive a CB_LAYOUTRECALL
>> =A0 =A0 =A0 =A0 - we spawn a thread to handle the recall
>> =A0 =A0 =A0 =A0 (xxx: now only one recall can be active at a time, e=
lse NFS4ERR_DELAY)
>> =A0 =A0 =A0 =A0 - we check the stateid seqid
>> =A0 =A0 =A0 =A0 if it does not match we return NFS4ERR_DELAY
>> =A0 =A0 =A0 =A0 - we check for pending I/O
>> =A0 =A0 =A0 =A0 if there is we return NFS4ERR_DELAY
>> =A0 =A0 =A0 =A0 Else we return NO_MATCHING_LAYOUT.
>> =A0 =A0 =A0 =A0 Note that for whole file layouts there is no need to=
 serialize LAYOUTGETs/LAYOUTRETURNs
>> For bulk layouts, if there is a layout active, we return NFS4_OK and=
 we start
>> cleaning the layouts asynchronously. At the end we send a bulk LAYOU=
TRETURN.
>> Note that there is no need to prevent any new LAYOUTGETs explicitly =
as the server should reject them.
>>
>> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
>> ---
>> =A0fs/nfs/callback_proc.c | =A0146 +++++++++++++++++++++++++++++++++=
+--------------
>> =A0fs/nfs/nfs4_fs.h =A0 =A0 =A0 | =A0 =A01 +
>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0| =A0 70 ++++++++++-------------
>> =A03 files changed, 136 insertions(+), 81 deletions(-)
>>
>> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
>> index 3bae785..af7a01d 100644
>> --- a/fs/nfs/callback_proc.c
>> +++ b/fs/nfs/callback_proc.c
>> @@ -129,6 +129,38 @@ int nfs4_validate_delegation_stateid(struct nfs=
_delegation *delegation, const nf
>>
>> =A0#if defined(CONFIG_NFS_V4_1)
>>
>> +static bool
>> +pnfs_is_next_layout_stateid(const struct pnfs_layout_type *lo,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const nfs4_stateid=
 stateid)
>> +{
>> + =A0 =A0 int seqlock;
>> + =A0 =A0 bool res;
>> + =A0 =A0 u32 oldseqid, newseqid;
>> +
>> + =A0 =A0 do {
>> + =A0 =A0 =A0 =A0 =A0 =A0 seqlock =3D read_seqbegin(&lo->seqlock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 oldseqid =3D be32_to_cpu(lo->stateid.u.sta=
teid.seqid);
>> + =A0 =A0 =A0 =A0 =A0 =A0 newseqid =3D be32_to_cpu(stateid.u.stateid=
=2Eseqid);
>> + =A0 =A0 =A0 =A0 =A0 =A0 res =3D !memcmp(lo->stateid.u.stateid.othe=
r,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stateid.u.stat=
eid.other,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NFS4_STATEID_O=
THER_SIZE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (res) { /* comparing layout stateids */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (oldseqid =3D=3D ~0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D (n=
ewseqid =3D=3D 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D (n=
ewseqid =3D=3D oldseqid + 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else { /* open stateid */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D !memcmp(lo->statei=
d.u.data,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 &zero_stateid,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 NFS4_STATEID_SIZE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D (n=
ewseqid =3D=3D 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 } while (read_seqretry(&lo->seqlock, seqlock));
>> +
>> + =A0 =A0 return res;
>> +}
>> +
>> =A0/*
>> =A0 * Retrieve an inode based on layout recall parameters
>> =A0 *
>> @@ -191,9 +223,10 @@ static int pnfs_recall_layout(void *data)
>> =A0 =A0 =A0 struct inode *inode, *ino;
>> =A0 =A0 =A0 struct nfs_client *clp;
>> =A0 =A0 =A0 struct cb_pnfs_layoutrecallargs rl;
>> + =A0 =A0 struct nfs4_pnfs_layoutreturn *lrp;
>> =A0 =A0 =A0 struct recall_layout_threadargs *args =3D
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct recall_layout_threadargs *)data;
>> - =A0 =A0 int status;
>> + =A0 =A0 int status =3D 0;
>>
>> =A0 =A0 =A0 daemonize("nfsv4-layoutreturn");
>>
>> @@ -204,47 +237,59 @@ static int pnfs_recall_layout(void *data)
>> =A0 =A0 =A0 clp =3D args->clp;
>> =A0 =A0 =A0 inode =3D args->inode;
>> =A0 =A0 =A0 rl =3D *args->rl;
>> - =A0 =A0 args->result =3D 0;
>> - =A0 =A0 complete(&args->started);
>> - =A0 =A0 args =3D NULL;
>> - =A0 =A0 /* Note: args must not be used after this point!!! */
>> -
>> -/* FIXME: need barrier here:
>> - =A0 pause I/O to data servers
>> - =A0 pause layoutgets
>> - =A0 drain all outstanding writes to storage devices
>> - =A0 wait for any outstanding layoutreturns and layoutgets mentione=
d in
>> - =A0 cb_sequence.
>> - =A0 then return layouts, resume after layoutreturns complete
>> - */
>>
>> =A0 =A0 =A0 /* support whole file layouts only */
>> =A0 =A0 =A0 rl.cbl_seg.offset =3D 0;
>> =A0 =A0 =A0 rl.cbl_seg.length =3D NFS4_MAX_UINT64;
>>
>> =A0 =A0 =A0 if (rl.cbl_recall_type =3D=3D RETURN_FILE) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_return_layout(inode, &rl.c=
bl_seg, &rl.cbl_stateid,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 RETURN_FILE, true);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pnfs_is_next_layout_stateid(&NFS_I(ino=
de)->layout,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 rl.cbl_stateid))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_return_lay=
out(inode, &rl.cbl_seg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &rl.cbl_stateid, RETURN_FILE,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 false);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D cpu_to_be32(NFS=
4ERR_DELAY);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s RETURN_FILE =
error: %d\n", __func__, status);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D =A0cpu_to_be32(=
NFS4ERR_NOMATCHING_LAYOUT);
>> + =A0 =A0 =A0 =A0 =A0 =A0 args->result =3D status;
>> + =A0 =A0 =A0 =A0 =A0 =A0 complete(&args->started);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 /* FIXME: This loop is inefficient, running in O(|s_inodes=
|^2) */
>> + =A0 =A0 status =3D cpu_to_be32(NFS4_OK);
>> + =A0 =A0 args->result =3D status;
>> + =A0 =A0 complete(&args->started);
>> + =A0 =A0 args =3D NULL;
>> +
>> + =A0 =A0 /* IMPROVEME: This loop is inefficient, running in O(|s_in=
odes|^2) */
>> =A0 =A0 =A0 while ((ino =3D nfs_layoutrecall_find_inode(clp, &rl)) !=
=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 /* XXX need to check status on pnfs_return=
_layout */
>> - =A0 =A0 =A0 =A0 =A0 =A0 pnfs_return_layout(ino, &rl.cbl_seg, NULL,=
 RETURN_FILE, true);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* FIXME: need to check status on pnfs_ret=
urn_layout */
>> + =A0 =A0 =A0 =A0 =A0 =A0 pnfs_return_layout(ino, &rl.cbl_seg, NULL,=
 RETURN_FILE, false);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 iput(ino);
>> =A0 =A0 =A0 }
>>
>> + =A0 =A0 lrp =3D kzalloc(sizeof(*lrp), GFP_KERNEL);
>> + =A0 =A0 if (!lrp) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: allocation failed. Cannot sen=
d last LAYOUTRETURN\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 /* send final layoutreturn */
>> - =A0 =A0 status =3D pnfs_return_layout(inode, &rl.cbl_seg, NULL,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rl=
=2Ecbl_recall_type, true);
>> - =A0 =A0 if (status)
>> - =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO "%s: ignoring pnfs_return=
_layout status=3D%d\n",
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, =
status);
>> + =A0 =A0 lrp->args.reclaim =3D 0;
>> + =A0 =A0 lrp->args.layout_type =3D rl.cbl_layout_type;
>> + =A0 =A0 lrp->args.return_type =3D rl.cbl_recall_type;
>> + =A0 =A0 lrp->args.lseg =3D rl.cbl_seg;
>> + =A0 =A0 lrp->args.inode =3D inode;
>> + =A0 =A0 lrp->lo =3D NULL;
>> + =A0 =A0 pnfs4_proc_layoutreturn(lrp, true);
>> +
>> =A0out:
>> - =A0 =A0 iput(inode);
>> + =A0 =A0 clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
>> + =A0 =A0 nfs_put_client(clp);
>> =A0 =A0 =A0 module_put_and_exit(0);
>> =A0 =A0 =A0 dprintk("%s: exit status %d\n", __func__, 0);
>> =A0 =A0 =A0 return 0;
>> @@ -262,15 +307,18 @@ static int pnfs_async_return_layout(struct nfs=
_client *clp, struct inode *inode,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .rl =3D rl,
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 struct task_struct *t;
>> - =A0 =A0 int status;
>> -
>> - =A0 =A0 /* should have returned NFS4ERR_NOMATCHING_LAYOUT... */
>> - =A0 =A0 BUG_ON(inode =3D=3D NULL);
>> + =A0 =A0 int status =3D -EAGAIN;
>>
>> =A0 =A0 =A0 dprintk("%s: -->\n", __func__);
>>
>> + =A0 =A0 /* FIXME: do not allow two concurrent layout recalls */
>> + =A0 =A0 if (test_and_set_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_stat=
e))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return status;
>> +
>> =A0 =A0 =A0 init_completion(&data.started);
>> =A0 =A0 =A0 __module_get(THIS_MODULE);
>> + =A0 =A0 if (!atomic_inc_not_zero(&clp->cl_count))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_put_no_client;
>>
>> =A0 =A0 =A0 t =3D kthread_run(pnfs_recall_layout, &data, "%s", "pnfs=
_recall_layout");
>> =A0 =A0 =A0 if (IS_ERR(t)) {
>> @@ -284,6 +332,9 @@ static int pnfs_async_return_layout(struct nfs_c=
lient *clp, struct inode *inode,
>> =A0 =A0 =A0 wait_for_completion(&data.started);
>> =A0 =A0 =A0 return data.result;
>> =A0out_module_put:
>> + =A0 =A0 nfs_put_client(clp);
>> +out_put_no_client:
>> + =A0 =A0 clear_bit(NFS4CLNT_LAYOUT_RECALL, &clp->cl_state);
>> =A0 =A0 =A0 module_put(THIS_MODULE);
>> =A0 =A0 =A0 return status;
>> =A0}
>> @@ -294,35 +345,46 @@ __be32 pnfs_cb_layoutrecall(struct cb_pnfs_lay=
outrecallargs *args,
>> =A0 =A0 =A0 struct nfs_client *clp;
>> =A0 =A0 =A0 struct inode *inode =3D NULL;
>> =A0 =A0 =A0 __be32 res;
>> + =A0 =A0 int status;
>> =A0 =A0 =A0 unsigned int num_client =3D 0;
>>
>> =A0 =A0 =A0 dprintk("%s: -->\n", __func__);
>>
>> - =A0 =A0 res =3D htonl(NFS4ERR_INVAL);
>> - =A0 =A0 clp =3D nfs_find_client(args->cbl_addr, 4);
>> + =A0 =A0 res =3D cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
>> + =A0 =A0 clp =A0=3D nfs_find_client(args->cbl_addr, 4);
>> =A0 =A0 =A0 if (clp =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: no client for addr %u.%u.%u=
=2E%u\n",
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, NIPQUAD(args->=
cbl_addr));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 res =3D htonl(NFS4ERR_NOMATCHING_LAYOUT);
>> + =A0 =A0 res =3D cpu_to_be32(NFS4ERR_NOMATCHING_LAYOUT);
>> =A0 =A0 =A0 do {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs_client *prev =3D clp;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 num_client++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 inode =3D nfs_layoutrecall_find_inode(clp,=
 args);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (inode !=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PNFS_LD(&NFS_I(inode)-=
>layout)->id =3D=3D
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 args->cbl_layout_t=
ype) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Set up =
a helper thread to actually
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* retur=
n the delegation */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D pn=
fs_async_return_layout(clp, inode, args);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res !=3D=
 0)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 res =3D htonl(NFS4ERR_RESOURCE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* the callback must come from the MDS per=
sonality */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!(clp->cl_exchange_flags & EXCHGID4_FL=
AG_USE_PNFS_MDS))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto loop;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (args->cbl_recall_type =3D=3D RETURN_FI=
LE) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inode =3D nfs_layoutrecall=
_find_inode(clp, args);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (inode !=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 pnfs_async_return_layout(clp, inode,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 args);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status=
 =3D=3D -EAGAIN)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 res =3D cpu_to_be32(NFS4ERR_DELAY);
>
> what about other errors?
>

pnfs_async_return_layout does not send any RPCs, so it's either EAGAIN
or an "out of memory" error in which case I guess it's better to
return NFS4ERR_RESOURCE than NFS4ERR_NO_MATCHING_LAYOUT. So you are
right, I ll send a fix.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iput(inode=
);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else { /* _ALL or _FSID */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we need the inode to ge=
t the nfs_server struct */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inode =3D nfs_layoutrecall=
_find_inode(clp, args);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!inode)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto loop;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_async_retu=
rn_layout(clp, inode, args);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status =3D=3D -EAGAIN)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res =3D cp=
u_to_be32(NFS4ERR_DELAY);
>
> ditto
>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iput(inode);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +loop:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 clp =3D nfs_find_client_next(prev);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nfs_put_client(prev);
>> =A0 =A0 =A0 } while (clp !=3D NULL);
>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>> index ebc9b3b..2f7974b 100644
>> --- a/fs/nfs/nfs4_fs.h
>> +++ b/fs/nfs/nfs4_fs.h
>> @@ -47,6 +47,7 @@ enum nfs4_client_state {
>> =A0 =A0 =A0 NFS4CLNT_SESSION_RESET,
>> =A0 =A0 =A0 NFS4CLNT_SESSION_DRAINING,
>> =A0 =A0 =A0 NFS4CLNT_RECALL_SLOT,
>> + =A0 =A0 NFS4CLNT_LAYOUT_RECALL,
>> =A0};
>>
>> =A0/*
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index d0b45bf..2006926 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -709,6 +709,8 @@ return_layout(struct inode *ino, struct nfs4_pnf=
s_layout_segment *range,
>>
>> =A0 =A0 =A0 dprintk("--> %s\n", __func__);
>>
>> + =A0 =A0 BUG_ON(type !=3D RETURN_FILE);
>> +
>> =A0 =A0 =A0 lrp =3D kzalloc(sizeof(*lrp), GFP_KERNEL);
>> =A0 =A0 =A0 if (lrp =3D=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lo && (type =3D=3D RETURN_FILE))
>> @@ -745,13 +747,11 @@ _pnfs_return_layout(struct inode *ino, struct =
nfs4_pnfs_layout_segment *range,
>>
>> =A0 =A0 =A0 dprintk("--> %s type %d\n", __func__, type);
>>
>> - =A0 =A0 if (range)
>> - =A0 =A0 =A0 =A0 =A0 =A0 arg =3D *range;
>> - =A0 =A0 else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 arg.iomode =3D IOMODE_ANY;
>> - =A0 =A0 =A0 =A0 =A0 =A0 arg.offset =3D 0;
>> - =A0 =A0 =A0 =A0 =A0 =A0 arg.length =3D NFS4_MAX_UINT64;
>> - =A0 =A0 }
>> +
>> + =A0 =A0 arg.iomode =3D range ? range->iomode : IOMODE_ANY;
>> + =A0 =A0 arg.offset =3D 0;
>> + =A0 =A0 arg.length =3D NFS4_MAX_UINT64;
>> +
>> =A0 =A0 =A0 if (type =3D=3D RETURN_FILE) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo =3D get_lock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (lo && !has_layout_to_return(lo, &arg=
)) {
>> @@ -760,11 +760,7 @@ _pnfs_return_layout(struct inode *ino, struct n=
fs4_pnfs_layout_segment *range,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lo) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: no layout s=
egments to return\n", __func__);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* must send the LAYOUTRET=
URN in response to recall */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stateid)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto send_=
return;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* unlock w/o put rebalanced by eventual=
 call to
>> @@ -773,12 +769,23 @@ _pnfs_return_layout(struct inode *ino, struct =
nfs4_pnfs_layout_segment *range,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pnfs_return_layout_barrier(nfsi, &ar=
g)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stateid) { /* callback=
 */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 -EAGAIN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_curre=
nt_layout(nfsi);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_unlock=
_current_layout(lo);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: waiting\n",=
 __func__);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wait_event(nfsi->lo_wait=
q,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !pnfs_retu=
rn_layout_barrier(nfsi, &arg));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!pn=
fs_return_layout_barrier(nfsi, &arg));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (layoutcommit_needed(nfsi)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (stateid && !wait) { /*=
 callback */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%=
s: layoutcommit pending\n", __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 -EAGAIN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D pnfs_layoutco=
mmit_inode(ino, wait);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk(=
"%s: layoutcommit failed, status=3D%d. "
>> @@ -787,9 +794,13 @@ _pnfs_return_layout(struct inode *ino, struct n=
fs4_pnfs_layout_segment *range,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D=
 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (stateid && wait)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D return_layout(i=
no, &arg, stateid, type,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0lo, wait);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pnfs_layout_release(lo, &a=
rg);
>> =A0 =A0 =A0 }
>> -send_return:
>> - =A0 =A0 status =3D return_layout(ino, &arg, stateid, type, lo, wai=
t);
>> =A0out:
>> =A0 =A0 =A0 dprintk("<-- %s status: %d\n", __func__, status);
>> =A0 =A0 =A0 return status;
>> @@ -1044,7 +1055,7 @@ pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 struct nfs4_pnfs_layout_segment arg =3D {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .iomode =3D iomode,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 .offset =3D 0,
>> - =A0 =A0 =A0 =A0 =A0 =A0 .length =3D ~0
>> + =A0 =A0 =A0 =A0 =A0 =A0 .length =3D NFS4_MAX_UINT64,
>
> why do you have to ask for whole file layouts?
> Isn't it enough to always return the whole layout
> but potentially having more than one layout segment?
>

Supposedly version A will not support multiple segments. Is this what
you mean ? I guarantee it by setting "minlength" equal to "length" in
Layoutget. I just wanted to enforce it here too.

-alexandros

> Benny
>
>> =A0 =A0 =A0 };
>> =A0 =A0 =A0 struct nfs_inode *nfsi =3D NFS_I(ino);
>> =A0 =A0 =A0 struct pnfs_layout_type *lo;
>> @@ -1063,31 +1074,12 @@ pnfs_update_layout(struct inode *ino,
>> =A0 =A0 =A0 /* Check to see if the layout for the given range alread=
y exists */
>> =A0 =A0 =A0 lseg =3D pnfs_has_layout(lo, &arg, take_ref, !take_ref);
>> =A0 =A0 =A0 if (lseg && !lseg->valid) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (take_ref)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(lseg);
>> - =A0 =A0 =A0 =A0 =A0 =A0 for (;;) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 prepare_to_wait(&nfsi->lo_=
waitq, &__wait,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 TASK_KILLABLE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_current_layout(nfsi);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lseg =3D pnfs_has_layout(l=
o, &arg, take_ref, !take_ref);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!lseg || lseg->valid)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dprintk("%s: invalid lseg =
%p ref %d\n", __func__,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lseg, atom=
ic_read(&lseg->kref.refcount)-1);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (take_ref)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_lseg(l=
seg);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (signal_pending(current=
)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lseg =3D N=
ULL;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 result =3D=
 -ERESTARTSYS;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_current_layout(nfsi=
);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 finish_wait(&nfsi->lo_waitq, &__wait);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (result)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* someone is cleaning the layout */
>> + =A0 =A0 =A0 =A0 =A0 =A0 result =3D -EAGAIN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out_put;
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 if (lseg) {
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
