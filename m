Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60302 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbaEAJbt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 05:31:49 -0400
Date: Thu, 1 May 2014 11:31:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>,
        Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com,
        Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>,
        Steve French <sfrench@samba.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140501093140.GN11096@twins.programming.kicks-ass.net>
References: <20140501123738.3e64b2d2@notabene.brown>
 <20140501074257.GK11096@twins.programming.kicks-ass.net>
 <20140501192605.6b5383f8@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140501192605.6b5383f8@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 01, 2014 at 07:26:05PM +1000, NeilBrown wrote:
> On Thu, 1 May 2014 09:42:57 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Thu, May 01, 2014 at 12:37:38PM +1000, NeilBrown wrote:
> > > +static inline int
> > > +wait_on_bit(void *word, int bit, unsigned mode)
> > > +{
> > > +	if (!test_bit(bit, word))
> > > +		return 0;
> > > +	return out_of_line_wait_on_bit(word, bit,
> > > +				       bit_wait,
> > > +				       mode & 65535);
> > > +}
> > 
> > Still puzzled by the 16 bit mask there ;-)
> 
> I clearly remember removing that!
> And I've just done it again.
> I hope it doesn't re-reappear!
> :-)
> NeilBrown

Seems dead now, I'll hold out for a little while so that dhowells can
explain this fscache thing.

Then I'll queue it. Ingo is currently enjoying a long weekend and is
fighting (well I am now) a stability issue in -tip kernels, so it might
be a little while before it actually shows up in the git tree.
