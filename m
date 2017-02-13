Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:33795 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751818AbdBMVky (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 16:40:54 -0500
MIME-Version: 1.0
In-Reply-To: <20170213095616.GA18053@linaro.org>
References: <20170124212327.14517-1-jlayton@redhat.com> <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk> <20170202105651.GA32111@infradead.org>
 <20170202111625.GG27291@ZenIV.linux.org.uk> <1486040452.2812.6.camel@redhat.com>
 <20170203072952.GI27291@ZenIV.linux.org.uk> <CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
 <20170203190816.GK27291@ZenIV.linux.org.uk> <CA+55aFwXKPUoZ3R4ey03L6ksXCmGLNS=16aQ7gRO1=VXCMZx-A@mail.gmail.com>
 <20170213095616.GA18053@linaro.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 13 Feb 2017 13:40:52 -0800
Message-ID: <CA+55aFz2UjH-Lz=Zoi1he3-FfHEkh3kqP8PfeOP-u_Br9=BQAw@mail.gmail.com>
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
To: Steve Capper <steve.capper@linaro.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@kernel.org>, Jeff Layton <jlayton@redhat.com>,
        Christoph Hellwig <hch@infradead.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        ceph-devel <ceph-devel@vger.kernel.org>, lustre-devel@lists.lustre.org,
        V9FS Developers <v9fs-developer@lists.sourceforge.net>,
        Jan Kara <jack@suse.cz>, Chris Wilson <chris@chris-wilson.co.uk>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 13, 2017 at 1:56 AM, Steve Capper <steve.capper@linaro.org> wrote:
>
> Okay so looking at what we have for access_ok(.) on arm64, my
> understanding is that we perform a 65-bit add/compare (in assembler) to
> see whether or not the range is below the current_thread_info->addr_limit.
> So I think this is a roundabout way of checking for no-wrap around and <= TASK_SIZE.

No, that's the problem. It's *not* testing against TASK_SIZE.

Because add_limit is not always TASK_SIZE. When you do
set_fs(KERNEL_DS), you set addr_limit to infinity.

And yes, the kernel does read and write calls too. Seldom, but it
happens. And walking the page tables with kernel addresses is not
supposed to work (sometimes it happens to work by mistake). So if
somebody finds a path that gets from that kind of situation into the
get_user_pages() interface, bad things happen.

                 Linus
