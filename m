From: Kenny Simpson <theonetruekenny@yahoo.com>
Subject: kernel BUG at fs/locks.c:1932!
Date: Tue, 20 Dec 2005 18:00:27 -0800 (PST)
Message-ID: <20051221020027.82238.qmail@web34115.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EotHP-0007Wy-8V
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 18:00:35 -0800
Received: from web34115.mail.mud.yahoo.com ([66.163.178.113])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EotHN-0006WK-1V
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 18:00:35 -0800
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

While running some tests (in this case sio) on 2.6.15-rc5 kernel with a r=
ecent NFS_ALL patch
applied, I got this:

[ 1543.034595]  ------------[ cut here ]------------
[ 2687.686724] kernel BUG at fs/locks.c:1932!
[ 2687.690922] invalid operand: 0000 [#3]
[ 2687.694768] PREEMPT SMP=20
[ 2687.697375] Modules linked in: e1000 nvidia agpgart autofs4 parport_pc=
 parport floppy=20
ohci_hcd
i2c_i801 i2c_core generic ehci_hcd uhci_hcd usbcore sn
d_intel8x0 snd_ac97_codec snd_ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm =
snd_timer snd soundcore
snd_page_alloc psmouse mousedev tg3 bcm5700
[ 2687.723803] CPU:    2
[ 2687.723804] EIP:    0060:[<c0171910>]    Tainted: PF     VLI
[ 2687.723805] EFLAGS: 00010246   (2.6.15-rc5+nfs-p4)=20
[ 2687.736945] EIP is at locks_remove_flock+0x6f/0x11f
[ 2687.741948] eax: f789023c   ebx: f5623920   ecx: 00000000   edx: 00000=
000
[ 2687.748916] esi: f7890e9c   edi: f5dccf4c   ebp: f65b9180   esp: f5dcc=
e80
[ 2687.755882] ds: 007b   es: 007b   ss: 0068
[ 2687.760083] Process sio_ntap_linux (pid: 4258, threadinfo=3Df5dcc000 t=
ask=3Df5b81030)
[ 2687.767583] Stack: f5dcceec 00000007 f5dcceec 00000000 00000000 000000=
00 00000000 00000000=20
[ 2687.776216]        00000000 000010a1 00000000 00000000 00000000 000000=
00 f65b9180 00000202=20
[ 2687.784853]        00000000 00000000 ffffffff 7fffffff 00000000 000000=
00 00000000 00000000=20
[ 2687.793484] Call Trace:
[ 2687.796187]  [<c015b62f>] __fput+0x90/0x17e
[ 2687.800495]  [<c0159d02>] filp_close+0x4d/0x79
[ 2687.805069]  [<c0159d9a>] sys_close+0x6c/0x82
[ 2687.809555]  [<c0102e63>] sysenter_past_esp+0x54/0x75
[ 2687.814757] Code: 39 68 2c 74 18 89 c6 8b 06 85 c0 75 f3 e8 7a 5d 29 0=
0 81 c4 cc 00 00 00 5b=20
5e
5f 5d c3 0f b6 50 30 f6 c2 02 75 21 80 e2 20 75 0a <0
f> 0b 8c 07 40 ae 42 c0 eb d0 89 34 24 c7 44 24 04 02 00 00 00=20

-Kenny


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
