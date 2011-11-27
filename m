Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54268 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab1K0S0p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Nov 2011 13:26:45 -0500
MIME-Version: 1.0
In-Reply-To: <CAAfyv35RfdnrjdDF7RhnV-CyTX53f0qm7xOaRQeJLEB==sP+ZQ@mail.gmail.com>
References: <CAAfyv36nxYq1EA2pcHi5WR1BdWYHp2sQTY1mMA4Q3JjcOG5RDw@mail.gmail.com>
	<4ECCAF76.3090502@linux.vnet.ibm.com>
	<20111123124656.35063401@corrin.poochiereds.net>
	<CAAfyv35RfdnrjdDF7RhnV-CyTX53f0qm7xOaRQeJLEB==sP+ZQ@mail.gmail.com>
Date: Sun, 27 Nov 2011 19:26:43 +0100
Message-ID: <CAAfyv35bZdQ1524TPu6DdK9HcL-ymVOU1fs==Wj-D15i=Ebwvg@mail.gmail.com>
Subject: Re: Freezing of tasks failed after 20.01 seconds in kernel 3.2.0-rc2
From: Belisko Marek <marek.belisko@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        LKML <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        linux-nfs@vger.kernel.org,
        Linux PM mailing list <linux-pm@vger.kernel.org>, john@calva.com,
        Tejun Heo <tj@kernel.org>, trond.myklebust@netapp.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 27, 2011 at 8:55 AM, Belisko Marek <marek.belisko@gmail.com> wrote:
