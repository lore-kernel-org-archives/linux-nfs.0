Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:38449 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758782Ab2IFQVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Sep 2012 12:21:31 -0400
Message-ID: <5048CDA2.10300@gmail.com>
Date: Thu, 06 Sep 2012 18:21:54 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
To: Steven Rostedt <rostedt@goodmis.org>
CC: Josh Triplett <josh@joshtriplett.org>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Pedro Alves <palves@redhat.com>, Tejun Heo <tj@kernel.org>,
        torvalds@linux-foundation.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu,
        ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com,
        netdev@vger.kernel.org, eric.dumazet@gmail.com, axboe@kernel.dk,
        agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and naive hashtable
References: <503C95E4.3010000@gmail.com> <20120828101148.GA21683@Krystal>  <503CAB1E.5010408@gmail.com> <20120828115638.GC23818@Krystal>  <20120828230050.GA3337@Krystal>  <1346772948.27919.9.camel@gandalf.local.home> <50462C99.5000007@redhat.com>  <50462EE8.1090903@redhat.com> <20120904170138.GB31934@Krystal>  <5048AAF6.5090101@gmail.com> <20120906145545.GA17332@leaf>  <5048C615.4070204@gmail.com> <1346947206.1680.36.camel@gandalf.local.home>
In-Reply-To: <1346947206.1680.36.camel@gandalf.local.home>
Content-Type: text/plain; charset=ISO-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/06/2012 06:00 PM, Steven Rostedt wrote:
>> > I think that that code doesn't make sense. The users of hlist_for_each_* aren't
>> > supposed to be changing the loop cursor.
> I totally agree. Modifying the 'node' pointer is just asking for issues.
> Yes that is error prone, but not due to the double loop. It's due to the
> modifying of the node pointer that is used internally by the loop
> counter. Don't do that :-)

While we're on this subject, I haven't actually seen hlist_for_each_entry() code
that even *touches* 'pos'.

Will people yell at me loudly if I change the prototype of those macros to be:

	hlist_for_each_entry(tpos, head, member)

(Dropping the 'pos' parameter), and updating anything that calls those macros to
drop it as well?


Thanks,
Sasha
