Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:42598 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755442Ab1HKAgL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 20:36:11 -0400
In-Reply-To: <20110810122304.96b8be67.rdunlap@xenotime.net>
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com>
 <20110810122304.96b8be67.rdunlap@xenotime.net>
From: Peng Tao <bergwolf@gmail.com>
Date: Thu, 11 Aug 2011 08:35:50 +0800
Message-ID: <CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com>
Subject: Re: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-raid@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 11, 2011 at 3:23 AM, Randy Dunlap <rdunlap@xenotime.net> wrote:
> When CONFIG_BLOCK is not enabled (x86_64):
>
> warning: (NFS_V4_1) selects MD which has unmet direct dependencies (BLOCK)
MD depends on BLOCK but when MD is selected, it will not select BLOCK.
Selecting BLOCK at NFS_V4_1 can solve this but it's like resolving
dependency from top down.

Is MD designed to not be selected from the first place? If not, can we
change it to selecting BLOCK?

Thanks,
Tao

>
> and these build errors:
>
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_submit_bio':
> fs/nfs/blocklayout/blocklayout.c:132: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:133: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:133: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:136: error: implicit declaration of function 'submit_bio'
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_alloc_init_bio':
> fs/nfs/blocklayout/blocklayout.c:148: error: implicit declaration of function 'bio_alloc'
> fs/nfs/blocklayout/blocklayout.c:148: warning: assignment makes pointer from integer without a cast
> fs/nfs/blocklayout/blocklayout.c:152: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:153: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:154: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:155: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_add_page_to_bio':
> fs/nfs/blocklayout/blocklayout.c:171: error: implicit declaration of function 'bio_add_page'
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_read':
> fs/nfs/blocklayout/blocklayout.c:192: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:193: error: 'BIO_UPTODATE' undeclared (first use in this function)
> fs/nfs/blocklayout/blocklayout.c:193: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:193: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:194: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:194: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:198: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:200: error: decrement of pointer to unknown structure
> fs/nfs/blocklayout/blocklayout.c:200: error: arithmetic on pointer to an incomplete type
> fs/nfs/blocklayout/blocklayout.c:200: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:201: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:204: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:210: error: implicit declaration of function 'bio_put'
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_write_zero':
> fs/nfs/blocklayout/blocklayout.c:355: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:356: error: 'BIO_UPTODATE' undeclared (first use in this function)
> fs/nfs/blocklayout/blocklayout.c:356: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:356: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:357: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:357: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:361: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:363: error: decrement of pointer to unknown structure
> fs/nfs/blocklayout/blocklayout.c:363: error: arithmetic on pointer to an incomplete type
> fs/nfs/blocklayout/blocklayout.c:363: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:364: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:368: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'bl_end_io_write':
> fs/nfs/blocklayout/blocklayout.c:381: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:382: error: 'BIO_UPTODATE' undeclared (first use in this function)
> fs/nfs/blocklayout/blocklayout.c:382: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:382: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'map_block':
> fs/nfs/blocklayout/blocklayout.c:440: error: implicit declaration of function 'set_buffer_mapped'
> fs/nfs/blocklayout/blocklayout.c:441: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:442: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:445: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c:445: error: dereferencing pointer to incomplete type
> fs/nfs/blocklayout/blocklayout.c: In function 'init_page_for_write':
> fs/nfs/blocklayout/blocklayout.c:469: error: implicit declaration of function 'alloc_page_buffers'
> fs/nfs/blocklayout/blocklayout.c:469: warning: assignment makes pointer from integer without a cast
> fs/nfs/blocklayout/blocklayout.c:477: error: implicit declaration of function 'bh_uptodate_or_lock'
> fs/nfs/blocklayout/blocklayout.c:478: error: implicit declaration of function 'bh_submit_read'
> fs/nfs/blocklayout/blocklayout.c:486: error: implicit declaration of function 'free_buffer_head'
> make[4]: *** [fs/nfs/blocklayout/blocklayout.o] Error 1
>
> In file included from include/linux/raid/pq.h:20,
>                 from lib/raid6/algos.c:19:
> include/linux/blkdev.h:1346: warning: 'struct task_struct' declared inside parameter list
> include/linux/blkdev.h:1346: warning: its scope is only this definition or declaration, which is probably not what you want
> include/linux/blkdev.h:1350: warning: 'struct task_struct' declared inside parameter list
> include/linux/blkdev.h:1355: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'blk_needs_flush_plug'
> In file included from lib/raid6/algos.c:19:
> include/linux/raid/pq.h:27: error: 'PAGE_SIZE' undeclared here (not in a function)
> include/linux/raid/pq.h:74: error: expected declaration specifiers or '...' before 'size_t'
> include/linux/raid/pq.h:113: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'raid6_gfmul'
> include/linux/raid/pq.h:114: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'raid6_gfexp'
> include/linux/raid/pq.h:115: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'raid6_gfinv'
> include/linux/raid/pq.h:116: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'raid6_gfexi'
> include/linux/raid/pq.h:119: error: expected declaration specifiers or '...' before 'size_t'
> include/linux/raid/pq.h:121: error: expected declaration specifiers or '...' before 'size_t'
> include/linux/raid/pq.h:122: error: expected declaration specifiers or '...' before 'size_t'
> lib/raid6/algos.c: In function 'raid6_select_algo':
> lib/raid6/algos.c:90: error: 'raid6_gfmul' undeclared (first use in this function)
> lib/raid6/algos.c:116: warning: passing argument 2 of '(*algo)->gen_syndrome' makes pointer from integer without a cast
> lib/raid6/algos.c:116: note: expected 'void **' but argument is of type 'long unsigned int'
> lib/raid6/algos.c:116: error: too many arguments to function '(*algo)->gen_syndrome'
> lib/raid6/algos.c: At top level:
> lib/raid6/algos.c:153: error: expected declaration specifiers or '...' before string constant
> lib/raid6/algos.c:153: warning: data definition has no type or storage class
> lib/raid6/algos.c:153: warning: type defaults to 'int' in declaration of 'MODULE_LICENSE'
> lib/raid6/algos.c:153: warning: function declaration isn't a prototype
> lib/raid6/algos.c:154: error: expected declaration specifiers or '...' before string constant
> lib/raid6/algos.c:154: warning: data definition has no type or storage class
> lib/raid6/algos.c:154: warning: type defaults to 'int' in declaration of 'MODULE_DESCRIPTION'
> lib/raid6/algos.c:154: warning: function declaration isn't a prototype
>  CC [M]  drivers/char/applicom.o
> make[3]: *** [lib/raid6/algos.o] Error 1
>
> In file included from drivers/md/linear.c:19:
> include/linux/blkdev.h:1346: warning: 'struct task_struct' declared inside parameter list
> include/linux/blkdev.h:1346: warning: its scope is only this definition or declaration, which is probably not what you want
> include/linux/blkdev.h:1350: warning: 'struct task_struct' declared inside parameter list
> include/linux/blkdev.h:1355: error: expected '=', ',', ';', 'asm' or '__attribute__' before 'blk_needs_flush_plug'
> In file included from drivers/md/linear.c:23:
> drivers/md/md.h: In function 'md_sync_acct':
> drivers/md/md.h:418: error: dereferencing pointer to incomplete type
> drivers/md/md.h: In function 'mdname':
> drivers/md/md.h:484: error: dereferencing pointer to incomplete type
>  CC [M]  net/netfilter/xt_connbytes.o
> In file included from drivers/md/linear.c:24:
> drivers/md/linear.h: At top level:
> drivers/md/linear.h:15: error: field 'rcu' has incomplete type
> drivers/md/linear.c: In function 'which_dev':
> drivers/md/linear.c:36: error: implicit declaration of function 'rcu_dereference'
> drivers/md/linear.c:36: warning: assignment makes pointer from integer without a cast
> drivers/md/linear.c: At top level:
> drivers/md/linear.c:64: warning: 'struct bvec_merge_data' declared inside parameter list
> drivers/md/linear.c: In function 'linear_mergeable_bvec':
> drivers/md/linear.c:66: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:68: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:69: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:69: error: implicit declaration of function 'get_start_sect'
> drivers/md/linear.c:69: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:71: error: implicit declaration of function 'rcu_read_lock'
> drivers/md/linear.c:74: error: implicit declaration of function 'rcu_read_unlock'
> drivers/md/linear.c:82: error: dereferencing pointer to incomplete type
> drivers/md/linear.c: In function 'linear_congested':
> drivers/md/linear.c:100: warning: assignment makes pointer from integer without a cast
> drivers/md/linear.c:103: error: implicit declaration of function 'bdev_get_queue'
> drivers/md/linear.c:103: warning: initialization makes pointer from integer without a cast
> drivers/md/linear.c:104: error: implicit declaration of function 'bdi_congested'
> drivers/md/linear.c:104: error: dereferencing pointer to incomplete type
> drivers/md/linear.c: In function 'linear_size':
> drivers/md/linear.c:117: warning: assignment makes pointer from integer without a cast
> drivers/md/linear.c: In function 'linear_conf':
> drivers/md/linear.c:158: error: implicit declaration of function 'disk_stack_limits'
> drivers/md/linear.c:164: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:165: error: implicit declaration of function 'blk_queue_max_segments'
> drivers/md/linear.c:166: error: implicit declaration of function 'blk_queue_segment_boundary'
> drivers/md/linear.c:167: error: 'PAGE_CACHE_SIZE' undeclared (first use in this function)
> drivers/md/linear.c: In function 'linear_run':
> drivers/md/linear.c:210: error: implicit declaration of function 'blk_queue_merge_bvec'
> drivers/md/linear.c:211: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:212: error: dereferencing pointer to incomplete type
> drivers/md/linear.c: In function 'linear_add':
> drivers/md/linear.c:238: warning: assignment makes pointer from integer without a cast
> drivers/md/linear.c:240: error: implicit declaration of function 'rcu_assign_pointer'
> drivers/md/linear.c:242: error: implicit declaration of function 'set_capacity'
> drivers/md/linear.c:243: error: implicit declaration of function 'revalidate_disk'
> drivers/md/linear.c:244: error: implicit declaration of function 'kfree_rcu'
> drivers/md/linear.c:244: error: 'rcu' undeclared (first use in this function)
> drivers/md/linear.c: In function 'linear_stop':
> drivers/md/linear.c:259: error: implicit declaration of function 'rcu_barrier'
> drivers/md/linear.c:260: error: implicit declaration of function 'blk_sync_queue'
> drivers/md/linear.c: In function 'linear_make_request':
> drivers/md/linear.c:272: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:272: error: 'REQ_FLUSH' undeclared (first use in this function)
> drivers/md/linear.c:278: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:282: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:282: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:284: error: 'BDEVNAME_SIZE' undeclared (first use in this function)
> drivers/md/linear.c:290: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:291: error: implicit declaration of function 'bdevname'
> drivers/md/linear.c:293: warning: format '%s' expects type 'char *', but argument 4 has type 'int'
> drivers/md/linear.c:295: error: implicit declaration of function 'bio_io_error'
> drivers/md/linear.c:284: warning: unused variable 'b'
> drivers/md/linear.c:298: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:298: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:308: error: implicit declaration of function 'bio_split'
> drivers/md/linear.c:308: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:308: warning: assignment makes pointer from integer without a cast
> drivers/md/linear.c:310: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:311: error: implicit declaration of function 'generic_make_request'
> drivers/md/linear.c:311: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:312: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:313: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:314: error: implicit declaration of function 'bio_pair_release'
> drivers/md/linear.c:318: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:319: error: dereferencing pointer to incomplete type
> drivers/md/linear.c:319: error: dereferencing pointer to incomplete type
> drivers/md/linear.c: At top level:
> drivers/md/linear.c:337: error: 'THIS_MODULE' undeclared here (not in a function)
> drivers/md/linear.c:359: error: expected declaration specifiers or '...' before string constant
> drivers/md/linear.c:359: warning: data definition has no type or storage class
> drivers/md/linear.c:359: warning: type defaults to 'int' in declaration of 'MODULE_LICENSE'
> drivers/md/linear.c:359: warning: function declaration isn't a prototype
> drivers/md/linear.c:360: error: expected declaration specifiers or '...' before string constant
> drivers/md/linear.c:360: warning: data definition has no type or storage class
> drivers/md/linear.c:360: warning: type defaults to 'int' in declaration of 'MODULE_DESCRIPTION'
> drivers/md/linear.c:360: warning: function declaration isn't a prototype
> drivers/md/linear.c:361: error: expected declaration specifiers or '...' before string constant
> drivers/md/linear.c:361: warning: data definition has no type or storage class
> drivers/md/linear.c:361: warning: type defaults to 'int' in declaration of 'MODULE_ALIAS'
> drivers/md/linear.c:361: warning: function declaration isn't a prototype
> drivers/md/linear.c:362: error: expected declaration specifiers or '...' before string constant
> drivers/md/linear.c:362: warning: data definition has no type or storage class
> drivers/md/linear.c:362: warning: type defaults to 'int' in declaration of 'MODULE_ALIAS'
> drivers/md/linear.c:362: warning: function declaration isn't a prototype
> drivers/md/linear.c:363: error: expected declaration specifiers or '...' before string constant
> drivers/md/linear.c:363: warning: data definition has no type or storage class
> drivers/md/linear.c:363: warning: type defaults to 'int' in declaration of 'MODULE_ALIAS'
> drivers/md/linear.c:363: warning: function declaration isn't a prototype
> make[3]: *** [drivers/md/linear.o] Error 1
>
>
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
