From: Vince Busam <vbusam@google.com>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Thu, 05 Jan 2006 14:30:25 -0800
Message-ID: <43BD9E01.9040804@google.com>
References: <4382252E.4000602@google.com>	 <1132602917.8011.2.camel@lade.trondhjem.org> <43824151.5060604@google.com>	 <1132612440.8011.7.camel@lade.trondhjem.org> <4382515C.9020200@google.com>	 <1132614431.8011.14.camel@lade.trondhjem.org> <438B4983.3030809@google.com>	 <1133203961.27574.66.camel@lade.trondhjem.org>	 <4394AB2E.1030809@google.com>  <439DC809.3020502@google.com>	 <1134415137.7877.10.camel@lade.trondhjem.org> <439DDE7D.3050904@google.com> <1134431510.8028.26.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EuddB-0004rC-H2
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 14:30:49 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EuddB-0001ga-9E
	for nfs@lists.sourceforge.net; Thu, 05 Jan 2006 14:30:49 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134431510.8028.26.camel@lade.trondhjem.org>
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
> On Mon, 2005-12-12 at 12:33 -0800, Vince Busam wrote:
> 
>>Trond Myklebust wrote:
>>
>>>Could you send us the contents of rpc_close_pipes() and
>>>rpc_pipe_release()?
>>>
> 
> 
> Hmm.... Looks correct. The only potential races I can see should be
> fixed by the following patch. Can you apply and then try again?
> 

I'm still got an oops after applying that patch (it still takes a long time for it to 
occur, this happened over the break with expired credentials).

Dec 24 01:07:43 block kernel: RPC: AUTH_GSS upcall timed out.
Dec 24 01:07:43 block kernel: Please check user daemon is running!
Dec 24 01:07:45 block kernel: Unable to handle kernel NULL pointer dereference at virtual 
address 00000004
Dec 24 01:07:45 block kernel: printing eip:
Dec 24 01:07:45 block kernel: f8ad1d4b
Dec 24 01:07:45 block kernel: *pde = 00000000
Dec 24 01:07:45 block kernel: Oops: 0002 [#1]
Dec 24 01:07:45 block kernel: PREEMPT SMP
Dec 24 01:07:45 block kernel: Modules linked in: des binfmt_misc cpufreq_userspace 
cpufreq_ondemand cpufreq_powersave autofs4 video button battery container ac
capability commoncap nfs lockd af_packet tg3 generic piix snd_intel8x0 snd_ac97_codec 
snd_usb_audio snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd_usb_lib 
snd_rawmidi snd_seq_device snd_hwdep snd soundcore pwc videodev v4l2_common uhci_hcd 
pci_hotplug floppy pcspkr rtc tsdev evdev usbhid md_mod dm_mod nvidia agpgart psmouse 
mousedev parport_pc lp parport ide_generic ide_disk ide_cd cdrom rpcsec_gss_krb5 
auth_rpcgss sunrpc ehci_hcd ext3 jbd mbcache ahci sd_mod
ata_piix libata usb_storage usbcore scsi_mod ide_core unix thermal processor fanDec 24 
01:07:45 block kernel: CPU:    1
Dec 24 01:07:45 block kernel: EIP:    0060:[<f8ad1d4b>]    Tainted: P      VLI
Dec 24 01:07:45 block kernel: EFLAGS: 00010286   (2.6.13.4-gg5vb9)
Dec 24 01:07:45 block kernel: EIP is at __rpc_purge_list+0x2b/0xc0 [sunrpc]
Dec 24 01:07:45 block kernel: eax: 00000000   ebx: c877de88   ecx: c877dea0   edx: 00000000
Dec 24 01:07:45 block kernel: esi: ec69e684   edi: f890ece0   ebp: ffffffe0   esp: ebd4ff14
Dec 24 01:07:45 block kernel: ds: 007b   es: 007b   ss: 0068
Dec 24 01:07:45 block kernel: Process rpc.gssd (pid: 7410, threadinfo=ebd4e000 task=ec48c540)
Dec 24 01:07:45 block kernel: Stack: c877de80 00000002 d646d440 ec69e500 ffffffe0 ec68fa00 
ec69e500 f8ad1e15
Dec 24 01:07:45 block kernel: ec69e500 ec69e684 ffffffe0 ec69e500 e584bc80 f8ad21be 
ec69e500 ffffffe0
Dec 24 01:07:45 block kernel: 00000008 e584bc80 c01675fa ec69e500 e584bc80 00000000 
00000000 ebe667a0
Dec 24 01:07:45 block kernel: Call Trace:
Dec 24 01:07:45 block kernel: [<f8ad1e15>] __rpc_purge_upcall+0x35/0xb0 [sunrpc]Dec 24 
01:07:45 block kernel: [<f8ad21be>] rpc_pipe_release+0xae/0xd0 [sunrpc]
Dec 24 01:07:45 block kernel: [<c01675fa>] __fput+0x18a/0x1d0
Dec 24 01:07:45 block kernel: [<c0165906>] filp_close+0x46/0x90
Dec 24 01:07:45 block kernel: [<c01659ba>] sys_close+0x6a/0xa0
Dec 24 01:07:45 block kernel: [<c010316b>] sysenter_past_esp+0x54/0x75
Dec 24 01:07:45 block kernel: Code: 55 57 56 53 83 ec 0c 8b 5c 24 20 8b 74 24 24 8b 6c 24 
28 85 db 74 78 85 f6 74 54 8b 83 b4 01 00 00 8b 78 0c eb 17 8b 53 04 8b 03 <89> 50 04 89 
02 89 5b 04 89 1b 89 6b 14 89 1c 24 ff d7 8b 1e 39

After dissassembling the code, it appears this is happening in list_del_init(&msg->list) 
in __rpc_purge_list(), in the first line of the inlined function __list_del().

Vince


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
