From: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
Subject: Oops on flock on NFS3 krb5 mount
Date: Thu, 27 Jan 2005 20:59:32 -0800
Message-ID: <41F9C6B4.1030301@csua.berkeley.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuOEM-0007Hw-1U
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 20:59:38 -0800
Received: from soda.csua.berkeley.edu ([128.32.112.233] ident=[xz+E/yEYjqWeIDwMtHJ6ABNUDid7HbL1])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CuOEL-00040I-CZ
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 20:59:37 -0800
Received: from [127.0.0.1] (IDENT:OqiB3/v4y6y96w5QZmn09PvTQckEmrqL@localhost [127.0.0.1])
	by soda.csua.berkeley.edu (8.12.9/8.12.6) with ESMTP id j0S4xXij021220
	for <nfs@lists.sourceforge.net>; Thu, 27 Jan 2005 20:59:33 -0800 (PST)
	(envelope-from mgoodman@csua.berkeley.edu)
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

On 2.6.11-rc2 with Trond's patches applied, when I run the following on 
my NFS3 krb5 mount:

#include <stdio.h>
#include <sys/file.h>
#include <unistd.h>

int main(void) {
  int fd = open("foo", O_CREAT);
  flock(fd, LOCK_SH);
  close(fd);
  return 0;
}

I get:

Jan 27 20:49:23 soda kernel: net/sunrpc/auth_gss/auth_gss.c:356: 
spin_is_locked on uninitialized spinlock f6e62dbc.
Jan 27 20:49:23 soda kernel: net/sunrpc/auth_gss/auth_gss.c:356: 
spin_lock(<NULL>:f6e62dbc) already locked by /0
Jan 27 20:49:23 soda kernel: Unable to handle kernel paging request at 
virtual address 6469705f
Jan 27 20:49:23 soda kernel:  printing eip:
Jan 27 20:49:23 soda kernel: f8a0f467
Jan 27 20:49:23 soda kernel: *pde = 00000000
Jan 27 20:49:23 soda kernel: Oops: 0000 [#1]
Jan 27 20:49:23 soda kernel: Modules linked in: des nfs lockd parport_pc 
lp parport autofs4 rpcsec_gss_krb5 auth_rpcgss sunrpc video button 
battery ac md5 ipv6 uhci_hcd ehci_hcd snd_intel8x0 snd_ac97_codec 
snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc 
tg3 floppy dm_snapshot dm_zero dm_mirror ext3 jbd dm_mod ata_piix libata 
sd_mod scsi_mod
Jan 27 20:49:23 soda kernel: CPU:    0
Jan 27 20:49:23 soda kernel: EIP:    0060:[<f8a0f467>]    Not tainted VLI
Jan 27 20:49:23 soda kernel: EFLAGS: 00010286   (2.6.11-rc2)
Jan 27 20:49:23 soda kernel: EIP is at __gss_find_upcall+0x17/0xb0 
[auth_rpcgss]
Jan 27 20:49:23 soda kernel: eax: f6e62d60   ebx: 64697047   ecx: 
6469705f   edx: 000010a0
Jan 27 20:49:23 soda kernel: esi: f6e62d60   edi: 000010a0   ebp: 
f8a1476c   esp: f4fe9b24
Jan 27 20:49:23 soda kernel: ds: 007b   es: 007b   ss: 0068
Jan 27 20:49:23 soda kernel: Process test (pid: 5538, 
threadinfo=f4fe9000 task=f6bfa930)
Jan 27 20:49:23 soda kernel: Stack: f6e62d60 f6c81124 00000000 f6e62d60 
f6c81124 f8a0f6e0 f8a14874 f8a1476c
Jan 27 20:49:23 soda kernel:        00000164 00000000 f6e62dbc f6b88000 
00000000 00000000 000010a0 00000032
Jan 27 20:49:23 soda kernel:        f89c4f97 f72a00c0 f6c81080 f6c81080 
f72a00c0 f6c81124 f4fe9bb8 f89cd767
Jan 27 20:49:23 soda kernel: Call Trace:
Jan 27 20:49:23 soda kernel:  [<f8a0f6e0>] gss_upcall+0x60/0x500 
[auth_rpcgss]
Jan 27 20:49:23 soda kernel:  [<f89c4f97>] call_encode+0xa7/0x140 [sunrpc]
Jan 27 20:49:23 soda kernel:  [<f89cd767>] rpcauth_refreshcred+0x27/0x60 
[sunrpc]
Jan 27 20:49:23 soda kernel:  [<f89c5786>] call_refresh+0x16/0x60 [sunrpc]
Jan 27 20:49:23 soda kernel:  [<f89cb206>] __rpc_execute+0x76/0x3b0 [sunrpc]
Jan 27 20:49:23 soda kernel:  [<c0140e20>] autoremove_wake_function+0x0/0x50
Jan 27 20:49:23 soda last message repeated 2 times
Jan 27 20:49:23 soda kernel:  [<f89c4a77>] rpc_call_sync+0x87/0xa0 [sunrpc]
Jan 27 20:49:23 soda kernel:  [<f8b304b3>] nlmclnt_call+0xa3/0x210 [lockd]
Jan 27 20:49:23 soda kernel:  [<f8b3099c>] nlmclnt_lock+0x3c/0xd0 [lockd]
Jan 27 20:49:23 soda kernel:  [<f8b2fe2c>] nlmclnt_proc+0x26c/0x700 [lockd]
Jan 27 20:49:23 soda kernel:  [<f8a10d0c>] gss_unwrap_resp+0x4c/0x1a0 
[auth_rpcgss]
Jan 27 20:49:23 soda kernel:  [<c0168900>] 
arch_get_unmapped_area_topdown+0x0/0x140
Jan 27 20:49:23 soda kernel:  [<c0168a40>] arch_unmap_area_topdown+0x0/0x10
Jan 27 20:49:23 soda kernel:  [<f8b4be01>] do_setlk+0x111/0x1a0 [nfs]
Jan 27 20:49:23 soda kernel:  [<f8b4bfd0>] nfs_flock+0x0/0xf9 [nfs]
Jan 27 20:49:23 soda kernel:  [<c0198cae>] sys_flock+0x9e/0x180
Jan 27 20:49:23 soda kernel:  [<c010397d>] sysenter_past_esp+0x52/0x75
Jan 27 20:49:23 soda kernel: Code: 8d 74 26 00 c3 0f 0b 2c 01 6c 47 a1 
f8 eb e9 90 8d 74 26 00 83 ec 14 89 5c 24 08 89 7c 24 10 89 d7 89 74 24 
0c 8b 48 20 8d 59 e8 <8b> 53 18 0f 18 02 90 8d 70 20 39 f1 74 23 8d 74 
26 00 8d bc 27



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
