Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mercury.cora.nwra.com ([4.28.99.165]:47601 "EHLO
	mail.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756657Ab3BMTCi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2013 14:02:38 -0500
Message-ID: <511BD448.5050901@cora.nwra.com>
Date: Wed, 13 Feb 2013 10:58:32 -0700
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: umount(,MNT_DETACH) for nfsv4 hangs when using sec=krb5 and network
 is down
References: <loom.20121219T214634-616@post.gmane.org>    <4FA345DA4F4AE44899BD2B03EEEC2FA91196AE42@SACEXCMBX04-PRD.hq.netapp.com>    <50D236A4.6060906@cora.nwra.com>   <4FA345DA4F4AE44899BD2B03EEEC2FA91196C146@SACEXCMBX04-PRD.hq.netapp.com>   <50D3758D.9060808@cora.nwra.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA91196FF19@SACEXCMBX04-PRD.hq.netapp.com>  <50D388A9.9060300@cora.nwra.com> <4FA345DA4F4AE44899BD2B03EEEC2FA911970163@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA911970163@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/20/2012 03:01 PM, Myklebust, Trond wrote:
> On Thu, 2012-12-20 at 14:52 -0700, Orion Poplawski wrote:
>> On 12/20/2012 01:47 PM, Myklebust, Trond wrote:
>>> On Thu, 2012-12-20 at 13:31 -0700, Orion Poplawski wrote:
>>>> On 12/19/2012 03:19 PM, Myklebust, Trond wrote:
>>>>>
>>>>> Commit eb96d5c97b0825d542e9c4ba5e0a22b519355166 (SUNRPC handle
>>>>> EKEYEXPIRED in call_refreshresult), which will be in 3.8-rc1 when Linus
>>>>> releases it, may help.
>>>>>
>>>>
>>>> FWIW - I cherry picked that into the latest Fedora rawhide kernel but no
>>>> effect.  Sounds like a nice patch though, the current hang forever behavior
>>>> doesn't seem the trigger the needed "ah, need a new ticket" response.
>>>>
>>>
>>> So does simply killing the rpc.gssd process help?
>>>
>>
>> Yes, if automount is already stopped (these are automounted directories).  If
>> automount is running, it still seems to hang.  I think I'm going to need to
>> spend some time talking to Ian.
>>
> 
> I'd suggest also taking a long hard look at rpc.gssd and making sure
> that it handles ENETUNREACH, ECONNREFUSED and friends correctly. I
> suspect right now it is just baling out of the upcall instead of
> completing it by propagating the error reply to the kernel.
> 

Actually, I take that back - I'm not sure it's directly involved and killing
rpc.gssd doesn't seem to be helping me now.  I connected to rpc.gssd with
strace, dropped the interface and tried to umount.nfs4 -l but rpc.gssd is
still in poll and doesn't do anyting.  kernel process trace shows:

[ 2788.807017] umount.nfs4     D ffff88007cc13d40     0  3001   3000 0x00000084
[ 2788.807017]  ffff8800361319a8 0000000000000082 ffff880036131fd8
0000000000013d40
[ 2788.807017]  ffff880036131fd8 0000000000013d40 ffff8800773add80
ffff8800773add80
[ 2788.807017]  ffff88007cfe2cb8 0000000000000082 ffffffffa0009cc0
ffff880036131a20
[ 2788.807017] Call Trace:
[ 2788.807017]  [<ffffffffa0009cc0>] ?
__rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
[ 2788.807017]  [<ffffffff81634b39>] schedule+0x29/0x70
[ 2788.807017]  [<ffffffffa0009cf5>] rpc_wait_bit_killable+0x35/0x90 [sunrpc]
[ 2788.807017]  [<ffffffff816335a0>] __wait_on_bit+0x60/0x90
[ 2788.807017]  [<ffffffffa0001c50>] ? call_connect+0x90/0x90 [sunrpc]
[ 2788.807017]  [<ffffffffa0009cc0>] ?
__rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
[ 2788.807017]  [<ffffffff81633707>] out_of_line_wait_on_bit+0x77/0x90
[ 2788.807017]  [<ffffffff81080560>] ? autoremove_wake_function+0x40/0x40
[ 2788.807017]  [<ffffffffa0001c50>] ? call_connect+0x90/0x90 [sunrpc]
[ 2788.807017]  [<ffffffffa0001c50>] ? call_connect+0x90/0x90 [sunrpc]
[ 2788.807017]  [<ffffffffa000ac7a>] __rpc_execute+0x13a/0x3f0 [sunrpc]
[ 2788.807017]  [<ffffffffa000bd65>] rpc_execute+0x55/0x90 [sunrpc]
[ 2788.807017]  [<ffffffffa0002e60>] rpc_run_task+0x70/0x90 [sunrpc]
[ 2788.807017]  [<ffffffffa0002ec3>] rpc_call_sync+0x43/0xa0 [sunrpc]
[ 2788.807017]  [<ffffffffa01f5653>] _nfs4_call_sync+0x13/0x20 [nfsv4]
[ 2788.807017]  [<ffffffffa01f4e50>] _nfs4_proc_getattr+0xb0/0xc0 [nfsv4]
[ 2788.807017]  [<ffffffffa01f9b9e>] nfs4_proc_getattr+0x4e/0x70 [nfsv4]
[ 2788.807017]  [<ffffffffa01b67bc>] __nfs_revalidate_inode+0x8c/0x200 [nfs]
[ 2788.807017]  [<ffffffffa01b69a3>] nfs_revalidate_inode+0x73/0xa0 [nfs]
[ 2788.807017]  [<ffffffffa01afc60>] nfs_check_verifier+0x50/0x80 [nfs]
[ 2788.807017]  [<ffffffffa01b255b>] nfs_lookup_revalidate+0x2fb/0x470 [nfs]
[ 2788.807017]  [<ffffffffa01b2705>] nfs4_lookup_revalidate+0x35/0xe0 [nfs]
[ 2788.807017]  [<ffffffff811a18fb>] complete_walk+0xbb/0x110
[ 2788.807017]  [<ffffffff811a3310>] path_lookupat+0x70/0x7f0
[ 2788.807017]  [<ffffffff811a216f>] ? getname_flags+0x4f/0x1a0
[ 2788.807017]  [<ffffffff811a3abb>] filename_lookup+0x2b/0xc0
[ 2788.807017]  [<ffffffff811a67c4>] user_path_at_empty+0x54/0x90
[ 2788.807017]  [<ffffffff8117e4e6>] ? kmem_cache_free+0x46/0x1f0
[ 2788.807017]  [<ffffffff8115d4e3>] ? remove_vma+0x63/0x70
[ 2788.807017]  [<ffffffff811a6811>] user_path_at+0x11/0x20
[ 2788.807017]  [<ffffffff811b57af>] sys_umount+0x3f/0x3a0
[ 2788.807017]  [<ffffffff81639f7e>] ? do_page_fault+0xe/0x10
[ 2788.807017]  [<ffffffff8163e419>] system_call_fastpath+0x16/0x1b

But every other process in schedule.

The mount point gets "deleted":

# grep mnt /proc/mounts
earth:/export/home/orion /mnt\040(deleted) nfs4
rw,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=krb5,clientaddr=10.10.11.101,local_lock=none,addr=10.10.10.1
0 0

but that's it.

-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA, Boulder Office                  FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                   http://www.nwra.com
