Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:50888 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120Ab3EFOdb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 10:33:31 -0400
MIME-Version: 1.0
In-Reply-To: <20130506085547.GC13861@dyad.programming.kicks-ass.net>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<1367615050-3894-2-git-send-email-ccross@android.com>
	<20130504130440.GC13770@amd.pavel.ucw.cz>
	<CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
	<20130504225715.GB24276@amd.pavel.ucw.cz>
	<CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
	<20130505000528.GA25454@amd.pavel.ucw.cz>
	<20130505091844.GC22239@gmail.com>
	<20130506085547.GC13861@dyad.programming.kicks-ass.net>
Date: Mon, 6 May 2013 07:33:28 -0700
Message-ID: <CA+55aFzVNwCJhvp4f0EcHK3Vk1ZVKY0fAeu-6FdjhCFiafTAPQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Ingo Molnar <mingo@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        Colin Cross <ccross@android.com>, Andrew Morton <akpm@osdl.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
        Ben Chan <benchan@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 6, 2013 at 1:55 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> Doesn't i386 have all the funny per-cpu stuff too? So the only reason it still
> does the fugly stack based thing is because nobody could be arsed to do the
> work of converting it.

Umm. That "fugly stack-based" thing is better than the per-cpu crap.

The percpu stuff implies a memory load. The stack based thing gets
thread_info with pure register accesses. Much better.

For "current()" the per-cpu thing may be better, but if you actually
need the thread-info (not the case here, but in other places), the
stack masking is superior when it works (ie when you don't have
multi-stack issues due to irq's etc)

                Linus
