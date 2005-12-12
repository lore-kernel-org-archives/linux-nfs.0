From: Nikhil Kasinadhuni <nikhilk@google.com>
Subject: NFSv3 and krb5 ticket expiry issues
Date: Mon, 12 Dec 2005 14:21:46 -0800
Message-ID: <ad8f623c0512121421o60880edbm21b90bda1ca4d534@mail.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vince Busam <vbusam@google.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Elw3j-0004Ev-Gv
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 14:22:15 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Elw3i-000487-8j
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 14:22:15 -0800
Received: from evilmonkey.corp.google.com (evilmonkey.corp.google.com [172.24.0.124])
	by smtp-out.google.com with ESMTP id jBCMM4e1012999
	for <nfs@lists.sourceforge.net>; Mon, 12 Dec 2005 14:22:04 -0800
Received: from smtp-out2.google.com (epa14.prod.google.com [10.253.129.14])
	by evilmonkey.corp.google.com with ESMTP id jBCMAY4M023760
	for <nfs@lists.sourceforge.net>; Mon, 12 Dec 2005 14:21:47 -0800
Received: by smtp-out2.google.com with SMTP id 14so14040epa
        for <nfs@lists.sourceforge.net>; Mon, 12 Dec 2005 14:21:46 -0800 (PST)
To: nfs@lists.sourceforge.net
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

Hello all,

I'm running NFSv3 with krb5 along with the following patches:

linux-2.6.14-88-rpcsec_gss_fix.dif
linux-2.6.15-06-rpc_pipe_fix_cleanup.dif
linux-2.6.13-CITI_NFS4_ALL-1.dif
linux-2.6.15-remove_in_upcall.dif

When the krb5 ticket is about to expire, there's a constant flow in the log=
s:

Nov  5 18:16:10 divinity rpc.gssd[6448]: handling krb5 upcall
Nov  5 18:16:10 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor)
Requested effective lifetime is negative or too short
Nov  5 18:16:10 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor) No
credentials cache found
Nov  5 18:16:10 divinity rpc.gssd[6448]: WARNING: Failed to create
krb5 context for user with uid xxx for server xxx
Nov  5 18:16:10 divinity rpc.gssd[6448]: doing error downcall
Nov  5 18:16:10 divinity rpc.gssd[6448]: handling krb5 upcall
Nov  5 18:16:10 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor)
Requested effective lifetime is negative or too short
Nov  5 18:16:10 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor) No
credentials cache found
Nov  5 18:16:10 divinity rpc.gssd[6448]: WARNING: Failed to create
krb5 context for user with uid xxx for server xxx
Nov  5 18:16:10 divinity rpc.gssd[6448]: doing error downcall

and eventually, once the ticket expires:

Nov  6 09:38:57 divinity rpc.gssd[6448]: handling krb5 upcall
Nov  6 09:38:57 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor) Ticket
expired
Nov  6 09:38:57 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor) No
credentials cache found
Nov  6 09:38:57 divinity rpc.gssd[6448]: WARNING: Failed to create
krb5 context for user with uid xxx for server xxx
Nov  6 09:38:57 divinity rpc.gssd[6448]: doing error downcall
Nov  6 09:38:57 divinity rpc.gssd[6448]: handling krb5 upcall
Nov  6 09:38:57 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor) Ticket
expired
Nov  6 09:38:57 divinity rpc.gssd[6448]: rpcsec_gss:
gss_init_sec_context: (major) Miscellaneous failure - (minor) No
credentials cache found
Nov  6 09:38:57 divinity rpc.gssd[6448]: WARNING: Failed to create
krb5 context for user with uid xxx for server xxx
Nov  6 09:38:57 divinity rpc.gssd[6448]: doing error downcall
Nov  6 09:38:57 divinity rpc.gssd[6448]: handling krb5 upcall

---

Occasionally, I get the following message:

Dec  4 01:26:49 divinity rpc.gssd[6356]: processing client list
Dec  4 01:26:49 divinity kernel: RPC: AUTH_GSS upcall timed out.
Dec  4 01:26:49 divinity kernel: Please check user daemon is running!


Is this the way its designed to work - rpc.gssd and the kernel hitting
bouncing against each other continuously? Wouldn't it be a better idea
to block IO till the ticket is renewed?

This goes on for a few hours and the system finally hits an OOPS
and/or refuses to create any processes (can ssh in but will not get a
prompt). I wonder if this a result of a bug in the kernel or rpc.gssd.
I can reproduce this bug consistantly when the machine is left idle
over the weekend. We've since disabled printing the errors in the logs
so that our logs do not fill up, but the system still freezes up.

