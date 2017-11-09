Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39524 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdKIDpS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 22:45:18 -0500
Date: Thu, 9 Nov 2017 03:45:07 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
Message-ID: <20171109034507.GZ21978@ZenIV.linux.org.uk>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 08, 2017 at 06:40:22PM -0800, Linus Torvalds wrote:

> > Here is the BUG we are getting:
> >> [   58.962528] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
> >> [   58.963918] IP: vfs_statfs+0x73/0xb0
> 
> The code disassembles to
> 
>    0: 83 c9 08              or     $0x8,%ecx
>    3: 40 f6 c6 04          test   $0x4,%sil
>    7: 0f 45 d1              cmovne %ecx,%edx
>    a: 89 d1                mov    %edx,%ecx
>    c: 80 cd 04              or     $0x4,%ch
>    f: 40 f6 c6 08          test   $0x8,%sil
>   13: 0f 45 d1              cmovne %ecx,%edx
>   16: 89 d1                mov    %edx,%ecx
>   18: 80 cd 08              or     $0x8,%ch
>   1b: 40 f6 c6 10          test   $0x10,%sil
>   1f: 0f 45 d1              cmovne %ecx,%edx
>   22: 89 d1                mov    %edx,%ecx
>   24: 80 cd 10              or     $0x10,%ch
>   27: 83 e6 20              and    $0x20,%esi
>   2a:* 48 8b b7 30 02 00 00 mov    0x230(%rdi),%rsi <-- trapping instruction
>   31: 0f 45 d1              cmovne %ecx,%edx
>   34: 83 ca 20              or     $0x20,%edx
>   37: 89 f1                mov    %esi,%ecx
>   39: 83 e1 10              and    $0x10,%ecx
>   3c: 89 cf                mov    %ecx,%edi
> 
> and all those odd cmovne and bit-ops are just the bit selection code
> in flags_by_mnt(), which is inlined through calculate_f_flags (which
> is _also_ inlined) into vfs_statfs().
> 
> Sadly, gcc makes a mess of it and actually generates code that looks
> like the original C. I would have hoped that gcc could have turned
> 
>    if (x & BIT)
>         y |= OTHER_BIT;
> 
> into
> 
>     y |= (x & BIT) shifted-by-the-bit-difference-between BIT/OTHER_BIT;
> 
> but that doesn't happen. We actually do it by hand in some other more
> critical places, but it's painful to do by hand (because the shift
> direction/amount is not trivial to do in C).
> 
> Anyway, that cmovne noise makes it a bit hard to see the actual part
> that matters (and that traps) but I'm almost certain that it's the
> "mnt->mnt_sb->s_flags" loading that is part of calculate_f_flags()
> when it then does
> 
>      flags_by_sb(mnt->mnt_sb->s_flags);
> 
> and I think mnt->mnt_sb is NULL. We know it's not 'mnt' itself that is

Interesting...

struct super_block {
        struct list_head        s_list;         /* Keep this first */
        dev_t                   s_dev;          /* search index; _not_ kdev_t */
        unsigned char           s_blocksize_bits;
        unsigned long           s_blocksize;
        loff_t                  s_maxbytes;     /* Max file size */
        struct file_system_type *s_type;
        const struct super_operations   *s_op;
        const struct dquot_operations   *dq_op;
        const struct quotactl_ops       *s_qcop;
        const struct export_operations *s_export_op;
        unsigned long           s_flags;
	...

s_flags is preceded list_head, u32, unsigned char, 2 u64 and 5 pointers.
IOW, 10 64bit words.  And sure enough, amd64 builds here have
	mov    0x50(%rdi),%rsi
in the corresponding place.  What config and toolchain had produced that?

I would definitely start with turning the randomize crap off, just to
exclude the compiler weirdness.  Incidentally, randomizing anything that
contains a hash chain and key...  super_block is not the worst here -
struct dentry is clear "winner".  Anything in
struct dentry {
        /* RCU lookup touched fields */
        unsigned int d_flags;           /* protected by d_lock */
        seqcount_t d_seq;               /* per dentry seqlock */
        struct hlist_bl_node d_hash;    /* lookup hash list */
        struct dentry *d_parent;        /* parent directory */
        struct qstr d_name;
        struct inode *d_inode;          /* Where the name belongs to - NULL is
                                         * negative */
moving into a separate cache line and we've just doubled cache footprint of
hash chain traversal.

How much reordering does that gcc misfeature do and why do we enable
that in the first place?
