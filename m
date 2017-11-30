Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:40526 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750810AbdK3Hs5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Nov 2017 02:48:57 -0500
From: "Reshetova, Elena" <elena.reshetova@intel.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>
Subject: RE: [PATCH 0/4] lockd refcount conversions
Date: Thu, 30 Nov 2017 07:48:52 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B802C4FE5@IRSMSX102.ger.corp.intel.com>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
 <20171129222341.GB3923@fieldses.org>
In-Reply-To: <20171129222341.GB3923@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Thanks, applying all four for 4.16.--b.

Thank you very much!

Best Regards,
Elena.

> 
> On Wed, Nov 29, 2017 at 01:15:42PM +0200, Elena Reshetova wrote:
> > This series, for lockd component, replaces atomic_t reference
> > counters with the new refcount_t type and API (see include/linux/refcount.h).
> > By doing this we prevent intentional or accidental
> > underflows or overflows that can led to use-after-free vulnerabilities.
> >
> > The patches are fully independent and can be cherry-picked separately.
> > If there are no objections to the patches, please merge them via respective
> tree.
> >
> > Elena Reshetova (4):
> >   lockd: convert nlm_host.h_count from atomic_t to refcount_t
> >   lockd: convert nsm_handle.sm_count from atomic_t to refcount_t
> >   lockd: convert nlm_lockowner.count from atomic_t to refcount_t
> >   lockd: convert nlm_rqst.a_count from atomic_t to refcount_t
> >
> >  fs/lockd/clntproc.c         | 14 +++++++-------
> >  fs/lockd/host.c             | 16 ++++++++--------
> >  fs/lockd/mon.c              | 14 +++++++-------
> >  fs/lockd/svcproc.c          |  2 +-
> >  include/linux/lockd/lockd.h |  9 +++++----
> >  5 files changed, 28 insertions(+), 27 deletions(-)
> >
> > --
> > 2.7.4
