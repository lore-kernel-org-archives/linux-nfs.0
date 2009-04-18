From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: [PATCH 0/3] NFS regression in 2.6.26?, "task blocked for more
	than 120 seconds"
Date: Sat, 18 Apr 2009 07:17:39 +0200
Message-ID: <20090418051739.GL64731@fit.vutbr.cz>
References: <20090112090404.GL47559@fit.vutbr.cz> <1231782009.7322.12.camel@heimdal.trondhjem.org> <1231809446.7322.17.camel@heimdal.trondhjem.org> <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org> <20090303120848.GV89843@fit.vutbr.cz> <1236089767.9631.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:58135 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbZDRFRq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Apr 2009 01:17:46 -0400
In-Reply-To: <1236089767.9631.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 03, 2009 at 09:16:07AM -0500, Trond Myklebust wrote:
> On Tue, 2009-03-03 at 13:08 +0100, Kasparek Tomas wrote:
> > On Tue, Jan 20, 2009 at 10:32:27AM -0500, Trond Myklebust wrote:
> > > A binary wireshark dump of the traffic between one such client and the
> > > server would help.
> > 
> > I was able to finally got the tcpdump. I got it from 2.6.27.19 client but
> > after several weeks without problems. I include the file and place it on
> > http://merlin.fit.vutbr.cz/tmp/nfs/dump_kas2_mat.dump_small (have over 1GB
> > of dump, but it's all the time the same SYN+RST packets). The packet rate
> > maxed at 260000pps from two clients.
> > 
> > This dump is taken from server after reset (the server does not respond
> > even to keybord) before clients are disconnected/rebooted. To remind it - all
> > clients seems to work well with reversed
> > e06799f958bf7f9f8fae15f0c6f519953fb0257c
> 
> Yes. I saw that behaviour when testing at Connectathon last week. When
> one of the servers I was testing against crashed and later came up
> again, the patched client went into that same SYN+RST frenzy. I'm
> planning to look at this now that I'm back at home.

Hi, got a bit more data today as I get to the client early before it become
unresponsible. 

: BUG: soft lockup - CPU#5 stuck for 61s!  [rpciod/5:2730]
: Modules linked in: nfsd auth_rpcgss
exportfs i2c_dev i2c_core nfs lockd nfs_acl sunrpc ipv6 xfs dm_mirror 
dm_log dm_mod pci_slot fa n snd_hda_intel snd_seq_dummy thermal snd_seq_oss
snd_seq_midi_event snd_seq processor igb 8250_pnp sg firewire_ohci 
firewire_core crc_itu_t thermal_sys snd_seq_dev ice snd_pcm_oss snd_mixer_oss
evdev snd_pcm hwmon 3w_9xxx inet_lro button snd_timer sr_mod cdrom 8250
serial_core rtc_cmos rtc_core rtc_lib ehci_hcd uhci_hcd snd soundcore snd_page_alloc usbcore
: 
: Pid: 2730, comm: rpciod/5 Not tainted (2.6.27.21 #1)
: EIP: 0060:[<c02972c8>] EFLAGS: 00000202 CPU: 5
: EIP is at tcp_connect+0x213/0x2e6
: EAX: c55cf700 EBX: f67b7b40 ECX: 00000002 EDX: ed451d8c
: ESI: c5409380 EDI: 00000000 EBP: 00000001 ESP: f67cfe78
:  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
: CR0: 8005003b CR2: b7f7b9c8 CR3: 003b5000 CR4: 000006d0
: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
: DR6: ffff0ff0 DR7: 00000400 
:  [<c0299c5d>] ? tcp_v4_connect+0x3b2/0x40a
:  [<c02a312e>] ?  inet_stream_connect+0x87/0x20b
:  [<f8b41a88>] ?  rpc_wake_up_status+0x33/0x57 [sunrpc]
:  [<c026417a>] ? kernel_connect+0xb/0xe
:  [<f8b401b3>] ?  xs_tcp_finish_connecting+0xe4/0xea [sunrpc]
:  [<f8b41145>] ?  xs_tcp_connect_worker4+0x0/0x15a [sunrpc]
:  [<f8b41221>] ?  xs_tcp_connect_worker4+0xdc/0x15a [sunrpc]
:  [<c012854e>] ? run_workqueue+0x6a/0xe1
:  [<c0128c77>] ? worker_thread+0x0/0x8a
:  [<c0128cf6>] ? worker_thread+0x7f/0x8a
:  [<c012aeac>] ?  autoremove_wake_function+0x0/0x2b
:  [<c0128c77>] ? worker_thread+0x0/0x8a
:  [<c012ade8>] ? kthread+0x38/0x60
:  [<c012adb0>] ? kthread+0x0/0x60
:  [<c010371b>] ?  kernel_thread_helper+0x7/0x10
:  =======================

The lockup may be becouse I disconnected the cable from that client to stop
the packet storm, but still the backtrace may be usefull.

Is there anything else I can do, that will help with this problem?

Thanks in advance

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

