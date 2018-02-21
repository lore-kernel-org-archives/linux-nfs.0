Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vps-vb.mhejs.net ([37.28.154.113]:42746 "EHLO vps-vb.mhejs.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750805AbeBUWTJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 17:19:09 -0500
Subject: RANDSTRUCT structs need linux/compiler_types.h (Was: [nfsd4]
 potentially hardware breaking regression in 4.14-rc and 4.13.11)
To: Kees Cook <keescook@chromium.org>,
        Patrick McLean <chutzpah@gentoo.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Emese Revfy <re.emese@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>
References: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Message-ID: <6be06ce5-87e6-0d9d-55b9-6c70c3578ecf@maciej.szmigiero.name>
Date: Wed, 21 Feb 2018 23:19:01 +0100
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLc_A1w4FM8FvQHGSPjLfOu80L_vbt_FkcE6+Bh_XMjxw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18.11.2017 06:14, Kees Cook wrote:
> On Fri, Nov 17, 2017 at 5:54 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
>> On 2017-11-17 04:55 PM, Linus Torvalds wrote:
>>> On Fri, Nov 17, 2017 at 4:27 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
>>>>
>>>> I am still getting the crash at d9e12200852d, I figured I would
>>>> double-check the "good" and "bad" kernels before starting a full bisect.
>>>
>>> .. but without GCC_PLUGIN_RANDSTRUCT it's solid?
>>
>> Yes, without GCC_PLUGIN_RANDSTRUCT it's solid.
> 
> That's strange. With d9e12200852d the shuffle_seed variables won't
> ever actually get used. (i.e. I wouldn't expect the seed to change any
> behavior.)
> 
> Can you confirm with something like this:
> 
> 
>         for (i = 0; i < 4; i++) {
>                 seed[i] = shuffle_seed[i];
> 
> 
> You should see no reports of "Shuffling struct ..."
> 
> And if it reports nothing, and you're on d9e12200852d, can you confirm
> that switching to a "good" seed fixes it? (If it _does_, then I
> suspect a build artifact being left behind or something odd like
> that.)
> 
>>> Kees removed even the baseline "randomize pure function pointer
>>> structures", so at that commit, nothing should be randomized.
>>>
>>> But maybe the plugin code itself ends up confusing gcc somehow?
>>>
>>> Even when it doesn't actually do that "relayout_struct()" on the
>>> structure, it always does those TYPE_ATTRIBUTES() games.
> 
> FWIW, myself doing a build at d9e12200852d with and without
> GCC_PLUGIN_RANDSTRUCT _appears_ to produce identical objdump output
> where I did spot-checks.
> 

I have also hit a GPF in nfsd4_encode_fattr() with RANDSTRUCT plugin
enabled.
This function is located in a fs/nfsd/nfs4xdr.c file.

The fault happened at "xdr_encode_hyper(p, exp->ex_path.mnt->mnt_sb->s_maxbytes)"
line, namely when accessing s_maxbytes.

exp->ex_path is of type struct path that has been annotated with
__randomize_layout.
It seems to me that this annotation isn't really taken into consideration
when compiling nfs4xdr.c.
This most likely results in dereferencing a value of exp->ex_path.dentry
instead of exp->ex_path.mnt. Then some member of struct dentry is
dereferenced as struct super_block to access its s_maxbytes member which
results in an oops if it happens to be an invalid pointer (which it was
in my case).

How to reproduce the problem statically (tested on current Linus's tree
and on 4.15.4, with gcc 7.3.0):
1) Enable RANDSTRUCT plugin,

2) Use a RANDSTRUCT seed that results in shuffling of struct path,
Example: "55e5fea7ff662b333a190209ab31f35b6f0f2470f7d0e3c64430936169571106".

3) make fs/nfsd/nfs4xdr.s and save the result,

4) Insert "#include <linux/compiler_types.h>" at the top of
fs/nfsd/nfs4xdr.c as the very first include directive.

5) make fs/nfsd/nfs4xdr.s and compare the result with the one from step 3.

One can see that offsets used to access various members of struct path are
different, and also that the original file from step 3 contains an object
named "__randomize_layout".

This is caused by a fact that the current version of nfs4xdr.c includes
linux/fs_struct.h as the very first included header which then includes
linux/path.h as the very first included header, which then defines
struct path, but without including any files on its own.

This results in __randomize_layout tag at the end of struct path
definition being treated as a variable name (since linux/compiler-gcc.h
that defines it as a type attribute has not been included yet).

It looks like to me that every header file that defines a randomized
struct also has to include linux/compiler_types.h or some other file
that ultimately results in that file inclusion in order to make
the RANDSTRUCT plugin work correctly.

Maciej
