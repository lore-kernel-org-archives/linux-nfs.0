Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:34820 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752626AbdKITeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 14:34:22 -0500
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and
 4.13.11
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
From: Patrick McLean <chutzpah@gentoo.org>
Message-ID: <8fc5311b-fc56-1c19-8f63-0c509d3dd4ad@gentoo.org>
Date: Thu, 9 Nov 2017 11:34:19 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 2017-11-08 06:40 PM, Linus Torvalds wrote:
> On Wed, Nov 8, 2017 at 4:43 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
>> As of 4.13.11 (and also with 4.14-rc) we have an issue where when
>> serving nfs4 sometimes we get the following BUG. When this bug happens,
>> it usually also causes the motherboard to no longer POST until we
>> externally re-flash the BIOS (using the BMC web interface). If a
>> motherboard does not have an external way to flash the BIOS, this would
>> brick the hardware.
> 
> That sounds like your BIOS is just broken.

All the dead boards were from the same vendor. We are going to try some
boards from another vendor today.

> 
> The kernel oops is probably just a trigger for that - possibly because
> you reboot with a particular state that breaks the BIOS.
> 
> Also, are you sure you really need to reflash the BIOS? It's actually
> fairly hard to overwrite the BIOS itself, but crashing with bad
> hardware state (where "bad" can just mean "unexpected by the BIOS")
> can cause the BIOS to not properly re-initialize things, and hang at
> boot.
> 
> So not booting cleanly from a warm reset is a reasonably common BIOS failure.
> 
> And yes, reflashing tends to force a full initialization and thus
> "fixes" things, but it may be a big hammer when a cold boot or just a
> "reset BIOS to safe defaults" might be sufficient.
> 
> In pretty much all cases this is a sign of a nasty BIOS problem,
> though, and you may want to look into a firmware update from the
> vendor for that.

We tried a cold power off (physically unplugging the machine from power)
and a CMOS reset, and neither helped. The only thing that actually
restored one of the dead boards was a reflash. I did the reflash with
the latest code when I reflashed it.

> 
> But on to the kernel side:
> 
>> Here is the BUG we are getting:
>>> [   58.962528] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
>>> [   58.963918] IP: vfs_statfs+0x73/0xb0
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
> NULL, because we wouldn't have gotten this far if it was.
> 
> Now, afaik, mnt->mnt_sb should never be NULL in the first place for a
> proper path. And the vfs_statfs() code itself hasn't changed in a
> while.
> 
> Which does seem to implicate nfsd as having passed in a bad path to
> vfs_statfs(). But I'm not seeing any changes in nfsd either.
> 
> In particular, there are *no* nfsd changes in that 4.13.8..4.13.11
> range. There is a bunch of xfs changes, though. What's the underlying
> filesystem that you are exporting?

It's an ext4 filesystem.

> 
> But bringing in Al Viro and Bruce Fields explicitly in case they see
> something. And Darrick, just in case it might be xfs.
> 

Thanks
