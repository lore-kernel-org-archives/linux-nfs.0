From: Vince Busam <vbusam@google.com>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 05 Dec 2005 13:03:42 -0800
Message-ID: <4394AB2E.1030809@google.com>
References: <4382252E.4000602@google.com>	 <1132602917.8011.2.camel@lade.trondhjem.org> <43824151.5060604@google.com>	 <1132612440.8011.7.camel@lade.trondhjem.org> <4382515C.9020200@google.com>	 <1132614431.8011.14.camel@lade.trondhjem.org> <438B4983.3030809@google.com> <1133203961.27574.66.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EjNVJ-00060U-Gc
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 13:04:09 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EjNVJ-0003bK-27
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 13:04:09 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1133203961.27574.66.camel@lade.trondhjem.org>
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
> Argh... Yep. Looks like the "fix" to ensure that we purge
> rpci->in_upcall was wrong. Does the following patch fix it?

I got another oops in __rpc_purge_upcall, which looks like this after applying the 
patches.  Looks like rcpi must have been NULL, but I'll defer to the experts here.

static void
__rpc_purge_upcall(struct inode *inode, int err)
{
         struct rpc_inode *rpci = RPC_I(inode);

         __rpc_purge_list(rpci, &rpci->pipe, err);
         rpci->pipelen = 0;
         wake_up(&rpci->waitq);
}

Dec  4 13:09:59 block kernel: RPC: AUTH_GSS upcall timed out.
Dec  4 13:09:59 block kernel: Please check user daemon is running!
Dec  4 13:10:12 block kernel: Unable to handle kernel NULL pointer dereference at virtual 
address 00000004
Dec  4 13:10:12 block kernel: printing eip:
Dec  4 13:10:12 block kernel: f8a98d55
Dec  4 13:10:12 block kernel: *pde = 00000000
Dec  4 13:10:12 block kernel: Oops: 0002 [#1]
Dec  4 13:10:12 block kernel: PREEMPT SMP
Dec  4 13:10:12 block kernel: Modules linked in: des tsdev usbhid vmnet vmmon binfmt_misc 
cpufreq_userspace cpufreq_ondemand cpufreq_powersave autofs4 video button battery 
container ac capability commoncap nfs lockd af_packet tg3 generic piix snd_intel8x0 
snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc 
uhci_hcd pci_hotplug floppy pcspkr rtc md_mod evdev dm_mod nvidia agpgart psmouse mousedev 
parport_pc lp parport ide_generic ide_disk ide_cd cdrom ide_core rpcsec_gss_krb5 
auth_rpcgss sunrpc ehci_hcd usbcore ext3 jbd mbcache ahci sd_mod ata_piix libata scsi_mod 
unix thermal processor fan
Dec  4 13:10:12 block kernel: CPU:    1
Dec  4 13:10:12 block kernel: EIP:    0060:[<f8a98d55>]    Tainted: P      VLI
Dec  4 13:10:12 block kernel: EFLAGS: 00010202   (2.6.13.4-gg5vb7)
Dec  4 13:10:12 block kernel: EIP is at __rpc_purge_upcall+0x35/0x80 [sunrpc]
Dec  4 13:10:12 block kernel: eax: 00000000   ebx: c2bcec84   ecx: d16e1688   edx: 00000000
Dec  4 13:10:12 block kernel: esi: c2bceb00   edi: f88b5ce0   ebp: ffffffe0   esp: eea1bf30
Dec  4 13:10:12 block kernel: ds: 007b   es: 007b   ss: 0068
Dec  4 13:10:12 block kernel: Process rpc.gssd (pid: 5833, threadinfo=eea1a000 task=ef353020)
Dec  4 13:10:12 block kernel: Stack: d16e1680 c2bceb00 cf453380 c2bceb00 c2bceb00 f8a990cb 
c2bceb00 ffffffe0
Dec  4 13:10:12 block kernel: 00000008 cf453380 eea94800 c01675fa c2bceb00 cf453380 
00000000 00000000
Dec  4 13:10:12 block kernel: d16a28c0 cf453380 ef02b300 00000000 cf453380 c0165906 
cf453380 ef02b300
Dec  4 13:10:12 block kernel: Call Trace:
Dec  4 13:10:12 block kernel: [<f8a990cb>] rpc_pipe_release+0xcb/0xf0 [sunrpc]
Dec  4 13:10:12 block kernel: [<c01675fa>] __fput+0x18a/0x1d0
Dec  4 13:10:12 block kernel: [<c0165906>] filp_close+0x46/0x90
Dec  4 13:10:12 block kernel: [<c01659ba>] sys_close+0x6a/0xa0
Dec  4 13:10:12 block kernel: [<c010316b>] sysenter_past_esp+0x54/0x75
Dec  4 13:10:12 block kernel: Code: 18 8b 6c 24 1c 8b 86 ac 01 00 00 8d 9e 84 01 00 00 8b 
78 0c 8b 86 84 01 00 00 39 d8 74 25 89 c1 8d b6 00 00 00 00 8b 51 04 8b 01 <89> 50 04 89 
02 89 49 04 89 09 89 69 14 89 0c 24 ff d7 8b 0b 39
Dec  5 10:59:31 block kernel: x55/0xb0

Vince


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
