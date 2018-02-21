Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43249 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751104AbeBUXYg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Feb 2018 18:24:36 -0500
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+gvH+X-XyqFbY+X0xtG2mQoL5bO7T2_QaeEyr3-Z5eLw@mail.gmail.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
 <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name> <CAGXu5j+gvH+X-XyqFbY+X0xtG2mQoL5bO7T2_QaeEyr3-Z5eLw@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 21 Feb 2018 15:24:35 -0800
Message-ID: <CA+55aFzsiVMFZVwm92N8L=E+YgOG+fpjwxt7rmz72=yMQGz8rg@mail.gmail.com>
Subject: Re: RANDSTRUCT structs need linux/compiler_types.h (Was: [nfsd4]
 potentially hardware breaking regression in 4.14-rc and 4.13.11)
To: Kees Cook <keescook@chromium.org>
Cc: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>,
        Patrick McLean <chutzpah@gentoo.org>,
        Emese Revfy <re.emese@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 21, 2018 at 2:52 PM, Kees Cook <keescook@chromium.org> wrote:
>
> I'll play with Linus's suggestion and see what we get.

It may be just as well to just include <linux/compiler_types.h> from
<linux/kconfig.h> and be done with it.

If you look at that hacky script I documented in commit 23c35f48f5fb
("pinctrl: remove include file from <linux/device.h>") and run it in a
fully built kernel tree, you'll see that that header is included from
pretty much every single file anyway. At least for me, for an
allmodconfig build, the top headers are

  23322 arch/x86/include/uapi/asm/types.h
  23322 include/asm-generic/int-ll64.h
  23322 include/linux/types.h
  23322 include/uapi/asm-generic/int-ll64.h
  23322 include/uapi/asm-generic/types.h
  23322 include/uapi/linux/types.h
  23323 arch/x86/include/uapi/asm/bitsperlong.h
  23323 include/asm-generic/bitsperlong.h
  23323 include/uapi/asm-generic/bitsperlong.h
  23326 include/linux/stringify.h
  23390 include/linux/compiler_types.h

and considering that I have 25949 object files in that tree, it really
means that just about every compile ended up including that
<linux/compiler_types.h> file anyway (yeah, the "orc_types.h" header
ends up being mentioned twice for most files, so it looks even more
hot, but that's not real data).

I do hate including unnecessary stuff because it makes builds slower,
but kernel header files probably don't get much more core than
<linux/compiler_types.h>.

              Linus
