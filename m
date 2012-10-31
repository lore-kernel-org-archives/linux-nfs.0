Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:60859 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754190Ab2JaAxV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 20:53:21 -0400
Date: Tue, 30 Oct 2012 20:51:28 -0400
From: Jim Rees <rees@umich.edu>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, torvalds@linux-foundation.org,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
        aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
        josh@joshtriplett.org, eric.dumazet@gmail.com,
        mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Message-ID: <20121031005128.GA30251@umich.edu>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org>
 <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sasha Levin wrote:

  On Tue, Oct 30, 2012 at 5:42 PM, Tejun Heo <tj@kernel.org> wrote:
  > Hello,
  >
  > Just some nitpicks.
  >
  > On Tue, Oct 30, 2012 at 02:45:57PM -0400, Sasha Levin wrote:
  >> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
  >> +#define hash_min(val, bits)                                                  \
  >> +({                                                                           \
  >> +     sizeof(val) <= 4 ?                                                      \
  >> +     hash_32(val, bits) :                                                    \
  >> +     hash_long(val, bits);                                                   \
  >> +})
  >
  > Doesn't the above fit in 80 column.  Why is it broken into multiple
  > lines?  Also, you probably want () around at least @val.  In general,
  > it's a good idea to add () around any macro argument to avoid nasty
  > surprises.
  
  It was broken to multiple lines because it looks nicer that way (IMO).
  
  If we wrap it with () it's going to go over 80, so it's going to stay
  broken down either way :)

I would prefer the body be all on one line too. But shouldn't this be a
static inline function?
