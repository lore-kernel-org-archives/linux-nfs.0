Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:45314 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750975AbcFJQt2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2016 12:49:28 -0400
Subject: Re: NFS/d_splice_alias breakage
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=utf-8
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <0413AB81-9BA5-41CF-B736-3F7B8909897B@linuxhacker.ru>
Date: Fri, 10 Jun 2016 12:49:16 -0400
Cc: linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Message-Id: <7F30331A-6283-4061-AB58-7E246C8F85A0@linuxhacker.ru>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru> <20160603033750.GL14480@ZenIV.linux.org.uk> <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru> <20160603042648.GN14480@ZenIV.linux.org.uk> <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru> <20160603055655.GQ14480@ZenIV.linux.org.uk> <18266C54-EE2D-4E79-9216-77D1B17A1B85@linuxhacker.ru> <0413AB81-9BA5-41CF-B736-3F7B8909897B@linuxhacker.ru>
To: Al Viro <viro@ZenIV.linux.org.uk>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 9, 2016, at 9:33 PM, Oleg Drokin wrote:

> 
> On Jun 6, 2016, at 7:36 PM, Oleg Drokin wrote:
> 
>> Well, I have some bad news.
>> 
>> This patch does not fix the issue 100% of the time apparently, I just hit it again.
> 
> Ok, so now finally a piece of good news.
> Whatever was causing this other much harder to hit crash is gone in -rc2, gone are
> some other disturbing things I saw.

Famous last words, I guess.
It all returned overnight.

But this time it's different from the past couple.

0xffffffff813aa8bb is in nfs4_do_open (/home/green/bk/linux/fs/nfs/nfs4proc.c:2482).
2477                    d_drop(dentry);
2478                    alias = d_exact_alias(dentry, state->inode);
2479                    if (!alias)
2480                            alias = d_splice_alias(igrab(state->inode), dentry);
2481                    /* d_splice_alias() can't fail here - it's a non-directory */

So it appears the dentry that was negative turned positive in the middle of
d_exact_alias call… and also despite us doing d_drop(dentry), it's also already
hashed?
If this can happen in the middle of our operations here, same thing
presumably can happen in the other place we patched up in nfs_atomic_open - 
we do d_drop there, but by the time we get into d_splice_alias it's now
all hashed again by some racing thread, that would explain
some of the rarer earlier crashes I had in -rc1 after the initial fix.

I wonder if it could be a remote-fs specific open vs open race?

Say we have atomic open for parent1/file1, this locks parent1 and proceeds to lookup
file1.
Now before the lookup commences, some other thread moves file1 to parent2
and yet some other thread goes to open parent2/file1.
Eventually it all converges with two threads trying to instantiate file1,
if we get it "just wrong" then a clash like what we see can happen, no?
Hm, I guess then both opens would have their own dentry and it's only inode that's
shared, so that cannot be it.
How can anything find a dentry we presumably just allocated and hash it while we
are not done with it, I wonder?
Also I wonder if all of this is somehow related to this other problem I am having
where drop_nlink reports going into negative territory on rename() call, I hit this
twice already and I guess I just need to convert that to BUG_ON instead for a
closer examination.


The dentry is (I finally have a crashdump):

crash> p *(struct dentry *)0xffff880055dbd2e8
$4 = {
  d_flags = 4718796, 
  d_seq = {
    sequence = 4, 
    dep_map = {
      key = 0xffffffff8337b1c0 <__key.41115>, 
      class_cache = {0x0, 0x0}, 
      name = 0xffffffff81c79c66 "&dentry->d_seq", 
      cpu = 6, 
      ip = 6510615555426900570
    }
  }, 
  d_hash = {
    next = 0x0, 
    pprev = 0xffffc900000fd9c0
  }, 
  d_parent = 0xffff8800079d1008, 
  d_name = {
    {
      {
        hash = 2223188567, 
        len = 2
      }, 
      hash_len = 10813123159
    }, 
    name = 0xffff880055dbd358 "10"
  }, 
  d_inode = 0xffff880066d8ab38, 
  d_iname = "10\000ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ", 
  d_lockref = {
    {
      {
        lock = {
          {
            rlock = {
              raw_lock = {
                val = {
                  counter = 0
                }
              }, 
              magic = 3735899821, 
              owner_cpu = 4294967295, 
              owner = 0xffffffffffffffff, 
              dep_map = {
                key = 0xffffffff8337b1c8 <__key.41114>, 
                class_cache = {0xffffffff82c1c3a0 <lock_classes+47616>, 0x0}, 
                name = 0xffffffff81c65bc8 "&(&dentry->d_lockref.lock)->rlock", 
                cpu = 3, 
                ip = 18446744071583760701
              }
            }, 
            {
              __padding = "\000\000\000\000╜N╜чЪЪЪЪZZZZЪЪЪЪЪЪЪЪ", 
              dep_map = {
                key = 0xffffffff8337b1c8 <__key.41114>, 
                class_cache = {0xffffffff82c1c3a0 <lock_classes+47616>, 0x0}, 
                name = 0xffffffff81c65bc8 "&(&dentry->d_lockref.lock)->rlock", 
                cpu = 3, 
                ip = 18446744071583760701
              }
            }
          }
        }, 
        count = 3
      }
    }
  }, 
  d_op = 0xffffffff81a46780 <nfs4_dentry_operations>, 
  d_sb = 0xffff88004eaf3000, 
  d_time = 6510615555426956154, 
  d_fsdata = 0x0, 
  {
    d_lru = {
      next = 0xffff880066d7e3e8, 
      prev = 0xffff8800036736c8
    }, 
    d_wait = 0xffff880066d7e3e8
  }, 
  d_child = {
    next = 0xffff8800268629b8, 
    prev = 0xffff8800079d1128
  }, 
  d_subdirs = {
    next = 0xffff880055dbd408, 
    prev = 0xffff880055dbd408
  }, 
  d_u = {
    d_alias = {
      next = 0x0, 
      pprev = 0xffff880066d8ad20
    }, 
    d_in_lookup_hash = {
      next = 0x0, 
      pprev = 0xffff880066d8ad20
    }, 
    d_rcu = {
      next = 0x0, 
      func = 0xffff880066d8ad20
    }
  }
}

