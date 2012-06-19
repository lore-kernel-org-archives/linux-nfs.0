Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:50326 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab2FSGPv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jun 2012 02:15:51 -0400
Received: by wgbdr13 with SMTP id dr13so6421773wgb.1
        for <linux-nfs@vger.kernel.org>; Mon, 18 Jun 2012 23:15:49 -0700 (PDT)
Message-ID: <4FE01912.3040208@tonian.com>
Date: Tue, 19 Jun 2012 09:15:46 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFSv4 regression, kernel BUG at fs/nfsd/nfs4state.c:1044!
References: <20120610090342.GA5076@cucamonga.audible.transient.net> <20120611161425.GF31109@pad.fieldses.org> <20120612101339.GB30293@cucamonga.audible.transient.net> <20120612111802.GI31109@pad.fieldses.org> <20120612123644.GA16430@fieldses.org>
In-Reply-To: <20120612123644.GA16430@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-06-12 15:36, J. Bruce Fields wrote:
> On Tue, Jun 12, 2012 at 07:18:03AM -0400, J. Bruce Fields wrote:
>> On Tue, Jun 12, 2012 at 10:13:39AM +0000, Jamie Heilman wrote:
>>> J. Bruce Fields wrote:
>>>> On Sun, Jun 10, 2012 at 09:03:42AM +0000, Jamie Heilman wrote:
>>>>> Upgrading my NFSv4 server from 3.3.8 to 3.4.2 I've managed to
>>>>> reproduce this reliably:
>>>>>
>>>>> ------------[ cut here ]------------
>>>>> kernel BUG at fs/nfsd/nfs4state.c:1044!
>>>>
>>>> That's 
>>>>
>>>> 	free_client(struct nfs4_client *clp)
>>>> 	{
>>>> --->        	BUG_ON(!spin_is_locked(&client_lock));
>>>>
>>>>
>>>>> invalid opcode: 0000 [#1] 
>>>>> Modules linked in: md5 cpufreq_conservative cpufreq_stats cpufreq_powersave cpufreq_ondemand autofs4 quota_v2 quota_tree nfsd nfs_acl exportfs nfs lockd fscache auth_rpcgss sunrpc xt_mark xt_dscp cls_fw sch_htb iptable_nat nf_nat ipt_REJECT xt_multiport xt_mac xt_tcpudp iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_LOG xt_limit iptable_filter ip_tables x_tables dm_crypt dm_mod snd_hda_codec_via tpm_tis tpm via_rhine snd_hda_intel snd_hda_codec tpm_bios mii via_velocity snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc evdev crc_ccitt via_agp agpgart button
>>>>>
>>>>> Pid: 1804, comm: nfsd Not tainted 3.4.2 #3 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
>>>>> EIP: 0060:[<f86ac683>] EFLAGS: 00010246 CPU: 0
>>>>> EIP is at free_client.isra.47+0x3/0x5 [nfsd]
>>>>> EAX: 00000000 EBX: e9d48800 ECX: e9d48030 EDX: f86b20f8
>>>>> ESI: e9d48810 EDI: e9cf9ec0 EBP: e9cf9eb4 ESP: e9cf9eb4
>>>>>  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
>>>>> CR0: 8005003b CR2: b760bee0 CR3: 34d04000 CR4: 000006b0
>>>>> DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
>>>>> DR6: ffff0ff0 DR7: 00000400
>>>>> Process nfsd (pid: 1804, ti=e9cf8000 task=e9cf4000 task.ti=e9cf8000)
>>>>> Stack:
>>>>>  e9cf9ed4 f86a6c00 e9d48828 e9cf9ec0 e9cf9ec0 e9d48800 e9d48000 00000000
>>>>>  e9cf9f00 f86a6d36 00000000 000555c0 f53c0001 4fd43f69 00000001 7ad0b2a0
>>>>>  f4c45000 f4c44060 00000360 e9cf9f3c f869f63c f86aff20 e9cb9000 00000000
>>>>> Call Trace:
>>>>>  [<f86a6c00>] expire_client+0xb1/0xb9 [nfsd]
>>>>
>>>> And the only free_client call there is:
>>>>
>>>> 	spin_lock(&client_lock);
>>>> 	unhash_client_locked(clp);
>>>> 	if (atomic_read(&clp->cl_refcount) == 0)
>>>> --->		free_client(clp);
>>>> 	spin_unlock(&client_lock);
>>>>
>>>> So, that's strange.
>>>
>>> OK, other observations which may or may not have any value:
>>> - I can't trigger the BUG if I build with CONFIG_SMP (which obviously
>>>   changes the RCU as well)
>>> - I can't trigger the BUG if I build with CONFIG_DEBUG_SPINLOCK
>>
>> Oh, OK, so probably spin_is_locked() just isn't reliable in the
>> !CONFIG_SMP case.  That would make sense.
>>
>> So at a minimum we should change that BUG_ON to a WARN_ON_ONCE.
> 
> Doh.  Googline around--looks like we want something like this.
> 
> I've got a couple other bugfixes to collect and then I'll try to get
> this to Linus by the end of the week.
> 
> --b.
> 
> 
> commit 4cdc12ca178dfa74a9619451be41419617424a07
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Jun 12 08:28:48 2012 -0400
> 
>     nfsd4: BUG_ON(!is_spin_locked()) no good on UP kernels
>     
>     Most frequent symptom was a BUG triggering in expire_client, with the
>     server locking up shortly thereafter.
>     
>     Introduced by 508dc6e110c6dbdc0bbe84298ccfe22de7538486 "nfsd41:
>     free_session/free_client must be called under the client_lock".
>     
>     Cc: stable@kernel.org
>     Cc: Benny Halevy <bhalevy@tonian.com>

Ack.  Thanks!

Benny

>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 8fdc9ec..94effd5 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -900,7 +900,7 @@ static void free_session(struct kref *kref)
>  	struct nfsd4_session *ses;
>  	int mem;
>  
> -	BUG_ON(!spin_is_locked(&client_lock));
> +	lockdep_assert_held(&client_lock);
>  	ses = container_of(kref, struct nfsd4_session, se_ref);
>  	nfsd4_del_conns(ses);
>  	spin_lock(&nfsd_drc_lock);
> @@ -1080,7 +1080,7 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
>  static inline void
>  free_client(struct nfs4_client *clp)
>  {
> -	BUG_ON(!spin_is_locked(&client_lock));
> +	lockdep_assert_held(&client_lock);
>  	while (!list_empty(&clp->cl_sessions)) {
>  		struct nfsd4_session *ses;
>  		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
