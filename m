Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:44321 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932427Ab2J2S6U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 14:58:20 -0400
Date: Mon, 29 Oct 2012 11:58:14 -0700
From: Tejun Heo <tj@kernel.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Sasha Levin <levinsasha928@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
        aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable implementation
Message-ID: <20121029185814.GC4066@htj.dyndns.org>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
 <20121029113515.GB9115@Krystal>
 <CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com>
 <20121029183157.GC3097@jtriplet-mobl1>
 <CA+1xoqfMrn9zDFMJNFfA0NA86wE_DedD97cP1yJ2UQdTjs3uyQ@mail.gmail.com>
 <20121029185319.GA21546@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121029185319.GA21546@Krystal>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 29, 2012 at 02:53:19PM -0400, Mathieu Desnoyers wrote:
> The argument about hash_init being useful to add magic values in the
> future only works for the cases where a hash table is declared with
> DECLARE_HASHTABLE(). It's completely pointless with DEFINE_HASHTABLE(),
> because we could initialize any debugging variables from within
> DEFINE_HASHTABLE().

You can do that with [0 .. HASH_SIZE - 1] initializer.

Thanks.

-- 
tejun
