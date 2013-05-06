Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:33304
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752388Ab3EFI5h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 04:57:37 -0400
Date: Mon, 6 May 2013 10:55:47 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@kernel.org>
Cc: Pavel Machek <pavel@ucw.cz>, Colin Cross <ccross@android.com>,
        Andrew Morton <akpm@osdl.org>, lkml <linux-kernel@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Len Brown <len.brown@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Ingo Molnar <mingo@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mandeep Singh Baines <msb@chromium.org>,
        Paul Walmsley <paul@pwsan.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Oleg Nesterov <oleg@redhat.com>, linux-nfs@vger.kernel.org,
        Linux PM list <linux-pm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Tejun Heo <tj@kernel.org>, Ben Chan <benchan@chromium.org>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Message-ID: <20130506085547.GC13861@dyad.programming.kicks-ass.net>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
 <1367615050-3894-2-git-send-email-ccross@android.com>
 <20130504130440.GC13770@amd.pavel.ucw.cz>
 <CAMbhsRScr+3Zk5Bi6390bGRbtE4oh2H-mHrGHS0wew5hdkivUg@mail.gmail.com>
 <20130504225715.GB24276@amd.pavel.ucw.cz>
 <CAMbhsRS_cF7kF-QZ9BMBUS3ytU0ukRCbC3D549HW_XOsQbEZhg@mail.gmail.com>
 <20130505000528.GA25454@amd.pavel.ucw.cz>
 <20130505091844.GC22239@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130505091844.GC22239@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 05, 2013 at 11:18:44AM +0200, Ingo Molnar wrote:
> That's the old 32-bit x86 trick to compute 'current' from the kernel stack 
> pointer.
> 
> It can be done better - for example on platforms with optimized percpu 
> variables (x86-64) it looks like this:

Doesn't i386 have all the funny per-cpu stuff too? So the only reason it still
does the fugly stack based thing is because nobody could be arsed to do the
work of converting it.
