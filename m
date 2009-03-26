From: Ondrej Valousek <webserv-K2D8ygZuxnnrBKCeMvbIDA@public.gmane.org>
Subject: Re: Kernel panic by nfs-client and selinux
Date: Thu, 26 Mar 2009 08:36:25 +0100
Message-ID: <49CB3079.9080509@s3group.cz>
References: <49C9F7A5.6060106@s3group.cz>	<1238010001.26487.15.camel@heimdal.trondhjem.org> <20090325164601.7b25f625@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lynx.s3group.cz ([193.85.188.86]:39463 "EHLO lynx.s3group.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbZCZHhF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2009 03:37:05 -0400
In-Reply-To: <20090325164601.7b25f625-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

I have already opened a RedHat support request regarding this. They did 
not come back to me yet.
Mean time I have disabled the SELinux completely (was permissive at the 
time of  the crash) and rebooted back into 2.6.18-53 which seemed to be 
fine.
I would like to run at least 2.6.18-92 as it behaves better in my 
environment, but I can not risk any more crashes.
Shall I file a bug in RedHat Bugzilla, too (and what to do with the core 
dumps, they are fairly big) ?

Many thanks for all responses.

Ondrej

Jeff Layton wrote:
> On Wed, 25 Mar 2009 15:40:01 -0400
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
>
>   
>> On Wed, 2009-03-25 at 10:21 +0100, Ondrej Valousek wrote:
>>     
>>> Hi list,
>>> Just wondering if this rings any bell? Backtrace:
>>>
>>> SELinux: initialized (dev 0:1d, type nfs4), uses genfs_contexts
>>> Unable to handle kernel paging request at ffff8801e09b6000 RIP:
>>>  [<ffffffff80261b9e>] copy_page+0x32/0xe4
>>> PGD 1f4a067 PUD 2d52067 PMD 2e57067 PTE 0
>>> Oops: 0000 [1] SMP
>>> last sysfs file: 
>>> /devices/pci0000:00/0000:00:1c.0/0000:04:00.0/0000:05:00.0/irq
>>> CPU 0
>>> Modules linked in: hfsplus loop tun xt_physdev netloop netbk blktap 
>>> blkbk ipt_MASQUERADE iptable_nat ip_nat xt_state ip_conntrack nfnetlink 
>>> ipt_REJECT xt_tcpudp iptable_filter i
>>> p_tables x_tables bridge ipmi_devintf ipmi_si ipmi_msghandler dell_rbu 
>>> nfsd exportfs autofs4 hidp nfs lockd fscache nfs_acl rfcomm l2cap 
>>> bluetooth rpcsec_gss_krb5 auth_rpcgss de
>>> s sunrpc ipv6 xfrm_nalgo crypto_api mptctl dm_multipath video sbs 
>>> backlight i2c_ec i2c_core button battery asus_acpi ac parport_pc lp 
>>> parport st joydev sr_mod ide_cd i5000_edac
>>> edac_mc pcspkr aic7xxx cdrom bnx2 serial_core serio_raw shpchp 
>>> dm_snapshot dm_zero dm_mirror dm_mod mppVhba(U) usb_storage ata_piix 
>>> libata mptsas mptscsih scsi_transport_sas mpt
>>> base aic79xx scsi_transport_spi megaraid_sas mppUpper(U) sg sd_mod 
>>> scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd
>>> Pid: 6640, comm: smbd Tainted: G      2.6.18-92.1.17.el5xen #1
>>> RIP: e030:[<ffffffff80261b9e>]  [<ffffffff80261b9e>] copy_page+0x32/0xe4
>>> RSP: e02b:ffff8801e09b59f8  EFLAGS: 00010202
>>> RAX: 0000000000000246 RBX: 00007fffdaa61c38 RCX: 0000000000000025
>>> RDX: 000000000000e02b RSI: ffff8801e09b5fe8 RDI: ffff880193182540
>>> RBP: ffffffff885ba9a0 R08: 00007fffdaa63530 R09: 00007fffdaa62d30
>>> R10: 0000000000000004 R11: 00002b0bd27f2135 R12: 0000000000000033
>>> R13: ffff880193182000 R14: ffff880193182000 R15: ffff880156642fd5
>>> FS:  00002b0bd3a1fb70(0000) GS:ffffffff805af000(0000) knlGS:0000000000000000
>>> CS:  e033 DS: 0000 ES: 0000
>>> Process smbd (pid: 6640, threadinfo ffff8801e09b4000, task ffff880161dc2860)
>>> Stack:  ffff88014f08bec0  ffff8801e09b5aa8  ffff880193182000  
>>> ffffffff80315001
>>>  ffff8801e09b5aa8  ffff88014f08bec0  ffffffff885ba9a0  ffff88014f08bec0
>>>  ffffffff885ba9a0  ffff8801e09b5aa8
>>> Call Trace:
>>>  [<ffffffff80315001>] selinux_sb_copy_data+0x23/0x1c5
>>>  [<ffffffff802d0101>] vfs_kern_mount+0x79/0x11a
>>>  [<ffffffff8858dc70>] :nfs:nfs_do_submount+0xc0/0xdb
>>>  [<ffffffff8858dd92>] :nfs:nfs_follow_mountpoint+0xe3/0x1d9
>>>  [<ffffffff8031295e>] avc_has_perm+0x43/0x55
>>>  [<ffffffff8858108e>] :nfs:nfs_access_get_cached+0xab/0xfa
>>>  [<ffffffff80317c28>] selinux_inode_follow_link+0x5f/0x6a
>>>  [<ffffffff8020a79a>] __link_path_walk+0xb71/0xf42
>>>  [<ffffffff8020eb09>] link_path_walk+0x5c/0xe5
>>>  [<ffffffff8858c99a>] :nfs:nfs_sync_inode_wait+0x83/0x1db
>>>  [<ffffffff8020cf46>] do_path_lookup+0x270/0x2e8
>>>  [<ffffffff80212bcc>] getname+0x15b/0x1c1
>>>  [<ffffffff8022415b>] __user_walk_fd+0x37/0x4c
>>>  [<ffffffff8022905f>] vfs_stat_fd+0x1b/0x4a
>>>  [<ffffffff80223f01>] sys_newstat+0x19/0x31
>>>  [<ffffffff80260295>] tracesys+0x47/0xb2
>>>  [<ffffffff802602f5>] tracesys+0xa7/0xb2
>>>
>>> Happens on RHEL-5 with both 2.6.18-92.1.17.el5xen and 2.6.18-128.el5xen 
>>> kernels. Happens occasionally with the first one and frequently with the 
>>> latter one (shipped with RHEL 5.3).
>>> Just wondering if it is more likely some issue with NFS or SELinux....
>>> Many thanks
>>> Ondrej
>>>       
>> It looks like an issue with the copying of the selinux context string
>> from the binary NFS mount data. It shouldn't be an issue with recent
>> kernels, since they don't appear to have the 'Binary mount data: just
>> copy' case in selinux_sb_copy_data().
>>
>> Have you filed a bugzilla entry for it with Red Hat?
>>
>>     
>
> I think there was a similar known problem of this nature and there is a
> check that should prevent this, but obviously it didn't work. Here was
> the BZ for the original problem:
>
> https://bugzilla.redhat.com/show_bug.cgi?id=219837
>
> Please do file a bug in RH bugzilla so we can track down the cause and
> try to fix it...
>
> Thanks,
>   

