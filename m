From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [pnfs] nfs41: sunrpc: handle clnt==NULL in call_status
Date: Wed, 05 Nov 2008 11:59:00 -0600
Message-ID: <4911DEE4.5080208@opengridcomputing.com>
References: <273FE88A07F5D445824060902F700344029749C8@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:53245 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752460AbYKER7B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:59:01 -0500
In-Reply-To: <273FE88A07F5D445824060902F700344029749C8-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Labiaga, Ricardo wrote:
> Hi Tom,
> 
> The thinking is that NFSRDMA could initially use a TCP callback channel.
> We'll implement BIND_CONN_TO_SESSION so that the backchannel does not
> need to be tied to the forechannel connection.  This should address the
> case where you have NFSRDMA for the forechannel and TCP for the
> backchannel.  BIND_CONN_TO_SESSION is also required to reestablish
> dropped connections effectively (to avoid losing the reply cache).
> 
> We're first trying to get enough of the backchannel functionality
> implemented to make it useful.  We can then build on that.  Tom Talpey
> and I had a brief conversation about what would be needed to implement
> the backchannel over NFSRDMA some time ago.  We didn't see anything
> inherently wrong with the current approach.  Tom mentioned there needs
> to be some RDMA work during the pre-allocation.  It will also need to
> inspect the RPC direction to determine if it needs to queue the request
> on the callback service, or proceed as usual with the processing of the
> request.
> 

Thanks for the explanation.

Tom

