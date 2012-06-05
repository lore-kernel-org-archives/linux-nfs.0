Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:37620 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab2FEOwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 10:52:12 -0400
Message-ID: <4FCE1D17.1080904@openvz.org>
Date: Tue, 05 Jun 2012 18:52:07 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
To: Ondrej Zary <linux@rainbow-software.org>
CC: Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org> <201206051620.47925.linux@rainbow-software.org>
In-Reply-To: <201206051620.47925.linux@rainbow-software.org>
Content-Type: multipart/mixed;
 boundary="------------070904050700040409040500"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070904050700040409040500
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hmm, very interesting!
Please try this patch, it must fix the problem and print some numbers to debug.

Ondrej Zary wrote:
> On Tuesday 05 June 2012, Konstantin Khlebnikov wrote:
>> Ondrej Zary wrote:
>>> Hello,
>>> I use NFS for deploying HDD images on new machines. My machine has 2nd
>>> network card just for this, running DHCPD, TFTPD and kernel NFS server.
>>> The target machine is set to boot from LAN and boots SystemRescueCD from
>>> my machine with an autorun script that launches Partimage and deploys the
>>> HDD image (400 to 900 MB compressed).
>>>
>>> It worked fine for years, until now. With kernel 3.4, everyting
>>> works only for the first time after boot (and not always). Next time
>>> (next machine), partimage aborts almost immediately as it's probably
>>> unable to decompress the image file. md5sum is different on my machine
>>> vs. on the target (through NFS). Also SystemRescueCD boot aborts with md5
>>> error sometimes. Everything works fine after rebooting back to 3.3.
>>>
>>> Bisection found this:
>>>
>>> 0fc9d1040313047edf6a39fd4d7c7defdca97c62 is the first bad commit
>>> commit 0fc9d1040313047edf6a39fd4d7c7defdca97c62
>>> Author: Konstantin Khlebnikov<khlebnikov@openvz.org>
>>> Date:   Wed Mar 28 14:42:54 2012 -0700
>>>
>>>       radix-tree: use iterators in find_get_pages* functions
>>>
>>> Reverting this commit in 3.4 fixes the problem.
>>
>> [all reporters added to CC] let's keep all in one thread
>>
>> In attachment two patches which might help to debug this regression:
>>
>> "mm: recheck page index in find_get_pages_contig" adds paranoid check into
>> find_get_pages_contig(). It can explain everything, but currently I don't
>> see how this can hapens.
>>
>> "mm: debug fing_get_pages speculative restart" shows lookup restarting
>> condition which was removed by bisected commit.
>
> My dmesg (after corruption occured) with these two patches applied:
>
> [   79.999511] ------------[ cut here ]------------
> [   79.999564] WARNING: at mm/filemap.c:941 find_get_pages_contig+0x177/0x1b0()
> [   79.999611] Hardware name: VT82C694X
> [   79.999617] Modules linked in: nfsd lockd sunrpc des_generic ecb crypto_blkcipher md4 md5 hmac cryptomgr aead cifs crypto_hash crypto_algapi crypto
> firewire_ohci firewire_core
> [   79.999653] Pid: 1563, comm: nfsd Not tainted 3.4.0-omega #4
> [   79.999659] Call Trace:
> [   79.999729]  [<c011ff88>] ? warn_slowpath_common+0x78/0xb0
> [   79.999744]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
> [   79.999753]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
> [   79.999763]  [<c011ffd9>] ? warn_slowpath_null+0x19/0x20
> [   79.999772]  [<c0175187>] ? find_get_pages_contig+0x177/0x1b0
> [   79.999805]  [<c01c544b>] ? __generic_file_splice_read+0xeb/0x510
> [   79.999853]  [<c01c4040>] ? page_cache_pipe_buf_release+0x10/0x10
> [   79.999873]  [<c04f2589>] ? common_interrupt+0x29/0x30
> [   79.999900]  [<f892c710>] ? _fh_update.isra.11.part.12+0x60/0x60 [nfsd]
> [   79.999931]  [<c022c9f7>] ? exportfs_decode_fh+0xc7/0x250
> [   79.999981]  [<f893133d>] ? exp_get_by_name+0x3d/0x70 [nfsd]
> [   80.000000]  [<c0150215>] ? getboottime+0x35/0x40
> [   80.007383]  [<c04f0da8>] ? __schedule+0x198/0x470
> [   80.007505]  [<f88cbf34>] ? sunrpc_cache_lookup+0x54/0x2d0 [sunrpc]
> [   80.007574]  [<c01c58e3>] ? generic_file_splice_read+0x73/0x110
> [   80.007590]  [<c01254bf>] ? irq_exit+0x4f/0x90
> [   80.007599]  [<c01c5870>] ? __generic_file_splice_read+0x510/0x510
> [   80.007608]  [<c01c4330>] ? do_splice_to+0x60/0x90
> [   80.007618]  [<c01c459a>] ? splice_direct_to_actor+0xaa/0x1c0
> [   80.007654]  [<f892d710>] ? nfsd_buffered_filldir+0x160/0x160 [nfsd]
> [   80.007700]  [<f892dc37>] ? nfsd_vfs_read.isra.16+0x117/0x160 [nfsd]
> [   80.007715]  [<f892e764>] ? nfsd_read+0x1c4/0x280 [nfsd]
> [   80.007732]  [<f89357bf>] ? nfsd3_proc_read+0xcf/0x160 [nfsd]
> [   80.007745]  [<f892a7d0>] ? nfsd_dispatch+0xb0/0x190 [nfsd]
> [   80.007779]  [<f88c3682>] ? svc_process+0x442/0x7c0 [sunrpc]
> [   80.007825]  [<f892a0a3>] ? nfsd+0xa3/0x130 [nfsd]
> [   80.007838]  [<f892a000>] ? 0xf8929fff
> [   80.007846]  [<f892a000>] ? 0xf8929fff
> [   80.007858]  [<c01389bc>] ? kthread+0x6c/0x80
> [   80.007867]  [<c0138950>] ? kthread_freezable_should_stop+0x50/0x50
> [   80.007896]  [<c04f2596>] ? kernel_thread_helper+0x6/0xd
> [   80.007937] ---[ end trace 0bc8170cf5ac5466 ]---

