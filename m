From: Vince Busam <vbusam@google.com>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 28 Nov 2005 10:16:35 -0800
Message-ID: <438B4983.3030809@google.com>
References: <4382252E.4000602@google.com>	 <1132602917.8011.2.camel@lade.trondhjem.org> <43824151.5060604@google.com>	 <1132612440.8011.7.camel@lade.trondhjem.org> <4382515C.9020200@google.com> <1132614431.8011.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EgnYo-0000V6-9S
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 10:17:06 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EgnYm-0004Ji-OT
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 10:17:06 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1132614431.8011.14.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:
> 
> Could you revert that patch, and just add the one from
> 
> http://client.linux-nfs.org/Linux-2.6.x/2.6.14/linux-2.6.14-88-rpcsec_gss_fix.dif
> 

I got an Oops I haven't seen before.  (2.6.13.4 + linux-2.6.13-CITI_NFS4_ALL-1.dif + 
linux-2.6.14-88-rpcsec_gss_fix.dif + linux-2.6.15-06-rpc_pipe_fix_cleanup.dif)

Nov 26 00:05:36 dig kernel: Unable to handle kernel NULL pointer dereference at
virtual address 00000000
Nov 26 00:05:36 dig kernel: printing eip:
Nov 26 00:05:36 dig kernel: f8ad94ad
Nov 26 00:05:36 dig kernel: *pde = 00000000
Nov 26 00:05:36 dig kernel: Oops: 0002 [#1]
Nov 26 00:05:36 dig kernel: PREEMPT SMP
Nov 26 00:05:36 dig kernel: Modules linked in: des binfmt_misc cpufreq_userspace 
cpufreq_ondemand cpufreq_powersave autofs4 video button battery container ac nfs lockd 
af_packet tg3 snd_intel8x0 snd_ac97_codec ata_piix libata snd_usb_audio
snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd_usb_lib snd_rawmidi 
snd_seq_device snd_hwdep snd soundcore pwc videodev v4l2_common uhci_hcd pci_hotplug 
intel_agp floppy pcspkr rtc sd_mod tsdev usbhid usb_storage scsi_mod evdev md_mod dm_mod 
nvidia agpgart psmouse mousedev parport_pc lp parport ide_cd cdrom rpcsec_gss_krb5 
auth_rpcgss sunrpc ehci_hcd usbcore ext3 jbd mbcache ide_disk ide_generic via82cxxx trm290 
triflex slc90e66 sis5513 siimage serverworks sc1200 rz1000 piix pdc202xx_old opti621 
ns87415 hpt366 hpt34x generic cy82c693 cs5530 cs5520 cmd64x atiixp amd74xx alim15x3 
aec62xx pdc202xx_new ide_core unix thermal processor fan
Nov 26 00:05:36 dig kernel: CPU:    0
Nov 26 00:05:36 dig kernel: EIP:    0060:[<f8ad94ad>]    Tainted: P      VLI
Nov 26 00:05:36 dig kernel: EFLAGS: 00010287   (2.6.13.4-gg5vb5)
Nov 26 00:05:36 dig kernel: EIP is at rpc_pipe_read+0xad/0x130 [sunrpc]
Nov 26 00:05:36 dig kernel: eax: 00000000   ebx: f5470b08   ecx: f5e1a88c   edx: 00000000
Nov 26 00:05:36 dig kernel: esi: f5e1a700   edi: f55e3c80   ebp: 00000000   esp: f5b97f4c
Nov 26 00:05:36 dig kernel: ds: 007b   es: 007b   ss: 0068
Nov 26 00:05:36 dig kernel: Process rpc.gssd (pid: 7243, threadinfo=f5b96000 task=c22ba540)
Nov 26 00:05:36 dig kernel: Stack: e9a3f00c c0305200 e9a3f008 e9a3f008 00000004
f55e3c80 bff5dab4 00000000
Nov 26 00:05:36 dig kernel: c0165a03 f55e3c80 bff5dab4 00000004 f5b97fa4 f55e3c80 fffffff7 
00000004
Nov 26 00:05:36 dig kernel: f5b96000 c0165df1 f55e3c80 bff5dab4 00000004 f5b97fa4 00000000 
00000000
Nov 26 00:05:36 dig kernel: Call Trace:
Nov 26 00:05:36 dig kernel: [<c0165a03>] vfs_read+0xf3/0x1b0
Nov 26 00:05:36 dig kernel: [<c0165df1>] sys_read+0x51/0x80
Nov 26 00:05:36 dig kernel: [<c010316b>] sysenter_past_esp+0x54/0x75
Nov 26 00:05:36 dig kernel: Code: 24 14 8b 7c 24 18 8b 6c 24 1c 83 c4 20 c3 8b 96 84 01 00 
00 8d 86 84 01 00 00 39 c2 74 d0 89 d3 8b 52 04 8b 03 8d 8e 8c 01 00
00 <89> 02 89 50 04 8b 86 8c 01 00 00 89 58 04 89 03 89 4b 04 8b 86


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
