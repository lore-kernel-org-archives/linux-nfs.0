From: Razvan Gavril <razvan.g@plutohome.com>
Subject: [BUG] kmem_cache_create: duplicate cache nfsd4_stateowners
Date: Mon, 17 Jul 2006 12:51:42 +0300
Message-ID: <44BB5DAE.7080007@plutohome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G2PlX-0004WO-6x
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 02:51:51 -0700
Received: from k2smtpout03-02.prod.mesa1.secureserver.net ([64.202.189.172])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1G2PlX-0007uL-48
	for nfs@lists.sourceforge.net; Mon, 17 Jul 2006 02:51:51 -0700
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


I couldn't get the nfs server running on one of my machine, and by 
looking in dmesg, seams like there is a kernel problem. I use a 
2.6.16.20 vanilla kernel but i remember getting the same error with a 
2.6.17 kernel too, a week ago when trying to run rpc.nfsd. I couldn't 
get any pattern to reproduce it yet but i got it more then once. If you 
need any other info, please contact me.



uname  -a :
---------------------------------
Linux cpe-65 2.6.16.20-pluto-1-686 #1 Wed Jun 14 12:08:23 EDT 2006 i686 
GNU/Linux



dmesg :
---------------------------------
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
NFSD: unable to find recovery directory /var/lib/nfs/v4recovery
NFSD: starting 90-second grace period
kmem_cache_create: duplicate cache nfsd4_stateowners
 [<c01584dd>] kmem_cache_create+0x4fd/0x560
 [<c01416c7>] __alloc_pages+0x57/0x320
 [<e10e4fb0>] nfsd4_init_slabs+0x30/0x120 [nfsd]
 [<e10e8d25>] nfs4_state_start+0x15/0x40 [nfsd]
 [<e10cc05e>] nfsd_svc+0x4e/0x290 [nfsd]
 [<e10cc827>] nfsctl_transaction_write+0x77/0xa0 [nfsd]
 [<c0186492>] sys_nfsservctl+0xc2/0x110
 [<c0102f79>] syscall_call+0x7/0xb
Unable to handle kernel NULL pointer dereference at virtual address 00000018
 printing eip:
