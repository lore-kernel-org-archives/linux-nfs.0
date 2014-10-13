Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fisica.ufpr.br ([200.17.209.129]:51875 "EHLO fisica.ufpr.br"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554AbaJMXua (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Oct 2014 19:50:30 -0400
Date: Mon, 13 Oct 2014 20:50:27 -0300
From: Carlos Carvalho <carlos@fisica.ufpr.br>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: massive memory leak in 3.1[3-5] with nfs4+kerberos
Message-ID: <20141013235026.GA10153@fisica.ufpr.br>
References: <20141011033627.GA6850@fisica.ufpr.br>
 <20141013135840.GA32584@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141013135840.GA32584@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields (bfields@fieldses.org) wrote on Mon, Oct 13, 2014 at 10:58:40AM BRT:
> On Sat, Oct 11, 2014 at 12:36:27AM -0300, Carlos Carvalho wrote:
> > We're observing a big memory leak in 3.1[3-5]. We've gone until 3.15.8 and back
> > to 3.14 because of LTS. Today we're running 3.14.21. The problem has existed
> > for several months but recently has become a show-stopper.
> 
> Is there an older version that you know was OK?

Perhaps something as old as 3.8 but I'm not sure if it still worked. We jumped
from 3.8 to 3.13 and this one certainly leaks.

> > Here are the values of SUnreclaim: from /proc/meminfo, sampled at every 4h
> > (units are kB):
[TRIMMED]
> > 28034980
> > 29059812  <== almost 30GB!
> 
> Can you figure out from /proc/slabinfo which slab is the problem?

I don't understand it precisely but here's what slabtop says:

urquell# slabtop -o -sc
 Active / Total Objects (% used)    : 62466073 / 63672277 (98.1%)
 Active / Total Slabs (% used)      : 1903762 / 1903762 (100.0%)
 Active / Total Caches (% used)     : 122 / 140 (87.1%)
 Active / Total Size (% used)       : 31965140.38K / 32265879.49K (99.1%)
 Minimum / Average / Maximum Object : 0.08K / 0.51K / 8.07K

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                   
13782656 13745696  99%    1.00K 430708       32  13782656K ext4_inode_cache
3374235 3374199  99%    2.07K 224949       15   7198368K kmalloc-2048
6750996 6750937  99%    0.57K 241107       28   3857712K kmalloc-512
9438787 9121010  96%    0.26K 304477       31   2435816K dentry
11455656 11444417  99%    0.17K 249036       46   1992288K buffer_head
161378 161367  99%    4.07K  23054        7    737728K kmalloc-4096
6924380 6924248  99%    0.09K 150530       46    602120K kmalloc-16
6754644 6754432  99%    0.08K 132444       51    529776K kmalloc-8
662286 648372  97%    0.62K  12986       51    415552K radix_tree_node
161730 161709  99%    1.69K   8985       18    287520K TCP
1987470 1840303  92%    0.13K  66249       30    264996K kmalloc-64
203366 162439  79%    0.69K   4421       46    141472K sock_inode_cache
626112 285190  45%    0.11K  17392       36     69568K ext4_extent_status
177123 177040  99%    0.31K   3473       51     55568K skbuff_head_cache
357272 357220  99%    0.12K  10508       34     42032K jbd2_inode
136422 136375  99%    0.20K   3498       39     27984K ext4_groupinfo_4k

Note that ext4* appears to be the vilain but it's not because
echo 3>/proc/sys/vm/drop_caches
gets rid of it. The problem seems to be the kmalloc-*, particularly
kmalloc-2048, which never gets smaller.

Maybe this gives you a clue:

urquell# ./slabinfo -r kmalloc-2048

Slabcache: kmalloc-2048          Aliases:  0 Order :  3 Objects: 3379188

Sizes (bytes)     Slabs              Debug                Memory
------------------------------------------------------------------------
Object :    2048  Total  :  225282   Sanity Checks : On   Total: 7382040576
SlabObj:    2120  Full   :  225277   Redzoning     : On   Used : 6920577024
SlabSiz:   32768  Partial:       5   Poisoning     : On   Loss : 461463552
Loss   :      72  CpuSlab:       0   Tracking      : On   Lalig: 243301536
Align  :       8  Objects:      15   Tracing       : Off  Lpadd: 218072976

kmalloc-2048 has no kmem_cache operations

kmalloc-2048: Kernel object allocation
-----------------------------------------------------------------------
      1 mcheck_cpu_init+0x2dd/0x4b0 age=71315213 pid=0 cpus=0 nodes=0
      4 mempool_create_node+0x67/0x130 age=71310870/71310884/71310896 pid=845 cpus=8,10 nodes=1
      1 pcpu_extend_area_map+0x36/0xf0 age=71314878 pid=1 cpus=10 nodes=1
      1 __vmalloc_node_range+0xb1/0x250 age=71314877 pid=1 cpus=10 nodes=1
      7 alloc_fdmem+0x17/0x30 age=19467/40818077/71308204 pid=5541-16287 cpus=0-1,4,6-7 nodes=0
      2 __register_sysctl_table+0x52/0x540 age=71315213/71315213/71315213 pid=0 cpus=0 nodes=0
      1 register_leaf_sysctl_tables+0x7f/0x1f0 age=71315213 pid=0 cpus=0 nodes=0
      1 ext4_kvmalloc+0x1e/0x60 age=71310060 pid=2778 cpus=0 nodes=0
      2 ext4_kvzalloc+0x1e/0x70 age=71310041/71310197/71310354 pid=2778 cpus=4,9 nodes=0-1
      4 ext4_fill_super+0x9e/0x2d50 age=71310064/71310406/71310853 pid=987-2778 cpus=0,9-10 nodes=0-1
      4 journal_init_common+0x12/0x150 age=71310051/71310386/71310852 pid=987-2778 cpus=0,8-9 nodes=0-1
     50 create_client.isra.79+0x6d/0x450 age=56450/25384654/71293503 pid=5372-5435 cpus=0-17,19-21,23 nodes=0-1
   1550 nfsd4_create_session+0x24a/0x810 age=56450/25266733/71293502 pid=5372-5436 cpus=0-11,13-16,19-20,27 nodes=0-1
    136 pci_alloc_dev+0x22/0x60 age=71314711/71314783/71314907 pid=1 cpus=0 nodes=0-1
      1 acpi_ev_create_gpe_block+0x110/0x323 age=71315026 pid=1 cpus=0 nodes=0
      2 tty_write+0x1f9/0x290 age=11025/35647516/71284008 pid=5965-16318 cpus=5-6 nodes=0
      2 kobj_map_init+0x20/0xa0 age=71315078/71315145/71315213 pid=0-1 cpus=0 nodes=0
      7 scsi_host_alloc+0x30/0x410 age=71312864/71313119/71314655 pid=4 cpus=0 nodes=0
     52 scsi_alloc_sdev+0x52/0x290 age=71311100/71311851/71314235 pid=6-289 cpus=0-1,3,8 nodes=0-1
     50 _scsih_slave_alloc+0x36/0x1f0 age=71311100/71311758/71312386 pid=7-289 cpus=0,8 nodes=0-1
      1 ata_attach_transport+0x12/0x550 age=71314887 pid=1 cpus=10 nodes=1
      2 usb_create_shared_hcd+0x3d/0x1b0 age=71312498/71312500/71312502 pid=4 cpus=0 nodes=0
      2 input_alloc_absinfo+0x1f/0x50 age=71312135/71312157/71312180 pid=175 cpus=0 nodes=0
     18 sk_prot_alloc.isra.51+0xab/0x180 age=71307028/71307092/71307162 pid=5268 cpus=0-2 nodes=0
     12 reqsk_queue_alloc+0x5b/0xf0 age=71308217/71308264/71308326 pid=5281-5531 cpus=0,7 nodes=0
      9 __alloc_skb+0x82/0x2a0 age=11/62981/85980 pid=16286-28415 cpus=0,2,12,20 nodes=0-1
     19 alloc_netdev_mqs+0x5d/0x380 age=71309462/71309950/71314887 pid=1-4109 cpus=1,9-10 nodes=0-1
     48 neigh_sysctl_register+0x39/0x270 age=71309462/71310133/71314878 pid=1-4109 cpus=1-3,5-6,9-10,18 nodes=0-1
      2 neigh_hash_alloc+0x9d/0xb0 age=71122283/71208056/71293830 pid=4732-5411 cpus=0,12 nodes=0-1
      4 __rtnl_register+0x9e/0xd0 age=71312234/71314317/71315079 pid=1 cpus=0,2,10 nodes=0-1
      2 nf_ct_l4proto_register+0x96/0x140 age=71312233/71312234/71312235 pid=1 cpus=2 nodes=0
     25 __devinet_sysctl_register+0x39/0xf0 age=71309462/71310428/71314878 pid=1-4109 cpus=1,3,5-6,9-10,18 nodes=0-1
3377159 xprt_alloc+0x1e/0x190 age=0/27663979/71308304 pid=6-32599 cpus=0-31 nodes=0-1
      6 cache_create_net+0x32/0x80 age=71314835/71314848/71314876 pid=1 cpus=8,10 nodes=1
      1 uncore_types_init+0x33/0x1a5 age=71314842 pid=1 cpus=31 nodes=1
      2 netdev_create_hash+0x12/0x30 age=71314887/71314887/71314887 pid=1 cpus=10 nodes=1

kmalloc-2048: Kernel object freeing
------------------------------------------------------------------------
1236114 <not-available> age=4366207748 pid=0 cpus=0 nodes=0-1
      1 pcpu_extend_area_map+0x79/0xf0 age=71312606 pid=281 cpus=0 nodes=0
  13387 do_readv_writev+0x10f/0x2b0 age=11019/32837523/71273914 pid=5372-5436 cpus=0-31 nodes=0-1
    181 __free_fdtable+0xd/0x20 age=64631/41719568/71310089 pid=632-32741 cpus=0-26,28-29,31 nodes=0-1
  25068 free_session+0x113/0x140 age=65100/41914089/71277241 pid=6-32564 cpus=0-9,11-23,25-31 nodes=0-1
   1008 destroy_client+0x34b/0x3f0 age=88408/41955492/71233598 pid=6-32564 cpus=0-9,13-23,25-26,28-31 nodes=0-1
   5568 nfsd4_create_session+0x567/0x810 age=56743/41522683/71293808 pid=5372-5436 cpus=0-28,30 nodes=0-1
      5 acpi_pci_irq_find_prt_entry+0x253/0x26d age=71312722/71313708/71315113 pid=1-4 cpus=0,10 nodes=0-1
      1 free_tty_struct+0x23/0x40 age=68221685 pid=933 cpus=3 nodes=0
     14 flush_to_ldisc+0x86/0x170 age=2758222/47649639/71281276 pid=254-12135 cpus=0,2,9-10,12,15-17,25 nodes=0-1
2094711 __kfree_skb+0x9/0xa0 age=48/27035171/71311197 pid=0-32767 cpus=0-31 nodes=0-1
      1 pskb_expand_head+0x150/0x220 age=71315138 pid=1 cpus=10 nodes=1
      6 xt_free_table_info+0x4e/0x130 age=71308862/71308863/71308864 pid=5003-5005 cpus=25,29-30 nodes=0
      3 inetdev_event+0x36d/0x4e0 age=71310679/71310692/71310703 pid=1160-1199 cpus=5-6,18 nodes=0
      5 inetdev_event+0x37a/0x4e0 age=71310679/71310715/71310749 pid=1160-1199 cpus=3,5,18-19 nodes=0
   3155 unix_stream_sendmsg+0x39c/0x3b0 age=31207/33532093/71308550 pid=398-32756 cpus=0-31 nodes=0-1
      4 addrconf_notify+0x1b1/0x770 age=71310703/71310724/71310749 pid=1160-1199 cpus=3,5,18-19 nodes=0

NUMA nodes           :    0    1
--------------------------------
All slabs              118.1K 107.1K
Partial slabs             1    4

Note the big xprt_alloc. slabinfo is found in the kernel tree at tools/vm.
Another way to see it:

urquell# sort -n /sys/kernel/slab/kmalloc-2048/alloc_calls | tail -n 2
   1519 nfsd4_create_session+0x24a/0x810 age=189221/25894524/71426273 pid=5372-5436 cpus=0-11,13-16,19-20 nodes=0-1
3380755 xprt_alloc+0x1e/0x190 age=5/27767270/71441075 pid=6-32599 cpus=0-31 nodes=0-1

Yet another puzzling thing for us is that the number of allocs and frees is
nearly equal:

urquell# awk '{summ += $1} END {print summ}' /sys/kernel/slab/kmalloc-2048/alloc_calls
3385122
urquell# awk '{summ += $1} END {print summ}' /sys/kernel/slab/kmalloc-2048/free_calls
3385273

> It would also be interesting to know whether the problem is with nfs4 or
> krb5.  But I don't know if you have an easy way to test that.  (E.g.
> temporarily downgrade to nfs3 while keeping krb5 and see if that
> matters?)

That'd be quite hard to do...

> Do you know if any of your clients are using NFSv4.1?

All of them. Clients are a few general login servers and about a hundred
terminals. All of them are diskless and mount their root via nfs3 without
kerberos. The login servers mount the user home dirs with nfs4.1 WITHOUT
kerberos. The terminals run ubuntu and mount with nfs4.1 AND kerberos. Here is
their /proc/version:

Linux version 3.14.14-kernel (root@urquell) (gcc version 4.8.2 (Ubuntu 4.8.2-19ubuntu1) ) #15 SMP Thu Jul 31 11:15:52 BRT 2014

and here their mount:

urquell.home:/home on /home type nfs4(rw,vers=4.1,addr=10.17.110.3,clientaddr=10.17.110.11)

> What filesystem are you exporting, with what options?

ext4. For the terminals:
/exports        10.254.0.0/16(sec=krb5p:none,ro,async,fsid=0,crossmnt,subtree_check,no_root_squash)
/exports/home   10.254.0.0/16(sec=krb5p,rw,async,no_subtree_check,root_squash)

For the servers:
/exports/home   server.home(rw,async,root_squash,no_subtree_check)

> > What about these patches: http://permalink.gmane.org/gmane.linux.nfs/62012
> > Bruce said they were accepted but they're not in 3.14. Were they rejected or
> > forgotten? Could they have any relation to this memory leak?
> 
> Those are in 3.15.
> 
> There'd be no harm in trying them, but on a quick skim I don't think
> they're likely to explain your symptoms.

Yes, we tried until 3.15.8 to no avail.
