From: Peter Barker <pbarker@barker.dropbear.id.au>
Subject: kernel BUG at fs/nfs/namespace.c:108
Date: Tue, 12 Jun 2007 17:12:32 +1000 (EST)
Message-ID: <Pine.LNX.4.64.0706121655250.1149@milligan.fith.priv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hy0YQ-0004Rs-6g
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 00:12:45 -0700
Received: from scorpion.mycomport.com ([202.51.175.20])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hy0YS-0002yS-Rv
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 00:12:41 -0700
Received: from milligan.fith.priv (202-161-0-219.dyn.iinet.net.au
	[202.161.0.219])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "smtp.fith.priv", Issuer "aphid relay signer" (verified OK))
	by scorpion.mycomport.com (Postfix) with ESMTP id B75E410AC018
	for <nfs@lists.sourceforge.net>; Tue, 12 Jun 2007 17:12:24 +1000 (EST)
Received: from localhost (localhost [127.0.0.1])
	by milligan.fith.priv (Postfix) with ESMTP id E1D5422
	for <nfs@lists.sourceforge.net>; Tue, 12 Jun 2007 17:12:32 +1000 (EST)
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

I'm playing with nfs4.

Linux lynx 2.6.22-rc4 #4 Tue Jun 12 12:41:27 EST 2007 i686 GNU/Linux
I /believe/ this is mainline 99f9f3d49cbc7d944476f6fde53a77ec789ab2aa

A brief look at the code seems to indicate the following BUG() output 
isn't going to be terribly useful without some description of how I've 
managed to get the system into the state I have... I'll have a go at 
reproducing the state later, but I'll also include a brief description of 
what I've been up to after the BUG output.