--------------070904050700040409040500
Content-Type: text/plain;
 name="mm-fix-find_get_pages_contig"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="mm-fix-find_get_pages_contig"

bW06IGZpeCBmaW5kX2dldF9wYWdlc19jb250aWcKCkZyb206IEtvbnN0YW50aW4gS2hsZWJu
aWtvdiA8a2hsZWJuaWtvdkBvcGVudnoub3JnPgoKU2lnbmVkLW9mZi1ieTogS29uc3RhbnRp
biBLaGxlYm5pa292IDxraGxlYm5pa292QG9wZW52ei5vcmc+Ci0tLQogbW0vZmlsZW1hcC5j
IHwgICAgNSArKysrLQogMSBmaWxlIGNoYW5nZWQsIDQgaW5zZXJ0aW9ucygrKSwgMSBkZWxl
dGlvbigtKQoKZGlmZiAtLWdpdCBhL21tL2ZpbGVtYXAuYyBiL21tL2ZpbGVtYXAuYwppbmRl
eCA3OWM0YjJiLi5mNDM0M2EzIDEwMDY0NAotLS0gYS9tbS9maWxlbWFwLmMKKysrIGIvbW0v
ZmlsZW1hcC5jCkBAIC05MjgsNyArOTI4LDEwIEBAIHJlcGVhdDoKIAkJICogb3RoZXJ3aXNl
IHdlIGNhbiBnZXQgYm90aCBmYWxzZSBwb3NpdGl2ZXMgYW5kIGZhbHNlCiAJCSAqIG5lZ2F0
aXZlcywgd2hpY2ggaXMganVzdCBjb25mdXNpbmcgdG8gdGhlIGNhbGxlci4KIAkJICovCi0J
CWlmIChwYWdlLT5tYXBwaW5nID09IE5VTEwgfHwgcGFnZS0+aW5kZXggIT0gaXRlci5pbmRl
eCkgeworCQlpZiAocGFnZS0+bWFwcGluZyA9PSBOVUxMIHx8IHBhZ2UtPmluZGV4ICE9IGlu
ZGV4ICsgcmV0KSB7CisJCQlpZiAoaXRlci5pbmRleCAhPSBpbmRleCArIHJldCkKKwkJCQlw
cmludGsoIiVzICVsdSAlbHUgJXVcbiIsIF9fZnVuY19fLAorCQkJCQkJaXRlci5pbmRleCwg
aW5kZXgsIHJldCk7CiAJCQlwYWdlX2NhY2hlX3JlbGVhc2UocGFnZSk7CiAJCQlicmVhazsK
IAkJfQo=
--------------070904050700040409040500--