e10cc155
*pde = 00000000
Oops: 0000 [#1]
Modules linked in: nfsd exportfs lockd sunrpc capability commoncap 
ide_generic ipt_TCPMSS ipt_MASQUERADE xt_tcpudp xt_mark xt_state 
iptable_nat iptable_filter ip_tables x_tables autofs4 nvidia ipv6 
af_packet ip_nat_irc ip_nat_ftp ip_nat ip_conntrack_irc ip_conntrack_ftp 
ip_conntrack nfnetlink ivtv v4l1_compat cx88_dvb cx8802 cx88xx 
cx88_vp3054_i2c mt352 dvb_pll or51132 video_buf_dvb dvb_core nxt200x 
zl10353 cx24123 lgdt330x cx22702 ftdi_sio usbserial snd_seq_dummy 
snd_seq_oss snd_seq_midi sd_mod snd_seq_midi_event snd_seq parport_pc 
parport analog pcspkr snd_mpu401 psmouse bt878 rtc tuner tda9887 
serio_raw floppy snd_via82xx gameport snd_ac97_codec snd_ac97_bus 
snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc 
snd_mpu401_uart snd_rawmidi snd_seq_device snd soundcore via_rhine 
uhci_hcd i2c_viapro ehci_hcd ide_cd cdrom bttv video_buf firmware_class 
usbcore ir_common sata_via compat_ioctl32 i2c_algo_bit libata 
v4l2_common btcx_risc tveeprom scsi_mod i2c_core videodev shpchp 
pci_hotplug 8139cp amd64_agp agpgart 8139too mii unix ext3 jbd mbcache 
ide_disk generic via82cxxx ide_core evdev mousedev
CPU:    0
EIP:    0060:[<e10cc155>]    Tainted: P      VLI
EFLAGS: 00010297   (2.6.16.20-pluto-1-686 #1)
EIP is at nfsd_svc+0x145/0x290 [nfsd]
eax: 00000000   ebx: 00000008   ecx: 000d9b72   edx: 00000000
esi: 00000000   edi: 00000801   ebp: cfe4aa60   esp: ce6abf58
ds: 007b   es: 007b   ss: 0068
Process rpc.nfsd (pid: 9029, threadinfo=ce6aa000 task=d0f94a90)
Stack: <0>e10f9904 00000006 00000801 00000002 cfe4aa40 00000000 e10cc827 
00000801
       00000008 00000008 00000000 cfe4aa40 c0186492 cfe4aa40 bfd1e9d4 
00000008
       cfe4aa60 00000000 bfd1e9d4 00000201 00000000 b7f09b90 bfd1e9dc 
ce6aa000
Call Trace:
 [<e10cc827>] nfsctl_transaction_write+0x77/0xa0 [nfsd]
 [<c0186492>] sys_nfsservctl+0xc2/0x110
 [<c0102f79>] syscall_call+0x7/0xb
Code: 04 24 e8 5f 2e e6 ff 85 c0 89 c6 0f 88 81 00 00 00 c7 04 24 04 99 
0f e1 e8 69 a4 03 df 89 f6 8d bc 27 00 00 00 00 a1 00 99 0f e1 <8b> 48 
18 29 cb 8d 5b 01 85 db 7e 51 bf 00 97 0f e1 8d 76 00 8d
 <6>kjournald starting.  Commit interval 5 seconds
EXT3-fs warning: maximal mount count reached, running e2fsck is recommended
EXT3 FS on hdd1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hdb1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
EXT2-fs warning: mounting unchecked fs, running e2fsck is recommended
kmem_cache_create: duplicate cache nfsd4_stateowners
 [<c01584dd>] kmem_cache_create+0x4fd/0x560
 [<c01416c7>] __alloc_pages+0x57/0x320
 [<e10e4fb0>] nfsd4_init_slabs+0x30/0x120 [nfsd]
 [<e10e8d25>] nfs4_state_start+0x15/0x40 [nfsd]
 [<e10cc05e>] nfsd_svc+0x4e/0x290 [nfsd]
 [<e10cc827>] nfsctl_transaction_write+0x77/0xa0 [nfsd]
 [<c0186492>] sys_nfsservctl+0xc2/0x110
 [<c0102f79>] syscall_call+0x7/0xb
kmem_cache_create: duplicate cache nfsd4_stateowners
 [<c01584dd>] kmem_cache_create+0x4fd/0x560
 [<c01416c7>] __alloc_pages+0x57/0x320
 [<e10e4fb0>] nfsd4_init_slabs+0x30/0x120 [nfsd]
 [<e10e8d25>] nfs4_state_start+0x15/0x40 [nfsd]
 [<e10cc05e>] nfsd_svc+0x4e/0x290 [nfsd]
 [<e10cc827>] nfsctl_transaction_write+0x77/0xa0 [nfsd]
 [<c0186492>] sys_nfsservctl+0xc2/0x110
 [<c0102f79>] syscall_call+0x7/0xb
kmem_cache_create: duplicate cache nfsd4_stateowners
 [<c01584dd>] kmem_cache_create+0x4fd/0x560
 [<c01416c7>] __alloc_pages+0x57/0x320
 [<e10e4fb0>] nfsd4_init_slabs+0x30/0x120 [nfsd]
 [<e10e8d25>] nfs4_state_start+0x15/0x40 [nfsd]
 [<e10cc05e>] nfsd_svc+0x4e/0x290 [nfsd]
 [<e10cc827>] nfsctl_transaction_write+0x77/0xa0 [nfsd]
 [<c0186492>] sys_nfsservctl+0xc2/0x110
 [<c0102f79>] syscall_call+0x7/0xb

--
Razvan Gavril


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
