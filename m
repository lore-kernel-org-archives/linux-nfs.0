From: Vince Busam <vbusam@google.com>
Subject: Re: [PATCH] Fix typo on __rpc_purge_upcall
Date: Mon, 12 Dec 2005 10:57:13 -0800
Message-ID: <439DC809.3020502@google.com>
References: <4382252E.4000602@google.com>	 <1132602917.8011.2.camel@lade.trondhjem.org> <43824151.5060604@google.com>	 <1132612440.8011.7.camel@lade.trondhjem.org> <4382515C.9020200@google.com>	 <1132614431.8011.14.camel@lade.trondhjem.org> <438B4983.3030809@google.com> <1133203961.27574.66.camel@lade.trondhjem.org> <4394AB2E.1030809@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ElsrW-0005OY-Ss
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 10:57:26 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ElsrW-0002ve-RE
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 10:57:27 -0800
Received: from mail2.smo.corp.google.com (mail2.smo.corp.google.com [172.29.48.30])
	by smtp-out.google.com with ESMTP id jBCIvI2r013543
	for <nfs@lists.sourceforge.net>; Mon, 12 Dec 2005 10:57:18 -0800
Received: from [172.29.52.29] (block.smo.corp.google.com [172.29.52.29])
	by mail2.smo.corp.google.com with ESMTP id jBCIvDlC002187
	for <nfs@lists.sourceforge.net>; Mon, 12 Dec 2005 10:57:13 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <4394AB2E.1030809@google.com>
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

I applied this patch from 2.6.15-rc5, and got the following oops.  I really wish I could 
reproduce this faster, but it still only happens over the weekend when my credentials have 
expired.  Letting them expire during the week doesn't reproduce it.

--- e3b242daf53c64506f9ba77937a94bb544bcefe6
+++ c76ea221798caf96666ef99ac3ce5c1694c832b7
@@ -59,7 +59,6 @@ __rpc_purge_upcall(struct inode *inode,
  	struct rpc_inode *rpci = RPC_I(inode);

  	__rpc_purge_list(rpci, &rpci->pipe, err);
-	__rpc_purge_list(rpci, &rpci->in_upcall, err);
  	rpci->pipelen = 0;
  	wake_up(&rpci->waitq);
  }
@@ -119,6 +118,7 @@ rpc_close_pipes(struct inode *inode)
  	down(&inode->i_sem);
  	if (rpci->ops != NULL) {
  		rpci->nreaders = 0;
+		__rpc_purge_list(rpci, &rpci->in_upcall, -EPIPE);
  		__rpc_purge_upcall(inode, -EPIPE);
  		rpci->nwriters = 0;
  		if (rpci->ops->release_pipe)


Dec 11 13:53:28 block kernel: RPC: AUTH_GSS upcall timed out.
Dec 11 13:53:28 block kernel: Please check user daemon is running!
Dec 11 13:53:43 block kernel: RPC: AUTH_GSS upcall timed out.
Dec 11 13:53:43 block kernel: Please check user daemon is running!
Dec 11 13:53:43 block kernel: Unable to handle kernel NULL pointer dereference at virtual 
address 00000004
Dec 11 13:53:43 block kernel: printing eip:
Dec 11 13:53:43 block kernel: f8ad1d55
Dec 11 13:53:43 block kernel: *pde = 00000000
Dec 11 13:53:43 block kernel: Oops: 0002 [#1]
Dec 11 13:53:43 block kernel: PREEMPT SMP
Dec 11 13:53:43 block kernel: Modules linked in: ext2 loop des binfmt_misc 
cpufreq_userspace cpufreq_ondemand cpufreq_powersave autofs4 video button battery 
container ac capability commoncap nfs lockd af_packet tg3 generic piix snd_intel8x0 
snd_usb_audio snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_usb_lib 
snd_rawmidi snd_seq_device snd_hwdep snd soundcore snd_page_alloc pwc videodev v4l2_common 
uhci_hcd pci_hotplug floppy pcspkr rtc tsdev usbhid evdev md_mod dm_mod nvidia agpgart 
psmouse mousedev parport_pc lp parport ide_generic ide_disk ide_cd cdrom rpcsec_gss_krb5 
auth_rpcgss sunrpc ehci_hcd ext3 jbd mbcache ahci sd_mod ata_piix libata usb_storage 
usbcore scsi_mod ide_core unix thermal processor fan
Dec 11 13:53:43 block kernel: CPU:    1
Dec 11 13:53:43 block kernel: EIP:    0060:[<f8ad1d55>]    Tainted: P      VLI
Dec 11 13:53:43 block kernel: EFLAGS: 00010287   (2.6.13.4-gg5vb8)
Dec 11 13:53:43 block kernel: EIP is at __rpc_purge_list+0x35/0x60 [sunrpc]
Dec 11 13:53:43 block kernel: eax: 00000000   ebx: ebcdc684   ecx: ea628908   edx: 00000000
Dec 11 13:53:43 block kernel: esi: f890ece0   edi: ffffffe0   ebp: ebcdc500   esp: ebac7f1c
Dec 11 13:53:43 block kernel: ds: 007b   es: 007b   ss: 0068
Dec 11 13:53:43 block kernel: Process rpc.gssd (pid: 7196, threadinfo=ebac6000 task=dfe61540)
Dec 11 13:53:43 block kernel: Stack: ea628900 ebcdc500 ffffffe0 ebcdc500 f8ad1dad ebcdc500 
ebcdc684 ffffffe0
Dec 11 13:53:43 block kernel: ebcdc500 ea20ea80 f8ad213b ebcdc500 ffffffe0 00000008 
ea20ea80 ebcdaf00
Dec 11 13:53:43 block kernel: c01675fa ebcdc500 ea20ea80 00000000 00000000 ebba9d40 
ea20ea80 dfb06080
Dec 11 13:53:43 block kernel: Call Trace:
Dec 11 13:53:43 block kernel: [<f8ad1dad>] __rpc_purge_upcall+0x2d/0x80 [sunrpc]Dec 11 
13:53:43 block kernel: [<f8ad213b>] rpc_pipe_release+0xcb/0xf0 [sunrpc]
Dec 11 13:53:43 block kernel: [<c01675fa>] __fput+0x18a/0x1d0
Dec 11 13:53:43 block kernel: [<c0165906>] filp_close+0x46/0x90
Dec 11 13:53:43 block kernel: [<c01659ba>] sys_close+0x6a/0xa0
Dec 11 13:53:43 block kernel: [<c010316b>] sysenter_past_esp+0x54/0x75
Dec 11 13:53:43 block kernel: Code: 8b 44 24 14 8b 7c 24 1c 8b 0b 8b 80 b4 01 00 00 39 d9 
8b 70 0c 74 2c eb 0d 90 90 90 90 90 90 90 90 90 90 90 90 90 8b 51 04 8b 01 <89> 50 04 89 
02 89 49 04 89 09 89 79 14 89 0c 24 ff d6 8b 0b 39


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