> On Wed, Nov 23, 2011 at 6:46 PM, Jeff Layton <jlayton@redhat.com> wrote:
>> On Wed, 23 Nov 2011 14:01:50 +0530
>> "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> wrote:
>>
>>> On 11/23/2011 02:50 AM, Belisko Marek wrote:
>>> > Using 3.2.0-rc2 on my laptop once I've seen following trace when suspend:
>>> >
>>> > [15215.853880] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
>>> > [15221.646580] psmouse serio2: bad data from KBC - timeout
>>> > [15221.857213] psmouse serio2: bad data from KBC - timeout
>>> > [15226.960037] wlan0: no IPv6 routers present
>>> > [15278.513091] wlan0: deauthenticating from 00:1e:58:14:6c:44 by local
>>> > choice (reason=3)
>>> > [15278.537857] cfg80211: All devices are disconnected, going to
>>> > restore regulatory settings
>>> > [15278.537865] cfg80211: Restoring regulatory settings
>>> > [15278.537872] cfg80211: Calling CRDA to update world regulatory domain
>>> > [15278.546284] cfg80211: Ignoring regulatory request Set by core since
>>> > the driver uses its own custom regulatory domain
>>> > [15278.546290] cfg80211: World regulatory domain updated:
>>> > [15278.546294] cfg80211:     (start_freq - end_freq @ bandwidth),
>>> > (max_antenna_gain, max_eirp)
>>> > [15278.546300] cfg80211:     (2402000 KHz - 2472000 KHz @ 40000 KHz),
>>> > (300 mBi, 2000 mBm)
>>> > [15278.546305] cfg80211:     (2457000 KHz - 2482000 KHz @ 20000 KHz),
>>> > (300 mBi, 2000 mBm)
>>> > [15278.546310] cfg80211:     (2474000 KHz - 2494000 KHz @ 20000 KHz),
>>> > (300 mBi, 2000 mBm)
>>> > [15278.546315] cfg80211:     (5170000 KHz - 5250000 KHz @ 40000 KHz),
>>> > (300 mBi, 2000 mBm)
>>> > [15278.546321] cfg80211:     (5735000 KHz - 5835000 KHz @ 40000 KHz),
>>> > (300 mBi, 2000 mBm)
>>> > [15280.417945] init: anacron main process (10148) killed by TERM signal
>>> > [15281.558943] PM: Syncing filesystems ... done.
>>> > [15281.970184] PM: Preparing system for mem sleep
>>> > [15282.284192] Freezing user space processes ...
>>> > [15302.300305] Freezing of tasks failed after 20.01 seconds (1 tasks
>>> > refusing to freeze, wq_busy=0):
>>> > [15302.300485] mount.nfs       D f1bb7a1c     0  9987   9985 0x00800004
>>> > [15302.300494]  f1bb7a74 00000082 c1539243 f1bb7a1c f9220b89 f1bb79f8
>>> > c1026778 c1878340
>>> > [15302.300507]  f046cc20 c1878340 c1878340 1e6f8d83 00000de6 c1878340
>>> > f4a07340 f046cc20
>>> > [15302.300518]  f1a658d0 f3898000 f1bb7a48 c1055e95 00000000 f3898000
>>> > 0039d700 00000286
>>> > [15302.300530] Call Trace:
>>> > [15302.300542]  [<c1539243>] ? _raw_read_unlock_bh+0x13/0x20
>>> > [15302.300566]  [<f9220b89>] ? xs_tcp_state_change+0x49/0x280 [sunrpc]
>>> > [15302.300574]  [<c1026778>] ? default_spin_lock_flags+0x8/0x10
>>> > [15302.300582]  [<c1055e95>] ? mod_timer+0x135/0x260
>>> > [15302.300601]  [<f9223003>] ? __rpc_sleep_on_priority+0x173/0x240 [sunrpc]
>>> > [15302.300607]  [<c1026778>] ? default_spin_lock_flags+0x8/0x10
>>> > [15302.300613]  [<c153901f>] ? _raw_spin_lock_irqsave+0x2f/0x50
>>> > [15302.300619]  [<c1537475>] schedule+0x35/0x50
>>> > [15302.300637]  [<f922265e>] rpc_wait_bit_killable+0x1e/0x40 [sunrpc]
>>> > [15302.300643]  [<c1537b1d>] __wait_on_bit+0x4d/0x70
>>> > [15302.300661]  [<f9222640>] ? rpc_queue_empty+0x40/0x40 [sunrpc]
>>> > [15302.300679]  [<f9222640>] ? rpc_queue_empty+0x40/0x40 [sunrpc]
>>> > [15302.300685]  [<c1537beb>] out_of_line_wait_on_bit+0xab/0xc0
>>> > [15302.300692]  [<c1065b50>] ? autoremove_wake_function+0x50/0x50
>>> > [15302.300710]  [<f9222d27>] __rpc_execute+0x167/0x270 [sunrpc]
>>> > [15302.300716]  [<c1065aee>] ? wake_up_bit+0x5e/0x70
>>> > [15302.300734]  [<f9222e68>] rpc_execute+0x38/0x40 [sunrpc]
>>> > [15302.300749]  [<f921bd49>] rpc_run_task+0x59/0x70 [sunrpc]
>>> > [15302.300765]  [<f921be5e>] rpc_call_sync+0x3e/0x60 [sunrpc]
>>> > [15302.300782]  [<f921bec8>] rpc_ping+0x48/0x60 [sunrpc]
>>> > [15302.300799]  [<f921c6b7>] rpc_create+0x397/0x4d0 [sunrpc]
>>> > [15302.300807]  [<c102c73d>] ? kmap_atomic_prot+0xdd/0x100
>>> > [15302.300815]  [<c12b0500>] ? __nla_reserve+0x40/0x50
>>> > [15302.300831]  [<f9397a8b>] nfs_create_rpc_client+0xab/0xe0 [nfs]
>>> > [15302.300841]  [<f88f0ce9>] ? __fscache_acquire_cookie+0x59/0x270 [fscache]
>>> > [15302.300858]  [<f9397b92>] nfs4_init_client+0x62/0x170 [nfs]
>>> > [15302.300873]  [<f9398c83>] nfs_get_client+0x353/0x4e0 [nfs]
>>> > [15302.300880]  [<c1537e69>] ? mutex_lock+0x19/0x40
>>> > [15302.300886]  [<c12afef2>] ? __percpu_counter_init+0x62/0x70
>>> > [15302.300901]  [<f9398e6a>] nfs4_set_client+0x5a/0xc0 [nfs]
>>> > [15302.300917]  [<f9398f96>] nfs4_create_server+0xc6/0x310 [nfs]
>>> > [15302.300936]  [<f93a400e>] nfs4_remote_mount+0x5e/0x2f0 [nfs]
>>> > [15302.300943]  [<c1298aa1>] ? ida_get_new_above+0x101/0x1b0
>>> > [15302.300951]  [<c112fde6>] mount_fs+0x36/0x170
>>> > [15302.300960]  [<c10fcf9f>] ? __alloc_percpu+0xf/0x20
>>> > [15302.300967]  [<c1146dae>] ? alloc_vfsmnt+0xae/0x130
>>> > [15302.300974]  [<c1147b0b>] vfs_kern_mount+0x4b/0xa0
>>> > [15302.300991]  [<f93a35f9>] nfs_do_root_mount+0x69/0x90 [nfs]
>>> > [15302.301008]  [<f93a209c>] ? nfs_parse_devname+0x8c/0x1a0 [nfs]
>>> > [15302.301026]  [<f93a390f>] nfs4_try_mount+0x3f/0xb0 [nfs]
>>> > [15302.301043]  [<f93a2235>] ? nfs4_validate_text_mount_data+0x85/0x100 [nfs]
>>> > [15302.301060]  [<f93a47a5>] nfs_fs_mount+0x465/0xb20 [nfs]
>>> > [15302.301066]  [<c10fc210>] ? pcpu_alloc_area+0x210/0x320
>>> > [15302.301073]  [<c10fbbf8>] ? pcpu_next_pop+0x38/0x50
>>> > [15302.301078]  [<c10fca94>] ? pcpu_alloc+0x354/0x830
>>> > [15302.301085]  [<c1298aa1>] ? ida_get_new_above+0x101/0x1b0
>>> > [15302.301092]  [<c111e375>] ? __kmalloc_track_caller+0xf5/0x1a0
>>> > [15302.301097]  [<c1298aa1>] ? ida_get_new_above+0x101/0x1b0
>>> > [15302.301104]  [<c112fde6>] mount_fs+0x36/0x170
>>> > [15302.301110]  [<c10fcf9f>] ? __alloc_percpu+0xf/0x20
>>> > [15302.301116]  [<c1146dae>] ? alloc_vfsmnt+0xae/0x130
>>> > [15302.301123]  [<c1147b0b>] vfs_kern_mount+0x4b/0xa0
>>> > [15302.301129]  [<c1147bce>] do_kern_mount+0x3e/0xd0
>>> > [15302.301135]  [<c1148ec8>] do_mount+0x308/0x6d0
>>> > [15302.301142]  [<c11470b8>] ? copy_mount_options+0xa8/0x120
>>> > [15302.301148]  [<c11492fb>] sys_mount+0x6b/0xa0
>>> > [15302.301154]  [<c15393d4>] syscall_call+0x7/0xb
>>> > [15302.301162]
>>> > [15302.301165] Restarting tasks ... done.
>>> > [15302.359593] video LNXVIDEO:00: Restoring backlight state
>>> > [15303.897565] init: anacron main process (10434) killed by TERM signal
>>> > [15304.088853] iwlwifi 0000:07:00.0: L1 Disabled; Enabling L0S
>>> > [15304.091810] iwlwifi 0000:07:00.0: Radio type=0x1-0x2-0x0
>>> > [15304.139846] ADDRCONF(NETDEV_UP): wlan0: link is not ready
>>> > [15304.153864] atl1c 0000:09:00.0: irq 46 for MSI/MSI-X
>>> > [15304.212718] ADDRCONF(NETDEV_UP): eth0: link is not ready
>>> >
>>> >
>>> > Marek
>>> >
>>>
>>> Hi Marek,
>>>
>>> Thanks for the bug report. But this is a known issue and Jeff Layton
>>> is working on a patchset that aims to fix it.
>>>
>>> http://www.spinics.net/lists/linux-nfs/msg25585.html
>>>
>>> Can you please try it out and see if it fixes the issue for you?
> Hi I've applied both patches on top v3.2-rc3 and problem is gone. I
> make several suspend/resume
> and never seen reported behaviour.
> You can add my: Tested-by: Marek Belisko <marek.belisko@open-nandra.com>
Not sure if it's just coincidence or whatever but today I got
it again :( on tom of 3.2-rc3 (both patches applied):

[ 9110.307971] PM: Syncing filesystems ... done.
[ 9110.608064] PM: Preparing system for mem sleep
[ 9110.740487] Freezing user space processes ...
[ 9130.756335] Freezing of tasks failed after 20.01 seconds (1 tasks
refusing to freeze, wq_busy=0):
[ 9130.756533] mount.nfs       D 00000000     0  6071   6070 0x00800004
[ 9130.756542]  f0a9fa74 00000082 c1033ff5 00000000 00000000 f0a9f9f8
c10267e8 c1876340
[ 9130.756554]  f309f1a0 c1876340 c1876340 f0a9fa38 f0a9fa24 c1876340
f4a07340 f309f1a0
[ 9130.756565]  f38c0000 f3898000 f0a9fa48 c1055ee5 00000000 f3898000
00225600 00000286
[ 9130.756577] Call Trace:
[ 9130.756589]  [<c1033ff5>] ? __wake_up+0x45/0x60
[ 9130.756596]  [<c10267e8>] ? default_spin_lock_flags+0x8/0x10
[ 9130.756604]  [<c1055ee5>] ? mod_timer+0x135/0x260
[ 9130.756631]  [<f9265013>] ? __rpc_sleep_on_priority+0x173/0x240 [sunrpc]
[ 9130.756637]  [<c10267e8>] ? default_spin_lock_flags+0x8/0x10
[ 9130.756645]  [<c1538c4f>] ? _raw_spin_lock_irqsave+0x2f/0x50
[ 9130.756652]  [<c15370a5>] schedule+0x35/0x50
[ 9130.756671]  [<f926466e>] rpc_wait_bit_killable+0x1e/0x40 [sunrpc]
[ 9130.756677]  [<c153774d>] __wait_on_bit+0x4d/0x70
[ 9130.756695]  [<f9264650>] ? rpc_queue_empty+0x40/0x40 [sunrpc]
[ 9130.756713]  [<f9264650>] ? rpc_queue_empty+0x40/0x40 [sunrpc]
[ 9130.756719]  [<c153781b>] out_of_line_wait_on_bit+0xab/0xc0
[ 9130.756725]  [<c1065ba0>] ? autoremove_wake_function+0x50/0x50
[ 9130.756744]  [<f9264d37>] __rpc_execute+0x167/0x270 [sunrpc]
[ 9130.756750]  [<c1065b3e>] ? wake_up_bit+0x5e/0x70
[ 9130.756768]  [<f9264e78>] rpc_execute+0x38/0x40 [sunrpc]
[ 9130.756784]  [<f925dd49>] rpc_run_task+0x59/0x70 [sunrpc]
[ 9130.756800]  [<f925de5e>] rpc_call_sync+0x3e/0x60 [sunrpc]
[ 9130.756816]  [<f925dec8>] rpc_ping+0x48/0x60 [sunrpc]
[ 9130.756834]  [<f925e6b7>] rpc_create+0x397/0x4d0 [sunrpc]
[ 9130.756853]  [<f93a8a8b>] nfs_create_rpc_client+0xab/0xe0 [nfs]
[ 9130.756862]  [<f9240ce9>] ? __fscache_acquire_cookie+0x59/0x270 [fscache]
[ 9130.756883]  [<f93a8b92>] nfs4_init_client+0x62/0x170 [nfs]
[ 9130.756899]  [<f93a9c83>] nfs_get_client+0x353/0x4e0 [nfs]
[ 9130.756905]  [<c1537a99>] ? mutex_lock+0x19/0x40
[ 9130.756912]  [<c12aff92>] ? __percpu_counter_init+0x62/0x70
[ 9130.756928]  [<f93a9e6a>] nfs4_set_client+0x5a/0xc0 [nfs]
[ 9130.756944]  [<f93a9f96>] nfs4_create_server+0xc6/0x310 [nfs]
[ 9130.756963]  [<f93b4fee>] nfs4_remote_mount+0x5e/0x2f0 [nfs]
[ 9130.756970]  [<c1298b41>] ? ida_get_new_above+0x101/0x1b0
[ 9130.756978]  [<c112fea6>] mount_fs+0x36/0x170
[ 9130.756985]  [<c10fcfff>] ? __alloc_percpu+0xf/0x20
[ 9130.756991]  [<c1146e7e>] ? alloc_vfsmnt+0xae/0x130
[ 9130.756998]  [<c1147cbb>] vfs_kern_mount+0x4b/0xa0
[ 9130.757016]  [<f93b4659>] nfs_do_root_mount+0x69/0x90 [nfs]
[ 9130.757034]  [<f93b30fc>] ? nfs_parse_devname+0x8c/0x1a0 [nfs]
[ 9130.757051]  [<f93b48ef>] nfs4_try_mount+0x3f/0xb0 [nfs]
[ 9130.757069]  [<f93b3295>] ? nfs4_validate_text_mount_data+0x85/0x100 [nfs]
[ 9130.757087]  [<f93b5785>] nfs_fs_mount+0x465/0xb20 [nfs]
[ 9130.757093]  [<c10fc270>] ? pcpu_alloc_area+0x210/0x320
[ 9130.757099]  [<c10fbc58>] ? pcpu_next_pop+0x38/0x50
[ 9130.757105]  [<c10fcaf4>] ? pcpu_alloc+0x354/0x830
[ 9130.757111]  [<c1298b41>] ? ida_get_new_above+0x101/0x1b0
[ 9130.757118]  [<c111e435>] ? __kmalloc_track_caller+0xf5/0x1a0
[ 9130.757124]  [<c1298b41>] ? ida_get_new_above+0x101/0x1b0
[ 9130.757131]  [<c112fea6>] mount_fs+0x36/0x170
[ 9130.757136]  [<c10fcfff>] ? __alloc_percpu+0xf/0x20
[ 9130.757142]  [<c1146e7e>] ? alloc_vfsmnt+0xae/0x130
[ 9130.757149]  [<c1147cbb>] vfs_kern_mount+0x4b/0xa0
[ 9130.757155]  [<c1147d7e>] do_kern_mount+0x3e/0xd0
[ 9130.757161]  [<c1149078>] do_mount+0x308/0x6d0
[ 9130.757168]  [<c1147188>] ? copy_mount_options+0xa8/0x120
[ 9130.757174]  [<c11494ab>] sys_mount+0x6b/0xa0
[ 9130.757180]  [<c1539004>] syscall_call+0x7/0xb
[ 9130.757188]
[ 9130.757191] Restarting tasks ... done.

>
>>>
>>> [I am wondering why Jeff did not CC LKML while sending the patchset!]
>>>
>>> Adding relevant people and linux-pm mailing list to CC.
>>>
>>> Thanks,
>>> Srivatsa S. Bhat
>>>
>>
>> Sorry, it was an oversight -- I should have cc'ed LKML. At this point,
>> the patchset seems to work as expected, but I need to respin it to
>> flesh out the comments. Testing it would be helpful.
>>
>> I'll be sure to cc LKML when I send the respun set...
>>
>> Thanks,
>> --
>> Jeff Layton <jlayton@redhat.com>
>>
>
> regards,
>
> marek
>
> --
> as simple and primitive as possible
> -------------------------------------------------
> Marek Belisko - OPEN-NANDRA
> Freelance Developer
>
> Ruska Nova Ves 219 | Presov, 08005 Slovak Republic
> Tel: +421 915 052 184
> skype: marekwhite
> twitter: #opennandra
> web: http://open-nandra.com
>

regards,

marek

-- 
as simple and primitive as possible
-------------------------------------------------
Marek Belisko - OPEN-NANDRA
Freelance Developer

Ruska Nova Ves 219 | Presov, 08005 Slovak Republic
Tel: +421 915 052 184
skype: marekwhite
twitter: #opennandra
web: http://open-nandra.com
