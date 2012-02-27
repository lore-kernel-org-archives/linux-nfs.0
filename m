Return-Path: linux-nfs-owner@vger.kernel.org
Received: from che.mayfirst.org ([209.234.253.108]:60675 "EHLO
	che.mayfirst.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab2B0Sbt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2012 13:31:49 -0500
From: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
To: debian-backports@lists.debian.org, linux-nfs@vger.kernel.org
Subject: null pointer dereference in linux kernel 3.2.4 in nfs4_xdr_enc_getacl
Date: Mon, 27 Feb 2012 13:32:16 -0500
Message-ID: <871upg2klr.fsf@pip.fifthhorseman.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I'm running linux kernel 3.2.4-1~bpo60+1 from debian's squeeze-backports
repository on a 32-bit x86 machine.  The machine in question is an NFSv4
client, using sec=3Dkrb5p.  Both the NFS client and server are both
running rpc.svcgssd and rpc.gssd (so i think delegations are in effect,
though i don't know how to check).

I got the following crash report from the client, which was subsequently
unresponsive at the keyboard, and declined to shut down cleanly (i
needed to do a hard poweroff to get the machine functional again for the
user).


Feb 27 10:39:55 birman kernel: [13172.618474] usb 2-1: USB disconnect, devi=
ce number 4
Feb 27 11:55:29 birman kernel: [17706.184079] BUG: unable to handle kernel =
NULL pointer dereference at   (null)
Feb 27 11:55:29 birman kernel: [17706.184097] IP: [<c10b2623>] page_address=
+0x6/0x97
Feb 27 11:55:29 birman kernel: [17706.184108] *pdpt =3D 00000000365d3001 *p=
de =3D 0000000000000000=20
Feb 27 11:55:29 birman kernel: [17706.184116] Oops: 0000 [#1] SMP=20
Feb 27 11:55:29 birman kernel: [17706.184122] Modules linked in: nls_utf8 n=
ls_cp437 vfat fat usb_storage uas tun ip6table_filter ip6_tables iptable_fi=
lter ip_tables x_tables parport_pc ppdev lp parport bnep rfcomm bluetooth c=
rc16 uinput kvm_amd kvm fuse sha1_generic hmac cryptd aes_i586 aes_generic =
cbc cts rpcsec_gss_krb5 nfsd nfs lockd fscache auth_rpcgss nfs_acl sunrpc b=
ridge stp ext2 loop snd_hda_codec_hdmi tpm_infineon snd_hda_codec_realtek n=
ouveau snd_hda_intel snd_hda_codec ttm hp_wmi drm_kms_helper drm sparse_key=
map i2c_algo_bit snd_hwdep snd_pcm rfkill snd_seq snd_timer snd_seq_device =
sp5100_tco mxm_wmi i2c_piix4 snd usbhid video i2c_core wmi pcspkr processor=
 evdev psmouse tpm_tis tpm tpm_bios serio_raw thermal_sys usblp soundcore s=
nd_page_alloc hid k10temp ext3 jbd mbcache dm_mod sg sd_mod sr_mod crc_t10d=
if cdrom ohci_hcd ehci_hcd ahci libahci tg3 libphy libata scsi_mod usbcore =
usb_common button [last unloaded: scsi_wait_scan]
Feb 27 11:55:29 birman kernel: [17706.184281]=20
Feb 27 11:55:29 birman kernel: [17706.184285] Pid: 7568, comm: eog Not tain=
ted 3.2.0-0.bpo.1-686-pae #1 Hewlett-Packard HP Compaq 6005 Pro SFF PC/3047h
Feb 27 11:55:29 birman kernel: [17706.184299] EIP: 0060:[<c10b2623>] EFLAGS=
: 00210202 CPU: 2
Feb 27 11:55:29 birman kernel: [17706.184305] EIP is at page_address+0x6/0x=
97
Feb 27 11:55:29 birman kernel: [17706.184310] EAX: 00000000 EBX: 00000000 E=
CX: f6711804 EDX: 000000dc
Feb 27 11:55:29 birman kernel: [17706.184316] ESI: f67c3bf4 EDI: 00000037 E=
BP: f67c3c24 ESP: f67c3bd0
Feb 27 11:55:29 birman kernel: [17706.184322]  DS: 007b ES: 007b FS: 00d8 G=
S: 00e0 SS: 0068
Feb 27 11:55:29 birman kernel: [17706.184328] Process eog (pid: 7568, ti=3D=
f67c2000 task=3Df315b760 task.ti=3Df67c2000)
Feb 27 11:55:29 birman kernel: [17706.184334] Stack:
Feb 27 11:55:29 birman kernel: [17706.184337]  f67c3ddc f67c3bf4 00000037 f=
67c3c24 fb4b1ff3 00000000 00001000 f67c3bf4
Feb 27 11:55:29 birman kernel: [17706.184351]  f6a67ac0 00000000 00000002 f=
6711074 00000000 00000000 00000097 00000000
Feb 27 11:55:29 birman kernel: [17706.184365]  f6a67ac0 fb4b1f5c fb4b1f5c f=
6711064 f86402a8 f67110a0 f6a67ac4 f6711728
Feb 27 11:55:29 birman kernel: [17706.184379] Call Trace:
Feb 27 11:55:29 birman kernel: [17706.184393]  [<fb4b1ff3>] ? nfs4_xdr_enc_=
getacl+0x97/0xb4 [nfs]
Feb 27 11:55:29 birman kernel: [17706.184407]  [<fb4b1f5c>] ? nfs4_xdr_enc_=
setacl+0xdf/0xdf [nfs]
Feb 27 11:55:29 birman kernel: [17706.184420]  [<fb4b1f5c>] ? nfs4_xdr_enc_=
setacl+0xdf/0xdf [nfs]
Feb 27 11:55:29 birman kernel: [17706.184428]  [<f86402a8>] ? gss_wrap_req_=
encode+0x1e/0x25 [auth_rpcgss]
Feb 27 11:55:29 birman kernel: [17706.184441]  [<fb4b1f5c>] ? nfs4_xdr_enc_=
setacl+0xdf/0xdf [nfs]
Feb 27 11:55:29 birman kernel: [17706.184449]  [<f8640429>] ? gss_wrap_req+=
0x158/0x2eb [auth_rpcgss]
Feb 27 11:55:29 birman kernel: [17706.184456]  [<f8640a63>] ? gss_marshal+0=
x134/0x13e [auth_rpcgss]
Feb 27 11:55:29 birman kernel: [17706.184464]  [<f86402d1>] ? priv_release_=
snd_buf+0x22/0x22 [auth_rpcgss]
Feb 27 11:55:29 birman kernel: [17706.184477]  [<fb4b1f5c>] ? nfs4_xdr_enc_=
setacl+0xdf/0xdf [nfs]
Feb 27 11:55:29 birman kernel: [17706.184489]  [<f8ec138e>] ? rpcauth_wrap_=
req+0x56/0x7c [sunrpc]
Feb 27 11:55:29 birman kernel: [17706.184506]  [<f8ebab90>] ? call_transmit=
+0x175/0x1e0 [sunrpc]
Feb 27 11:55:29 birman kernel: [17706.184518]  [<f8ec0989>] ? __rpc_execute=
+0x5b/0x1ee [sunrpc]
Feb 27 11:55:29 birman kernel: [17706.184527]  [<f8ebb668>] ? rpc_run_task+=
0x57/0x5c [sunrpc]
Feb 27 11:55:29 birman kernel: [17706.184536]  [<f8ebb74e>] ? rpc_call_sync=
+0x3c/0x56 [sunrpc]
Feb 27 11:55:29 birman kernel: [17706.184549]  [<fb4a6a1c>] ? __nfs4_get_ac=
l_uncached+0x165/0x1f9 [nfs]
Feb 27 11:55:29 birman kernel: [17706.184563]  [<fb4a6b8c>] ? nfs4_xattr_ge=
t_nfs4_acl+0xdc/0x10a [nfs]
Feb 27 11:55:29 birman kernel: [17706.184571]  [<c10eb661>] ? generic_getxa=
ttr+0x61/0x65
Feb 27 11:55:29 birman kernel: [17706.184578]  [<c10eb600>] ? single_open+0=
x70/0x70
Feb 27 11:55:29 birman kernel: [17706.184584]  [<c10ebd8e>] ? vfs_getxattr+=
0x76/0x7d
Feb 27 11:55:29 birman kernel: [17706.184589]  [<c10ebe18>] ? getxattr+0x83=
/0xe2
Feb 27 11:55:29 birman kernel: [17706.184596]  [<c10e50c8>] ? dput+0x21/0xc4
Feb 27 11:55:29 birman kernel: [17706.184601]  [<c10dfb01>] ? path_lookupat=
+0x297/0x2a8
Feb 27 11:55:29 birman kernel: [17706.184607]  [<c10e04cd>] ? user_path_at_=
empty+0x46/0x65
Feb 27 11:55:29 birman kernel: [17706.184613]  [<c10ebb36>] ? listxattr+0x8=
0/0x88
Feb 27 11:55:29 birman kernel: [17706.184619]  [<c10ebef3>] ? sys_getxattr+=
0x37/0x48
Feb 27 11:55:29 birman kernel: [17706.184626]  [<c12cddbc>] ? syscall_call+=
0x7/0xb
Feb 27 11:55:29 birman kernel: [17706.184630] Code: 89 73 0c 89 0e eb 0c 8d=
 58 f8 8d 4b 08 39 f1 75 a1 89 f8 59 5b 5b 5e 5f 5d e9 14 b5 21 00 0f 0b e9=
 04 ff ff ff 55 57 56 53 89 c3 <8b> 00 c1 e8 1e 69 c0 40 03 00 00 05 40 7e =
41 c1 2b 80 0c 03 00=20
Feb 27 11:55:29 birman kernel: [17706.184699] EIP: [<c10b2623>] page_addres=
s+0x6/0x97 SS:ESP 0068:f67c3bd0
Feb 27 11:55:29 birman kernel: [17706.184709] CR2: 0000000000000000
Feb 27 11:55:29 birman kernel: [17706.188397] ---[ end trace e521447c73f579=
14 ]---

Please let me know if i can provide any more useful information about
this, or if there's something i can do to avoid this crash in the
future.

        --dkg

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQJ8BAEBCgBmBQJPS8wwXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXQwRUU1QkU5NzkyODJEODBCOUY3NTQwRjFD
Q0QyRUQ5NEQyMTczOUU5AAoJEMzS7ZTSFznp59gQAJTQ8ihpYi5gY7PyGJiTfwGz
lSAbo7CIiFkOUR/2Og5RPMdKDgxkkLHa6HlMlx6F93QOL3tXkF4p+Xp+RXsZknJM
4YFNAY5J05DftgfqfaM40aY1qnqTh97eiEm4ay3ygywZqqU5iLNBrgoDuGywhAqF
lRFKjGln4uuxh0ow5z2lvLuXkNSl1fNyo8HmHePzc4WOUb9gMjpDB4N9kPZFvnh8
nDMAcp5suAocP9krvjGevLQ+0sfRXp8N6ryemhEBqSk3EmyOHL9p+vuCyIbgItFB
gdqDMLEPuCGM19Ufhaqy7UI37BS7+wtz7cHSxWuYNAJ2p90Fsm5PZHMUmjpMAMhS
H+MwwgBH6rci1Sx62dzoZsyI5q+SlqvdQDRHIT2evWIH4HRhorOjOuz06JTa3zkR
iVWllhgvvqQzy/Dod1LdWOcHz1JQGVOvGtUkETvRe7RKEol3/eNO1Kxw8URnQxTp
UBAJh1FWOw2aMaCPx7kMTKM8my3RE2I/LZmE51PqjNgcDgPZnnxyD1sr4tjLC67F
668UQ0QkdTbHW54Y+Og0rzhnQzlJAVgUKRofLPut6NgQMV4yzrtw5Kjw1kLHBYRM
1jH/HdCHGhN2YLUU1+UH8xocwvWEu8uxnaOnfa7le2KOL2MuuKHhXrIGmcMNnHmD
jlR56KY6el7/Yw76KTyw
=zhXT
-----END PGP SIGNATURE-----
--=-=-=--
