Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54458 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751980AbdLVOZx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Dec 2017 09:25:53 -0500
Date: Fri, 22 Dec 2017 09:25:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
Subject: Re: [PATCH 1/4] lockd: convert nlm_host.h_count from atomic_t to
 refcount_t
Message-ID: <20171222142553.GA9630@fieldses.org>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
 <1511954146-11793-2-git-send-email-elena.reshetova@intel.com>
 <20171221202350.GE31467@fieldses.org>
 <2236FBA76BA1254E88B949DDB74E612B802CFB57@IRSMSX102.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B802CFB57@IRSMSX102.ger.corp.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 22, 2017 at 09:29:15AM +0000, Reshetova, Elena wrote:
> 
> On Wed, Nov 29, 2017 at 01:15:43PM +0200, Elena Reshetova wrote:
> > atomic_t variables are currently used to implement reference
> > counters with the following properties:
> >  - counter is initialized to 1 using atomic_set()
> >  - a resource is freed upon counter reaching zero
> >  - once counter reaches zero, its further
> >    increments aren't allowed
> >  - counter schema uses basic atomic operations
> >    (set, inc, inc_not_zero, dec_and_test, etc.)
> 
> >Whoops, I forgot that this doesn't apply to h_count.
> 
> >Well, it's confusing, because h_count is actually used in two different
> >ways: depending on whether a nlm_host represents a client or server, it
> >may have the above properties or not.
> 
> 
> So, what happens when it is not having the above properties? Is the object 
> being reused or? 

The object isn't destroyed when the counter hits zero--zero is just
taken as a hint to some garbage collection algorithm that it would be OK
to destroy it.  So decrementing to or incrementing from zero is OK.

--b.