> - ricardo
> 
>  
>> -----Original Message-----
>> From: Tom Tucker [mailto:tom@opengridcomputing.com]
>> Sent: Tuesday, November 04, 2008 4:44 PM
>> To: Labiaga, Ricardo
>> Cc: Trond Myklebust; Benny Halevy; NFS list; pNFS Mailing List
>> Subject: Re: [pnfs] nfs41: sunrpc: handle clnt==NULL in call_status
>>
>> Ricardo:
>>
>> I don't mean to throw this whole discussion down a rat-hole, but the
>> current back channel architecture isn't transport independent, so
>> NFSRDMA on NFS41 is basically broken because all the back-channel
> logic
>> is in the xprtsock.c (transport specific) file. It also assumes that
> the
>> same socket (not transport, socket) is used for both fore and back
>> channel communication.
>>
>> What are the plans long-term for making this consistent with the
>> existing architecture? Does it have to be the same socket/connection
> for
>> some reason?
>>
>> Thanks,
>> Tom
>>
>> Labiaga, Ricardo wrote:
>>>> -----Original Message-----
>>>> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
>>>> Sent: Tuesday, November 04, 2008 10:19 AM
>>>> To: Benny Halevy
>>>> Cc: pNFS Mailing List; NFS list
>>>> Subject: Re: nfs41: sunrpc: handle clnt==NULL in call_status
>>>>
>>>> On Tue, 2008-11-04 at 17:52 +0200, Benny Halevy wrote:
>>>>> On the following error path task->tk_client == NULL causing NULL
>>> deref:
>>>>> Nov  4 14:14:32 tl1 kernel: Callback slot table overflowed
>>>>> Nov  4 14:14:32 tl1 kernel: BUG: unable to handle kernel NULL
>>> pointer
>>>> dereference at 0000000000000078
>>>>> Nov  4 14:14:32 tl1 kernel: IP: [<ffffffffa02b4dd2>]
>>>> call_status+0xe1/0x145 [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: PGD 2f973067 PUD 2f974067 PMD 0
>>>>> Nov  4 14:14:32 tl1 kernel: Oops: 0000 [1] SMP
>>>>> Nov  4 14:14:32 tl1 kernel: CPU 0
>>>>> Nov  4 14:14:32 tl1 kernel: Modules linked in: panfs(P)
>>> panlayoutdriver
>>>> nfslayoutdriver nfsd auth_rpcgss exportfs nfs lockd nfs_acl fuse
>>> sunrpc
>>>> ipv6 cpufreq_ondemand powernow_k8 freq_table dm_mirror dm_log
>>> dm_multipath
>>>> dm_mod snd_hda_intel snd_seq_dummy sr_mod snd_seq_oss cdrom
>>>> snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss
>>>> snd_pcm snd_timer snd_page_alloc snd_hwdep snd pcspkr serio_raw
> k8temp
>>>> hwmon forcedeth soundcore pata_amd sg jedec_probe cfi_probe
> gen_probe
>>> mtd
>>>> i2c_nforce2 chipreg i2c_core button map_funcs sata_nv ata_generic
>>>> pata_acpi libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd
>>>> ehci_hcd [last unloaded: scsi_wait_scan]
>>>>> Nov  4 14:14:32 tl1 kernel: Pid: 3405, comm: nfsv4.1-svc Tainted:
> P
>>>> 2.6.27-pnfs #1
>>>>> Nov  4 14:14:32 tl1 kernel: RIP: 0010:[<ffffffffa02b4dd2>]
>>>> [<ffffffffa02b4dd2>] call_status+0xe1/0x145 [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: RSP: 0018:ffff88002a70bd60  EFLAGS:
>>> 00010246
>>>>> Nov  4 14:14:32 tl1 kernel: RAX: 0000000000000000 RBX:
>>> 00000000ffffff95
>>>> RCX: 0000000000000000
>>>>> Nov  4 14:14:32 tl1 kernel: RDX: ffff88002a70bd10 RSI:
>>> ffff88002fc52dc0
>>>> RDI: ffff88002fc52dc0
>>>>> Nov  4 14:14:32 tl1 kernel: RBP: ffff88002a70bd80 R08:
>>> ffff88002f9dae40
>>>> R09: ffffffff81489e60
>>>>> Nov  4 14:14:32 tl1 kernel: R10: ffff880038497800 R11:
>>> ffff88002a70bd30
>>>> R12: ffff88002fc52dc0
>>>>> Nov  4 14:14:32 tl1 kernel: R13: 0000000000000000 R14:
>>> ffff88002f57fa00
>>>> R15: ffff88002fc52e50
>>>>> Nov  4 14:14:32 tl1 kernel: FS:  00007fe78ffac6f0(0000)
>>>> GS:ffffffff8148da80(0000) knlGS:0000000000000000
>>>>> Nov  4 14:14:32 tl1 kernel: CS:  0010 DS: 0018 ES: 0018 CR0:
>>>> 000000008005003b
>>>>> Nov  4 14:14:32 tl1 kernel: CR2: 0000000000000078 CR3:
>>> 000000002f971000
>>>> CR4: 00000000000006e0
>>>>> Nov  4 14:14:32 tl1 kernel: DR0: 0000000000000000 DR1:
>>> 0000000000000000
>>>> DR2: 0000000000000000
>>>>> Nov  4 14:14:32 tl1 kernel: DR3: 0000000000000000 DR6:
>>> 00000000ffff0ff0
>>>> DR7: 0000000000000400
>>>>> Nov  4 14:14:32 tl1 kernel: Process nfsv4.1-svc (pid: 3405,
>>> threadinfo
>>>> ffff88002a70a000, task ffff88003694d900)
>>>>> Nov  4 14:14:32 tl1 kernel: Stack:  0000000000000000
>>> ffff88002f57fa00
>>>> ffff88002fc52dc0 ffff880030450ce8
>>>>> Nov  4 14:14:32 tl1 kernel: ffff88002a70bdc0 ffffffffa02bb9db
>>>> ffff88002a70bdf0 ffff88002fc52dc0
>>>>> Nov  4 14:14:32 tl1 kernel: ffff88002f57fa00 ffff88002f57fa00
>>>> ffff880030450ce8 ffff88002a734000
>>>>> Nov  4 14:14:32 tl1 kernel: Call Trace:
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffffa02bb9db>]
>>>> __rpc_execute+0x7e/0x21f [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffffa02bbba4>]
>>> rpc_execute+0x28/0x2c
>>>> [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffffa02b5596>]
>>>> rpc_run_bc_task+0x88/0xae [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffffa02c923d>] bc_send+0x35/0x5a
>>>> [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffffa02bdc92>]
>>>> bc_svc_process+0xf6/0x101 [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffff81048a6c>] ?
>>>> prepare_to_wait+0x5c/0x65
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffffa033a4c9>]
>>>> nfs41_callback_svc+0xda/0x131 [nfs]
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffff810488a0>] ?
>>>> autoremove_wake_function+0x0/0x38
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffffa033a3ef>] ?
>>>> nfs41_callback_svc+0x0/0x131 [nfs]
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffff81048561>] kthread+0x49/0x76
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffff8100cf49>]
> child_rip+0xa/0x11
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffff8102a401>] ?
>>>> pick_next_task_fair+0x93/0xa3
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffff81048518>] ?
> kthread+0x0/0x76
>>>>> Nov  4 14:14:32 tl1 kernel: [<ffffffff8100cf3f>] ?
>>> child_rip+0x0/0x11
>>>>> Nov  4 14:14:32 tl1 kernel:
>>>>> Nov  4 14:14:32 tl1 kernel:
>>>>> Nov  4 14:14:32 tl1 kernel: Code: e8 7c 70 00 00 49 8b 44 24 20 49
>>> c7 44
>>>> 24 68 dc 48 2b a0 f6 40 78 02 74 6d 41 8b b6 34 01 00 00 48 8b 78
> 30
>>> e8 b9
>>>> 2a 00 00 eb 5b <41> f6 45 78 04 74 13 49 8b 55 30 48 8d 82 80 04 00
> 00
>>> f0
>>>> 80 a2
>>>>> Nov  4 14:14:32 tl1 kernel: RIP  [<ffffffffa02b4dd2>]
>>>> call_status+0xe1/0x145 [sunrpc]
>>>>> Nov  4 14:14:32 tl1 kernel: RSP <ffff88002a70bd60>
>>>>> Nov  4 14:14:32 tl1 kernel: CR2: 0000000000000078
>>>>> Nov  4 14:14:32 tl1 kernel: ---[ end trace 1584c489f2573aaf ]---
>>>>>
>>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>>> ---
>>>>>
>>>>> Trond, I'm not sure if this can happen without nfs41.
>>>>> However, please consider this patch for upstream since
>>>>> it is safe to do in any case.
>>>>>
>>>>> Benny
>>>>>
>>>>>  net/sunrpc/clnt.c |    8 +++++---
>>>>>  1 files changed, 5 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>>> index 78fc483..b555d9f 100644
>>>>> --- a/net/sunrpc/clnt.c
>>>>> +++ b/net/sunrpc/clnt.c
>>>>> @@ -1206,7 +1206,8 @@ call_status(struct rpc_task *task)
>>>>>  		break;
>>>>>  	case -ECONNREFUSED:
>>>>>  	case -ENOTCONN:
>>>>> -		rpc_force_rebind(clnt);
>>>>> +		if (clnt)
>>>>> +			rpc_force_rebind(clnt);
>>>>>  		task->tk_action = call_bind;
>>>>>  		break;
>>>>>  	case -EAGAIN:
>>>>> @@ -1217,9 +1218,10 @@ call_status(struct rpc_task *task)
>>>>>  		rpc_exit(task, status);
>>>>>  		break;
>>>>>  	default:
>>>>> -		if (clnt->cl_chatty)
>>>>> +		if (!clnt || clnt->cl_chatty)
>>>>>  			printk("%s: RPC call returned error %d\n",
>>>>> -			       clnt->cl_protname, -status);
>>>>> +			       clnt ? clnt->cl_protname : "<unknown
>>> protocol>",
>>>>> +			       -status);
>>>>>  		rpc_exit(task, status);
>>>>>  	}
>>>>>  }
>>>> BIG NACK!
>>>>
>>>> How does even it make sense for a task to get past call_transmit
> and
>>>> call_status without having task->tk_client set? This sounds like
>>> serious
>>>> borkenness in the nfsv4.1 patches...
>>> The "Callback slot table overflowed" message means we couldn't
> obtain a
>>> pre-allocated rpc_rqst to process the callback.  When this occurs,
> the
>>> client sets the XPRT_CLOSE_WAIT bit to close the connection.  (As an
>>> aside, should we be using xprt_force_disconnect() instead?).
>>>
>>> This leads me to believe the server exceeded the number of
> outstanding
>>> requests allowed on the backchannel (slot count of one at the
> moment),
>>> the new request caused us to close the connection and pulled the rug
>>> from under the callback service.  I'll investigate further.
>>>
>>> Is this reproducible?
>>>
>>> - ricardo
>>>
>>>
>>>> Trond
>>>> ...
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe
> linux-nfs"
>>> in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> _______________________________________________
>>> pNFS mailing list
>>> pNFS@linux-nfs.org
>>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

