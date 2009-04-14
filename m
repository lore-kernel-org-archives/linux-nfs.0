From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC][PATCH v3 3/6] nfs, direct-io: fix fork vs direct-io race on nfs
Date: Tue, 14 Apr 2009 12:48:01 -0400
Message-ID: <x4963h7yyf2.fsf@segfault.boston.devel.redhat.com>
References: <20090414151204.C647.A69D9226@jp.fujitsu.com>
	<20090414151806.C650.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
        Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
        Nick Piggin <nickpiggin@yahoo.com.au>,
        Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20090414151806.C650.A69D9226@jp.fujitsu.com> (KOSAKI Motohiro's
	message of "Tue, 14 Apr 2009 15:19:24 +0900 (JST)")
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> Subject: [PATCH] nfs, direct-io: fix fork vs direct-io race on nfs
>
> After fs/diorect-io.c fix, following testcase still fail on nfs running.
> it's because nfs has own specific diorct-io implementation.

Same issue as 2/6.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
