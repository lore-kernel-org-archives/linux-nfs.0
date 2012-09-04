Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757871Ab2IDW6y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Sep 2012 18:58:54 -0400
Message-ID: <50468778.5000207@redhat.com>
Date: Tue, 04 Sep 2012 23:58:00 +0100
From: Pedro Alves <palves@redhat.com>
MIME-Version: 1.0
To: Steven Rostedt <rostedt@goodmis.org>
CC: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu,
        ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com,
        netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com,
        axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <20120824203332.GF21325@google.com> <5037E9D9.9000605@gmail.com>     <20120824212348.GK21325@google.com> <5038074D.300@gmail.com>     <20120824230740.GN21325@google.com> <20120825042419.GA27240@Krystal>     <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>     <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>     <20120828230050.GA3337@Krystal>    <1346772948.27919.9.camel@gandalf.local.home>   <50462C99.5000007@redhat.com>  <50462EE8.1090903@redhat.com>   <1346779027.27919.15.camel@gandalf.local.home>   <50463883.8080706@redhat.com>  <1346792345.27919.18.camel@gandalf.local.home>  <504677C8.3050801@redhat.com> <1346798509.27919.25.camel@gandalf.local.home>
In-Reply-To: <1346798509.27919.25.camel@gandalf.local.home>
Content-Type: text/plain; charset=ISO-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/04/2012 11:41 PM, Steven Rostedt wrote:
> Ah, I missed the condition with the rec == &pg->records[pg->index]. But
> if ftrace_pages_start is NULL, the rec = &pg->records[pg->index] will
> fault.

Right.

> 
> You could do something like rec = pg ? &pg->records[pg->index] : NULL,

Right.

> but IIRC, the comma operator does not guarantee order evaluation. That
> is, the compiler is allowed to process "a , b" as "b; a;" and not "a;
> b;".

Not true.  The comma operator introduces a sequence point.  It's the comma
that separates function parameters that doesn't guarantee ordering.

-- 
Pedro Alves

