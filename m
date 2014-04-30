Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48092 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbaD3Hix (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 03:38:53 -0400
Date: Wed, 30 Apr 2014 09:38:50 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
        NFS <linux-nfs@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH/RFC] SCHED: allow wait_on_bit functions to support a
 timeout.
Message-ID: <20140430073850.GB13658@twins.programming.kicks-ass.net>
References: <20140429194406.06c580b8@notabene.brown>
 <20140429103217.GQ27561@twins.programming.kicks-ass.net>
 <20140430122926.6bb0c771@notabene.brown>
 <20140430073154.GW11096@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140430073154.GW11096@twins.programming.kicks-ass.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 30, 2014 at 09:31:54AM +0200, Peter Zijlstra wrote:
> On Wed, Apr 30, 2014 at 12:29:26PM +1000, NeilBrown wrote:
> > If you think it is a good cleanup I'll post a proper patch with all the right
> > Cc:s.
> 
> Yeah, its a good cleanup. Thanks!

Also, please add Oleg to the Cc, he was involved in the last big wait
cleanup too.
