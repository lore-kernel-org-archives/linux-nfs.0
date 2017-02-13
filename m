Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:35199 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751916AbdBMJ4W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 04:56:22 -0500
Received: by mail-wr0-f169.google.com with SMTP id 89so146822986wrr.2
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2017 01:56:21 -0800 (PST)
Date: Mon, 13 Feb 2017 09:56:18 +0000
From: Steve Capper <steve.capper@linaro.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
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
Subject: Re: [PATCH v3 0/2] iov_iter: allow iov_iter_get_pages_alloc to
 allocate more pages per call
Message-ID: <20170213095616.GA18053@linaro.org>
References: <20170124212327.14517-1-jlayton@redhat.com>
 <20170125133205.21704-1-jlayton@redhat.com>
 <20170202095125.GF27291@ZenIV.linux.org.uk>
 <20170202105651.GA32111@infradead.org>
 <20170202111625.GG27291@ZenIV.linux.org.uk>
 <1486040452.2812.6.camel@redhat.com>
 <20170203072952.GI27291@ZenIV.linux.org.uk>
 <CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
 <20170203190816.GK27291@ZenIV.linux.org.uk>
 <CA+55aFwXKPUoZ3R4ey03L6ksXCmGLNS=16aQ7gRO1=VXCMZx-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwXKPUoZ3R4ey03L6ksXCmGLNS=16aQ7gRO1=VXCMZx-A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 03, 2017 at 11:28:48AM -0800, Linus Torvalds wrote:
> On Fri, Feb 3, 2017 at 11:08 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > On x86 it does.  I don't see anything equivalent in mm/gup.c one, and the
> > only kinda-sorta similar thing (access_ok() in __get_user_pages_fast()
> > there) is vulnerable to e.g. access via kernel_write().
> 
> Yeah, access_ok() is bogus. It needs to just check against TASK_SIZE
> or whatever.
> 
> > doesn't look promising - access_ok() is never sufficient.  Something like
> > _PAGE_USER tests in x86 one solves that problem, but if anything similar
> > works for HAVE_GENERIC_RCU_GUP I don't see it.  Thus the question re
> > what am I missing here...
> 
> Ok, I definitely agree that it looks like __get_user_pages_fast() just
> needs to get rid of the access_ok() and replace it with a proper check
> for the user address space range.
> 
> Looks like arm[64] and powerpc.are the current users. Adding in some
> people involved with the original submission a few years ago.

Hi,

[ Apologies for my late reply, I was on vacation then catchup... ]

> 
> I do note that the x86 __get_user_pages_fast() thing looks dodgy too.
> 
> In particular, we do it right in the *real* get_user_pages_fast(), see
> commit 7f8189068726 ("x86: don't use 'access_ok()' as a range check in
> get_user_pages_fast()"). But then the same bug was re-introduced when
> the "irq safe" version was merged. As well as in the GENERIC_RCU_GUP
> version.
> 
> Gaah. Apparently PeterZ copied the old buggy version before the fix
> when he added __get_user_pages_fast() in commit 465a454f254e ("x86,
> mm: Add __get_user_pages_fast()").
> 
> I guess it could be considered a merge error (both happened during the
> 2.6.31 merge window).
> 

Okay so looking at what we have for access_ok(.) on arm64, my
understanding is that we perform a 65-bit add/compare (in assembler) to
see whether or not the range is below the current_thread_info->addr_limit.
So I think this is a roundabout way of checking for no-wrap around and <= TASK_SIZE.

Looking at powerpc, I see it's a little different...

So if it sounds reasonable to folk I was going to send a patch to
replace the call to access_ok(.) with a wraparound + TASK_SIZE check
written explicitly in C? (and remove some of the comments talking about
access_ok(.)).

Cheers,
-- 
Steve
