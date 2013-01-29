Return-Path: linux-nfs-owner@vger.kernel.org
Received: from connotech.com ([76.10.176.241]:53568 "EHLO mail.connotech.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750809Ab3A2Vit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2013 16:38:49 -0500
Message-ID: <51084167.8060802@connotech.com>
Date: Tue, 29 Jan 2013 16:38:47 -0500
From: Thierry Moreau <thierry.moreau@connotech.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Kernel message when no support for NFSv4 compiled into it
References: <510812C0.1070307@connotech.com> <20130129194729.GC4209@fieldses.org>
In-Reply-To: <20130129194729.GC4209@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Tue, Jan 29, 2013 at 01:19:44PM -0500, Thierry Moreau wrote:
>> Dear nfs developers,
>>
>> I just SOLVED my operational problem. Maybe the symptom vs solution
>> is of interest to you.
>>
>> Kernel 3.5.4, nfs-utils 1.2.7
>>
>>     ./configure --prefix=/usr \
>>                 --mandir=/usr/man \
>>                 --sysconfdir=/etc \
>>                 --with-statedir=/var/lib/nfs \
>>                 --disable-gss \
>>                 --with-tcp-wrappers \
>>                 --enable-libmount-mount
>>
>> starting script:
>>
>>         /sbin/rpcbind -h 192.168.1.17
>>         /bin/mount -t nfsd nfsd $NFSD
>>         /bin/mount -t rpc_pipefs rpc_pipefs $PIPEFS
>>         /usr/sbin/rpc.idmapd
>>         /usr/sbin/exportfs -a
>>         /usr/sbin/rpc.mountd
>>         /usr/sbin/rpc.statd --no-notify
>>         /usr/sbin/rpc.nfsd --syslog 8A <==== this is where the
>> kernel would report an error
>>         /usr/sbin/sm-notify
>>
>> kernel configuration changes
>>
>> bash-4.2# diff config_02 config_04
>> d2437c2447,2448
>> < # CONFIG_NFSD_V4 is not set
>> ---
>>> CONFIG_NFSD_V4=y
>>> # CONFIG_NFSD_FAULT_INJECTION is not set
>> 2441a2453
>>> CONFIG_SUNRPC_GSS=m
>> d2622c2639,2641
>> < # CONFIG_KEYS is not set
>> ---
>>> CONFIG_KEYS=y
>>> CONFIG_ENCRYPTED_KEYS=m
>>> CONFIG_KEYS_DEBUG_PROC_KEYS=y
>> 2625a2645
>>> # CONFIG_DEFAULT_SECURITY_SELINUX is not set
>> 2646a2667
>>> CONFIG_CRYPTO_RNG=m
>> 2700c2721
>> < # CONFIG_CRYPTO_SHA256 is not set
>> ---
>>> CONFIG_CRYPTO_SHA256=m
>> With config_02 kernel, nfsd would not work (no big deal so far). But
>> it did work fine prior to a controlled system reboot where prior
>> live system had experienced extensive playing with nfsd installation
>> (not much help for you since I can not tell what made it work).
>>
>> What may be of interest to you is that with config_02 kernel, it is
>> the *kernel* that reports an error message on the system console,
>> right upon nfsd startup. It is only by (painful) trial and error
>> that the cause for the kernel message was found. The kernel message
>> message occurred even with the --disable-nfsv4/nfsv41 configure
>> options.
>>
>> I don't have the exact kernel messages at hand (circa memory mapping
>> then circa NULL pointer dereferencing during the trial-and-error
>> chase).
>>
>> I might be able to provide additional information if you ask
>> politely. Maybe I owe it to this great free software contribution
>> anyway.
> 
> Most useful would probably be the exact kernel messages if you have a
> way to find them or regenerate them again.
> 
> --b.
> 

OK, just for you I rebooted with my config_02 kernel (no System.map, 
sorry), and I found that I could copy-paste the kernel log messages 
(below with the BUG occurring at 21:11:11 soon after boot procedure 
completion at 21:10:44).

Further below, you'll see what popped up in the tty from where the nfsd 
was started.

Hope it helps

- Thierry

Jan 29 21:10:44 host----name kernel: Adding 1542204k swap on /dev/sda5. 
  Priority:42 extents:1 across:1542204k
Jan 29 21:10:44 host----name kernel: Adding 1542204k swap on /dev/sda6. 
  Priority:52 extents:1 across:1542204k
