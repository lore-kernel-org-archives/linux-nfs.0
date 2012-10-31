Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:45040 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271Ab2JaB0I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Oct 2012 21:26:08 -0400
MIME-Version: 1.0
In-Reply-To: <1351646186.4004.41.camel@gandalf.local.home>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org> <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <1351646186.4004.41.camel@gandalf.local.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 30 Oct 2012 18:25:46 -0700
Message-ID: <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com,
        axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 30, 2012 at 6:16 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> ({                                                                    \
>         sizeof(val) <= 4 ? hash_32(val, bits) : hash_long(val, bits); \
> })
>
> Is the better way to go. We are C programmers, we like to see the ?: on
> a single line if possible. The way you have it, looks like three
> statements run consecutively.

If we're C programmers, why use the non-standard statement-expression
at all? And split it onto three lines when it's just a single one?

But whatever. This series has gotten way too much bike-shedding
anyway. I think it should just be applied, since it does remove lines
of code overall. I'd even possibly apply it to mainline, but it seems
to be against linux-next.

             Linus
