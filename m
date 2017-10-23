Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:55250 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750885AbdJWHal (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Oct 2017 03:30:41 -0400
From: "Reshetova, Elena" <elena.reshetova@intel.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
Subject: RE: [PATCH 00/11] nfs refcount conversions
Date: Mon, 23 Oct 2017 07:30:34 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B802B4278@IRSMSX102.ger.corp.intel.com>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
 <20171020185927.GD15211@fieldses.org>
In-Reply-To: <20171020185927.GD15211@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Fri, Oct 20, 2017 at 12:53:27PM +0300, Elena Reshetova wrote:
> > This series, for nfs components, replaces atomic_t reference
> > counters with the new refcount_t type and API (see include/linux/refcount.h).
> > By doing this we prevent intentional or accidental
> > underflows or overflows that can led to use-after-free vulnerabilities.
> >
> > The patches are fully independent and can be cherry-picked separately.
> > If there are no objections to the patches, please merge them via respective trees.
> >
> > Rebased on top of linux-next.
> >
> > Elena Reshetova (11):
> >   fs, nfsd: convert nfs4_stid.sc_count from atomic_t to refcount_t
> >   fs, nfsd: convert nfs4_cntl_odstate.co_odcount from atomic_t to
> >     refcount_t
> >   fs, nfsd: convert nfs4_file.fi_ref from atomic_t to refcount_t
> 
> Thanks, applying for 4.15.

Thank you very much!

> 
> I haven't followed recent discussion on the refcount api, but I assume
> the consensus is to do this, and these particular conversions certainly
> look trivial enough.

refcount_api will continue for evolve for some time I think, we recently got
x86 specific FAST implementation done, some other archs might follow.
There is an ongoing discussion about the memory ordering, which we have to
decide which way we want things to be, but these are all independent things
from the actual conversions. So for conversions that are basic and rather trivial, 
nothing should prevent doing them now.

Best Regards,
Elena.


> 
> --b.
