From: Jason.V.Mock@L-3Com.com
Subject: Re: Kernel Oops in NFS
Date: Thu, 18 Oct 2007 16:01:52 -0500
Message-ID: <F31FEAB987B7C2469181758C14265CFA040BBB7A@gvlexch03.is.l-3com.com>
References: <F31FEAB987B7C2469181758C14265CFA040BBB64@gvlexch03.is.l-3com.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Kile, SE Scott @ IS" <scott.kile@L-3com.com>
To: "Mock, JV Jason @ IS" <Jason.V.Mock@L-3Com.com>,
	<nfs@lists.sourceforge.net>, <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IicVE-0000Ek-8p
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 14:02:02 -0700
Received: from smtpout1.l-3com.com ([128.170.207.211])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IicVI-0001wx-7d
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 14:02:05 -0700
In-Reply-To: <F31FEAB987B7C2469181758C14265CFA040BBB64@gvlexch03.is.l-3com.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

> We've come across an Oops, in what appears to NFS.
> 
> 2.6.22.6 vanilla + realtime-lsm
> RHEL4 over PXE/NFS_ROOT
> 
> 
> Oct  9 14:26:13 WS15 gdm(pam_unix)[6038]: session opened for 
> user mockj by (uid=0) Oct  9 14:26:48 WS15 gconfd 
> (mockj-7583): starting (version 2.8.1), pid
> 7583 user 'mockj'
> Oct  9 14:26:48 WS15 kernel: BUG: unable to handle kernel 
> NULL pointer dereference at virtual address 00000004 Oct  9 
> 14:26:48 WS15 kernel:  printing eip:
> Oct  9 14:26:48 WS15 kernel: c01a9fb8
> Oct  9 14:26:48 WS15 kernel: *pde = c691d067 Oct  9 14:26:48 
> WS15 kernel: Oops: 0000 [#1] Oct  9 14:26:48 WS15 kernel: 
> PREEMPT SMP Oct  9 14:26:48 WS15 kernel: Modules linked in: 
> lm85 w83781d hwmon_vid hwmon ipv6 parport_pc lp parport 
> autofs4 tulip dm_mirror dm_mod button battery ac mct_u232 
> usbserial uhci_hcd ehci_hcd nvidia(P) e7xxx_edac edac_mc 
> rng_core i2c_i801 i2c_core aic79xx scsi_transport_spi 
> ata_piix libata scsi_mod snd_intel8x0 snd_ac97_codec ac97_bus 
> snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc 
> snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq 
> snd_timer snd_seq_device snd soundcore realtime commoncap
> Oct  9 14:26:48 WS15 kernel: CPU:    0
> Oct  9 14:26:48 WS15 kernel: EIP:    0060:[<c01a9fb8>]    Tainted: P
> VLI
> Oct  9 14:26:48 WS15 kernel: EFLAGS: 00210246   (2.6.22-6.0.WSsmp #1)
> Oct  9 14:26:48 WS15 kernel: EIP is at nfs_lookup+0x11b/0x26a
> Oct  9 14:26:48 WS15 kernel: eax: 00000000   ebx: c0367600   ecx:
> 00000000   edx: 00000000
> Oct  9 14:26:48 WS15 kernel: esi: 00000000   edi: 00000000   ebp:
> 00000000   esp: f63b5d44
> Oct  9 14:26:48 WS15 kernel: ds: 007b   es: 007b   fs: 00d8  gs: 0033
> ss: 0068
> Oct  9 14:26:48 WS15 kernel: Process gconfd-2 (pid: 7583, 
> ti=f63b4000 task=f6273070 task.ti=f63b4000) Oct  9 14:26:48 
> WS15 kernel: Stack: f63b5d60 f63b5d98 f63b5d9c 7fffffff
> f63b5ed8 f63ef118 f63f5e8c f63b0002 
> Oct  9 14:26:48 WS15 kernel:        f63db21c 00000000 
> c014843e 00000000
> 0000000e 00000001 00000001 000081c0 
> Oct  9 14:26:48 WS15 kernel:        00000002 00001459 
> 000000c9 00000271
> 00000000 00002000 00000008 00000000
> Oct  9 14:26:48 WS15 kernel: Call Trace:
> Oct  9 14:26:48 WS15 kernel:  [<c014843e>] 
> write_cache_pages+0x235/0x285 Oct  9 14:26:48 WS15 kernel:  
> [<c01b4332>] nfs_flush_one+0x0/0xe5 Oct  9 14:26:48 WS15 
> kernel:  [<c01488c5>] mapping_tagged+0x2b/0x32 Oct  9 
> 14:26:48 WS15 kernel:  [<c016e227>] d_alloc+0x15e/0x166 Oct  
> 9 14:26:48 WS15 kernel:  [<c0166663>] 
> lookup_one_len+0xc5/0xe0 Oct  9 14:26:48 WS15 kernel:  
> [<c01aabba>] nfs_sillyrename+0x12b/0x253 Oct  9 14:26:48 WS15 
> kernel:  [<c01aba09>] nfs_permission+0x0/0x147 Oct  9 
> 14:26:48 WS15 kernel:  [<c01aae6e>] nfs_unlink+0x81/0xfc Oct  
> 9 14:26:48 WS15 kernel:  [<c01667f4>] may_delete+0x55/0x10a 
> Oct  9 14:26:48 WS15 kernel:  [<c0167a82>] 
> vfs_unlink+0xa1/0xc5 Oct  9 14:26:48 WS15 kernel:  
> [<c0167b3b>] do_unlinkat+0x95/0xf5 Oct  9 14:26:48 WS15 
> kernel:  [<c0105a67>] do_syscall_trace+0x15c/0x19d Oct  9 
> 14:26:48 WS15 kernel:  [<c0103136>] syscall_call+0x7/0xb Oct  
> 9 14:26:48 WS15 kernel:  [<c0350000>] 
> cache_make_upcall+0x40/0x129 Oct  9 14:26:48 WS15 kernel:  
> ======================= Oct  9 14:26:48 WS15 kernel: Code: 24 
> 14 8b 00 83 c2 20 8b 58 38 8d 44
> 24 1c 89 04 24 8b 44 24 18 ff 53 20 83 f8 fe 0f 84 93 00 00 
> 00 85 c0 89
> c5 0f 88 3d 01 00 00 <8b> 76 04 8b 54 24 18 89 74 24 10 8b 82 
> a4 00 00 00 8b 54 24 64 Oct  9 14:26:48 WS15 kernel: EIP: 
> [<c01a9fb8>] nfs_lookup+0x11b/0x26a SS:ESP 0068:f63b5d4
> 
> We haven't seen any negative side-effects other than users 
> seeing this in Kwrited quite often.  We've yet to update to 
> 2.6.22.9, however we've examined the change logs and patches 
> associated with NFS between then and now, and don't see 
> anything appropriate for the errors we're receiving.  Let me 
> know if you need anything else for this...

I was just checking to see if there's anything that I'm missing here, in
regards to never hearing a single thing back about this.

- Jason Mock

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