[22845.516232] kernel BUG at /home/green/bk/linux/fs/dcache.c:2989!
[22845.516864] invalid opcode: 0000 [#1] SMP
[22845.517350] Modules linked in: loop rpcsec_gss_krb5 acpi_cpufreq joydev tpm_tis tpm virtio_console i2c_piix4 pcspkr nfsd ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm virtio_blk serio_raw floppy
[22845.519236] CPU: 0 PID: 2894259 Comm: cat Not tainted 4.7.0-rc2-vm-nfs+ #122
[22845.519843] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[22845.520259] task: ffff8800640d8e40 ti: ffff88004665c000 task.ti: ffff88004665c000
[22845.520975] RIP: 0010:[<ffffffff81287811>]  [<ffffffff81287811>] d_splice_alias+0x1e1/0x470
[22845.521746] RSP: 0018:ffff88004665fa08  EFLAGS: 00010286
[22845.522122] RAX: ffff880066d8ab38 RBX: 0000000000000000 RCX: 0000000000000001
[22845.522524] RDX: 000000000000191a RSI: ffff880055dbd2e8 RDI: ffff880066d8ab38
[22845.522926] RBP: ffff88004665fa40 R08: 0000235352190a66 R09: ffff880055dbd2e8
[22845.523328] R10: 0000000000000001 R11: 0000000000000000 R12: ffff880072d43c00
[22845.523731] R13: ffff880072d43c00 R14: ffff88004883a580 R15: ffff880052615800
[22845.524131] FS:  00007f3b2c27d700(0000) GS:ffff88006b400000(0000) knlGS:0000000000000000
[22845.524846] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[22845.525225] CR2: 000055649285c0d0 CR3: 000000004d961000 CR4: 00000000000006f0
[22845.525628] Stack:
[22845.525964]  ffff88004665fa20 ffffffff8188a1f7 0000000000000000 ffff880072d43c00
[22845.526700]  ffff880072d43c00 ffff88004883a580 ffff880052615800 ffff88004665fb20
[22845.527433]  ffffffff813aa8bb ffffffff00000000 ffff8800024000c0 ffff88004665fd80
[22845.528161] Call Trace:
[22845.528504]  [<ffffffff8188a1f7>] ? _raw_spin_unlock+0x27/0x40
[22845.528943]  [<ffffffff813aa8bb>] nfs4_do_open+0xaeb/0xb10
[22845.529331]  [<ffffffff813aa9d0>] nfs4_atomic_open+0xf0/0x110
[22845.529718]  [<ffffffff8137eefc>] nfs_atomic_open+0x1ac/0x700
[22845.530112]  [<ffffffff8127900a>] lookup_open+0x2ea/0x770
[22845.530488]  [<ffffffff8127bee5>] path_openat+0x6e5/0xc20
[22845.530881]  [<ffffffff8104a425>] ? kvm_sched_clock_read+0x25/0x40
[22845.531268]  [<ffffffff8127d981>] do_filp_open+0x91/0x100
[22845.531645]  [<ffffffff8188a1f7>] ? _raw_spin_unlock+0x27/0x40
[22845.532027]  [<ffffffff8128efc0>] ? __alloc_fd+0x100/0x200
[22845.532405]  [<ffffffff81269f80>] do_sys_open+0x130/0x220
[22845.533157]  [<ffffffff8126a08e>] SyS_open+0x1e/0x20

vmcore is at http://knox.linuxhacker.ru/tmp/dentry2/vmcore.gz
vmlinux is at http://knox.linuxhacker.ru/tmp/dentry2/vmlinux.gz