This only happens when I am logged into the workstation and leave it
locked via xscreensaver over the weekend. I am assuming there are open
files over the weekend (GNOME) and once the ticket expires, the kernel
and rpc.gssd start pounding away at each other.

This is an older Oops I got:

Oct 30 00:22:43 divinity rpc.gssd[6483]: doing error downcall
Oct 30 00:22:43 divinity rpc.gssd[6483]: processing client list
Oct 30 00:22:43 divinity kernel: Unable to handle kernel NULL pointer
dereference at virtual address 00000004
Oct 30 00:22:43 divinity kernel: printing eip:
Oct 30 00:22:43 divinity kernel: f8abaf95
Oct 30 00:22:43 divinity kernel: *pde =3D 00000000
Oct 30 00:22:43 divinity kernel: Oops: 0002 [#1]
Oct 30 00:22:43 divinity kernel: PREEMPT SMP
Oct 30 00:22:43 divinity kernel: Modules linked in: des binfmt_misc
cpufreq_userspace cpufreq_ondemand cpufreq_powersave autofs4 video
sony_acpi pcc_acpi dev_acpi i2c_acpi_ec i2c_core button battery
container ac nfs lockd af_packet tg3 snd_intel8x0 snd_ac97_codec
snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore tsdev
snd_page_alloc hw_random usbhid uhci_hcd pci_hotplug floppy pcspkr rtc
evdev md dm_mod nvidia agpgart psmouse
mousedev parport_pc lp parport ide_generic ide_disk ide_cd ide_core
rpcsec_gss_krb5 auth_rpcgss sunrpc ehci_hcd usbcore ext3 jbd mbcache
ahci sr_mod cdrom sd_mod sg ata_piix libata scsi_mod unix thermal
processor fan
Oct 30 00:22:43 divinity kernel: CPU:    0
Oct 30 00:22:43 divinity kernel: EIP:    0060:[<f8abaf95>]    Tainted:
P      VLI
Oct 30 00:22:43 divinity kernel: EFLAGS: 00010283   (2.6.12-gg3)
Oct 30 00:22:43 divinity kernel: EIP is at __rpc_purge_upcall+0x25/0xb0 [su=
nrpc]
Oct 30 00:22:43 divinity kernel: eax: 00000000   ebx: f732a500   ecx:
e994eb88   edx: 00000000
Oct 30 00:22:43 divinity kernel: esi: f732a684   edi: ffffffe0   ebp:
f732a500   esp: f740df34
Oct 30 00:22:43 divinity kernel: ds: 007b   es: 007b   ss: 0068
Oct 30 00:22:43 divinity kernel: Process rpc.gssd (pid: 6483,
threadinfo=3Df740c000 task=3Df624ba60)
Oct 30 00:22:43 divinity kernel: Stack: e994eb80 f732a500 ea9f0780
f732a500 f8abb33b f732a500 ffffffe0 00000008
Oct 30 00:22:43 divinity kernel: ea9f0780 dfb41980 c01667fa f732a500
ea9f0780 00000000 00000000 f5affe60
Oct 30 00:22:43 divinity kernel: ea9f0780 00000000 c2934a80 ea9f0780
c0164b72 ea9f0780 c2934a80 c2934a80
Oct 30 00:22:43 divinity kernel: Call Trace:
Oct 30 00:22:43 divinity kernel: [<f8abb33b>]
rpc_pipe_release+0xcb/0xf0 [sunrpc]
Oct 30 00:22:43 divinity kernel: [<c01667fa>] __fput+0x18a/0x1d0
Oct 30 00:22:43 divinity kernel: [<c0164b72>] filp_close+0x52/0xa0
Oct 30 00:22:43 divinity kernel: [<c0164c2a>] sys_close+0x6a/0xa0
Oct 30 00:22:43 divinity kernel: [<c010343b>] sysenter_past_esp+0x54/0x75
Oct 30 00:22:43 divinity kernel: Code: 90 90 90 90 90 90 57 56 53 83
ec 04 8b 5c 24 14 8b 7c 24 18 8b 8b 84 01 00 00 8d b3 84 01 00 00 39
f1 74 2a 89 f6 8b 41 04 8b 11 <89> 42 04 89 10 89 49 04 89 09 89 79 14
8b 83 b4 01 00 00 89 0c

Thanks,

Nikhil.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