--
kernel BUG at fs/nfs/namespace.c:108!
invalid opcode: 0000 [#5]
Modules linked in: nfs nfsd exportfs lockd sunrpc apm md_mod af_packet 
snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event 
snd_seq_midi_emul snd_emu10k1 snd_rawmidi firmware_class snd_ac97_codec 
ac97_bus snd_pcm floppy 8139cp 8139too snd_page_alloc snd_util_mem 
snd_hwdep
CPU:    0
EIP:    0060:[<d0abdf3e>]    Not tainted VLI
EFLAGS: 00010246   (2.6.22-rc4 #4)
EIP is at nfs_follow_mountpoint+0x37/0x339 [nfs]
eax: ced42c00   ebx: cce3f154   ecx: d0acfa60   edx: c660bf40
esi: c660bf40   edi: cc58a128   ebp: ce7309c0   esp: c660bce8
ds: 007b   es: 007b   fs: 0000  gs: 0033  ss: 0068
Process umount (pid: 26513, ti=c660a000 task=cff87590 task.ti=c660a000)
Stack: c159fcd0 c015fa16 00000001 00000001 0000000b ce3980d0 0000000b 
c017c321
        00000000 c660bdb0 c8c50360 c0183568 00001000 c660bddc c6ab8668 
0000000b
        cf8e5c00 00000000 00000002 00000001 00000001 00000002 00000002 
c126c718
Call Trace:
  [<c015fa16>] ll_rw_block+0x7a/0x89
  [<c017c321>] ext3_find_entry+0x561/0x585
  [<c0183568>] __journal_file_buffer+0xe2/0x1c5
  [<c01817ba>] __ext3_journal_dirty_metadata+0x16/0x3a
  [<c01838c8>] journal_stop+0x185/0x191
  [<c0177816>] ext3_mark_inode_dirty+0x20/0x27
  [<c0154b30>] d_splice_alias+0x83/0x89
  [<c017d734>] ext3_lookup+0xa0/0xcc
  [<c01546c9>] d_alloc+0x1d/0x178
  [<c014c7b3>] do_lookup+0x4f/0x140
  [<c015449c>] __d_lookup+0x8b/0xbf
  [<c0153a5e>] dput+0x15/0xcb
  [<c014c723>] __follow_mount+0x1e/0x5f
  [<c014c7b3>] do_lookup+0x4f/0x140
  [<c014de2f>] __link_path_walk+0x723/0xa01
  [<c01571eb>] mntput_no_expire+0x11/0x47
  [<c014e1b2>] link_path_walk+0xa5/0xaf
  [<c014e14f>] link_path_walk+0x42/0xaf
  [<c014990c>] sys_stat64+0xf/0x23
  [<c010e335>] do_page_fault+0x272/0x515
  [<c013c1a9>] do_munmap+0x19d/0x1b6
  [<c014e3f0>] do_path_lookup+0x131/0x14c
  [<c014d498>] getname+0x59/0x8f
  [<c014eba7>] __user_walk_fd+0x2f/0x45
  [<c014ecfe>] __user_walk+0x14/0x16
  [<c01575ea>] sys_umount+0x1d/0x1a4
  [<c014990c>] sys_stat64+0xf/0x23
  [<c010e335>] do_page_fault+0x272/0x515
  [<c013c1a9>] do_munmap+0x19d/0x1b6
  [<c0157788>] sys_oldumount+0x17/0x1a
  [<c0102276>] sysenter_past_esp+0x5f/0x85
  =======================
Code: 00 00 8b 40 08 f6 05 2c 92 a1 d0 01 8b 80 88 00 00 00 8b a8 48 01 00 
00 74 0c c7 04 24 64 2a ad d0 e8 bc 47 65 ef 3b 5b 14 75 04 <0f> 0b eb fe 
f6 05 2c 92 a1 d0 01 74 14 c7 44 24 04 14 fb ac d0
EIP: [<d0abdf3e>] nfs_follow_mountpoint+0x37/0x339 [nfs] SS:ESP 
0068:c660bce8
-------

The server looks like this:
pbarker@milligan:~$ cat /etc/fstab | tail -2
# extra stuff for the nfs mounts:
/mnt/raid/media /srv/nfs/media  none    rw,bind 0       0
pbarker@milligan:~$ /usr/sbin/exportfs | grep srv
/srv/nfs/media  10.17.1.36/255.255.255.255
/srv/nfs        10.17.1.36/255.255.255.255
/srv/nfs        10.17.1.0/255.255.255.0
pbarker@milligan:~$
pbarker@milligan:~$ ls /srv/nfs
media/
pbarker@milligan:~$ ls /srv/nfs/media
anim/            mp3s-other/                ogg-david/    tulip.wrl
...

The client mounted the server with:
sudo mount milligan:/ /mnt/spare2 -tnfs4
peterlocal@lynx:/mnt$ sudo mount | grep milligan
milligan:/ on /mnt/spare2 type nfs4 (rw,addr=10.17.1.34)

Now.  I was having problems (as yet unsolved) where the bind-mount wasn't 
appearing on the client, which should be fixed with "nohide" or 
"crossmnt".  There was a lot of mounting and umounting going on, and after 
one particular change on the server, the "mount" command seemed to hang. 
I Ctrl-C'd that mount, it seemed to have failed cleanly and not done 
anything.  I tried mounting the remote filing system again, and it seemed 
to succeed after some time.  At this point, "ls" on the mountpoint is 
sufficient to BUG():
peterlocal@lynx:/mnt$ ls spare2
Segmentation fault
peterlocal@lynx:/mnt$ sudo umount spare2
Segmentation fault

Yours,
-- 
Peter Barker                          |   N    _--_|\ /---- Barham, Vic
Programmer,Sysadmin,Geek              | W + E /     /\
pbarker@barker.dropbear.id.au         |   S   \_,--?_*<-- Canberra
You need a bigger hammer.             |             v    [35S, 149E]
"Peter is apathetic, and I'm vaguely apathetic" -- Rachel, thinking of organising a movie trip

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