Jan 29 21:10:44 host----name kernel: Adding 1542204k swap on /dev/sda7. 
  Priority:62 extents:1 across:1542204k
Jan 29 21:10:44 host----name kernel: NET: Registered protocol family 10
Jan 29 21:11:10 host----name kernel: RPC: Registered named UNIX socket 
transport module.
Jan 29 21:11:10 host----name kernel: RPC: Registered udp transport module.
Jan 29 21:11:10 host----name kernel: RPC: Registered tcp transport module.
Jan 29 21:11:10 host----name kernel: RPC: Registered tcp NFSv4.1 
backchannel transport module.
Jan 29 21:11:10 host----name kernel: Installing knfsd (copyright (C) 
1996 okir@monad.swb.de).
Jan 29 21:11:11 host----name kernel: BUG: unable to handle kernel NULL 
pointer dereference at   (null)
Jan 29 21:11:11 host----name kernel: IP: [<cef27068>] 
rpcauth_lookupcred+0x30/0x66 [sunrpc]
Jan 29 21:11:11 host----name kernel: *pde = 00000000
Jan 29 21:11:11 host----name kernel: Oops: 0002 [#1] SMP
Jan 29 21:11:11 host----name kernel: Modules linked in: nfsd exportfs 
auth_rpcgss lockd sunrpc crypto ipv6 dm_mod 8250_pnp snd_via82xx 
snd_mpu401_uart snd_rawmidi snd_ac97_codec ac97_bus snd_pcm 
snd_page_alloc snd_timer snd soundcore sr_mod ehci_hcd uhci_hcd usbcore 
cdrom usb_common floppy 8250 serial_core parport_pc parport via_agp 
agpgart via_rhine
Jan 29 21:11:11 host----name kernel:
Jan 29 21:11:11 host----name kernel: Pid: 226, comm: rpc.nfsd Not 
tainted 3.5.4 #3 PCCHIPS P25G/P4M800-8237
Jan 29 21:11:11 host----name kernel: EIP: 0060:[<cef27068>] EFLAGS: 
00010246 CPU: 0
Jan 29 21:11:11 host----name kernel: EIP is at 
rpcauth_lookupcred+0x30/0x66 [sunrpc]
Jan 29 21:11:11 host----name kernel: EAX: 00000000 EBX: cc27b180 ECX: 
00000000 EDX: 00000000
Jan 29 21:11:11 host----name kernel: ESI: cc27b400 EDI: cc26ddc8 EBP: 
cef35204 ESP: cc26ddb4
Jan 29 21:11:11 host----name kernel:  DS: 007b ES: 007b FS: 00d8 GS: 
0033 SS: 0068
Jan 29 21:11:11 host----name kernel: CR0: 8005003b CR2: 00000000 CR3: 
0c27c000 CR4: 00000790
Jan 29 21:11:11 host----name kernel: DR0: 00000000 DR1: 00000000 DR2: 
00000000 DR3: 00000000
Jan 29 21:11:11 host----name kernel: DR6: ffff0ff0 DR7: 00000400
Jan 29 21:11:11 host----name kernel: Process rpc.nfsd (pid: 226, 
ti=cc26c000 task=cdb94d80 task.ti=cc26c000)
Jan 29 21:11:11 host----name kernel: Stack:
Jan 29 21:11:11 host----name kernel:  00000000 00000000 00000000 
00000000 00000000 cc27b180 cc27b180 00000000
Jan 29 21:11:11 host----name kernel:  cdbd5a00 cef271a6 cef23068 
cc27b180 cef237f3 cdbfca64 00000000 cc27b1b8
Jan 29 21:11:11 host----name kernel:  cc27b180 00000000 cdbd6200 
cef265e7 cc27b1b8 c102c9af cc27b180 cc26de2c
Jan 29 21:11:12 host----name kernel: Call Trace:
Jan 29 21:11:12 host----name kernel:  [<cef271a6>] ? 
rpcauth_refreshcred+0x5a/0x95 [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cef23068>] ? 
xprt_release_xprt+0x31/0x3f [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cef237f3>] ? 
xprt_reserve+0x184/0x1ad [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cef265e7>] ? 
__rpc_execute+0x34/0x158 [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<c102c9af>] ? wake_up_bit+0xb/0x16
Jan 29 21:11:12 host----name kernel:  [<cef222f8>] ? 
rpc_run_task+0x57/0x5c [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cef223d9>] ? 
rpc_call_sync+0x39/0x54 [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cef2bb41>] ? 
rpcb_register_call+0x11/0x20 [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cef2bedd>] ? 
rpcb_v4_register+0x82/0xed [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cef28431>] ? 
svc_unregister.isra.15+0x3c/0x98 [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cefb8cfd>] ? 
write_filehandle+0x14b/0x14b [nfsd]
Jan 29 21:11:12 host----name kernel:  [<cef284bc>] ? 
svc_rpcb_setup+0x1f/0x25 [sunrpc]
Jan 29 21:11:12 host----name kernel:  [<cefb8325>] ? 
nfsd_create_serv+0xba/0x10a [nfsd]
Jan 29 21:11:12 host----name kernel:  [<c10eb6a0>] ? 
simple_strtoull+0x23/0x3f
Jan 29 21:11:12 host----name kernel:  [<cefb8ed0>] ? 
write_gracetime+0x2f/0x2f [nfsd]
Jan 29 21:11:12 host----name kernel:  [<cefb8f69>] ? 
write_ports+0x99/0x2c0 [nfsd]
Jan 29 21:11:12 host----name kernel:  [<c11499d8>] ? 
get_random_bytes+0x12/0x15
Jan 29 21:11:12 host----name kernel:  [<c11eecf3>] ? 
_raw_write_lock_bh+0x9/0x1c
Jan 29 21:11:12 host----name kernel:  [<c108d955>] ? 
simple_transaction_get+0x66/0x80
Jan 29 21:11:12 host----name kernel:  [<cefb8ed0>] ? 
write_gracetime+0x2f/0x2f [nfsd]
Jan 29 21:11:12 host----name kernel:  [<cefb8d34>] ? 
nfsctl_transaction_write+0x37/0x51 [nfsd]
Jan 29 21:11:12 host----name kernel:  [<c1076e7c>] ? vfs_write+0x7b/0xf3
Jan 29 21:11:12 host----name kernel:  [<c1077081>] ? sys_write+0x38/0x65
Jan 29 21:11:12 host----name kernel:  [<c11ef6d0>] ? 
sysenter_do_call+0x12/0x26
Jan 29 21:11:13 host----name kernel: Code: 00 57 89 c5 56 53 83 ec 14 64 
a1 b8 45 31 c1 89 e7 8b b0 c4 01 00 00 31 c0 f3 ab 8b 46 1c 89 04 24 8b 
46 20 89 44 24 04 8b 46 60 <3e> ff 00 8b 75 10 89 d1 89 e2 89 44 24 08 
89 e8 ff 56 14 8b 54
Jan 29 21:11:13 host----name kernel: EIP: [<cef27068>] 
rpcauth_lookupcred+0x30/0x66 [sunrpc] SS:ESP 0068:cc26ddb4
Jan 29 21:11:13 host----name kernel: CR2: 0000000000000000
Jan 29 21:11:13 host----name kernel: ---[ end trace 796a54e9e6460ea6 ]---

bash-4.2# /etc/rc.d/rpcbind start
bash-4.2# /etc/rc.d/nfsserver start
/etc/rc.d/nfsserver: line 9:   226 Killed 
/usr/sbin/rpc.nfsd --syslog 8
bash-4.2#
Message from syslogd@host----name at Tue Jan 29 21:11:11 2013 ...
host----name kernel: Process rpc.nfsd (pid: 226, ti=cc26c000 
task=cdb94d80 task.ti=cc26c000)

Message from syslogd@host----name at Tue Jan 29 21:11:11 2013 ...
host----name kernel: Stack:

Message from syslogd@host----name at Tue Jan 29 21:11:12 2013 ...
host----name kernel: Call Trace:

Message from syslogd@host----name at Tue Jan 29 21:11:13 2013 ...
host----name kernel: Code: 00 57 89 c5 56 53 83 ec 14 64 a1 b8 45 31 c1 
89 e7 8b b0 c4 01 00 00 31 c0 f3 ab 8b 46 1c 89 04 24 8b 46 20 89 44 24 
04 8b 46 60 <3e> ff 00 8b 75 10 89 d1 89 e2 89 44 24 08 89 e8 ff 56 14 
8b 54

Message from syslogd@host----name at Tue Jan 29 21:11:13 2013 ...
host----name kernel: EIP: [<cef27068>] rpcauth_lookupcred+0x30/0x66 
[sunrpc] SS:ESP 0068:cc26ddb4

--- end of message ---
