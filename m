From: William Lee Irwin III <wli@holomorphy.com>
Subject: nfsd oops 2.6.7-rc1
Date: Fri, 28 May 2004 19:35:50 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040529023550.GB2370@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263032AbUE2Cfy@vger.kernel.org>
To: linux-kernel@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

While idle, the following oops happened. On virgin 2.6.7-rc1.


-- wli

 ------------[ cut here ]------------
 kernel BUG at include/linux/dcache.h:276!
 invalid operand: 0000 [#1]
 Modules linked in:
 CPU:    0
 EIP:    0060:[<c01e1de1>]    Not tainted
 EFLAGS: 00010246   (2.6.7-rc1-holomorphy-1) 
 EIP is at fh_compose+0x3d1/0x430
 eax: 00000000   ebx: 00800070   ecx: effe8d14   edx: 00000020
 esi: e29bf800   edi: 00000000   ebp: ddc24f58   esp: e29b3eb0
 ds: 007b   es: 007b   ss: 0068
 Process nfsd (pid: 1335, threadinfo=e29b3000 task=e29c0410)
 Stack: 00000000 edd2444c c014b66f e29b3ed4 e432c0c0 8191bdfa ddc24b4c ddc24b4c 
        eca73d0c 0100bdfa effe8d14 0000001a ddc24f58 ddc24f58 e29ce000 e432c0a6 
        c01e247b e29ce000 00000001 effe7314 c0419bee ddc24b4c e2a23000 effe8d14 
 Call Trace:
  [<c014b66f>] __lookup_hash+0x5f/0xb0
  [<c01e247b>] nfsd_lookup+0x12b/0x420
  [<c0419bee>] svcauth_unix_accept+0x23e/0x280
  [<c01e0513>] nfsd_proc_lookup+0x53/0xa0
  [<c01e82c4>] nfssvc_decode_diropargs+0x54/0xb0
  [<c01e8270>] nfssvc_decode_diropargs+0x0/0xb0
  [<c01dfb36>] nfsd_dispatch+0xb6/0x1c0
  [<c0416523>] svc_process+0x463/0x5c0
  [<c01df92f>] nfsd+0x16f/0x2c0
  [<c01df7c0>] nfsd+0x0/0x2c0
  [<c0103a7d>] kernel_thread_helper+0x5/0x18
 
 Code: 0f 0b 14 01 ba 29 44 c0 e9 99 fd ff ff 8b 45 18 8b 4c 24 1c 
