Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40998 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbdGEJDO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Jul 2017 05:03:14 -0400
From: "Reshetova, Elena" <elena.reshetova@intel.com>
To: David Miller <davem@davemloft.net>
CC: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-decnet-user@lists.sourceforge.net"
        <linux-decnet-user@lists.sourceforge.net>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "3chas3@gmail.com" <3chas3@gmail.com>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "jchapman@katalix.com" <jchapman@katalix.com>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "bridge@lists.linux-foundation.org"
        <bridge@lists.linux-foundation.org>,
        "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "vyasevich@gmail.com" <vyasevich@gmail.com>,
        "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "zyan@redhat.com" <zyan@redhat.com>,
        "sage@redhat.com" <sage@redhat.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "jreuter@yaina.de" <jreuter@yaina.de>
Subject: RE: [PATCH 00/36] v2 net subsystem misc refcounter conversions
Date: Wed, 5 Jul 2017 09:03:06 +0000
Message-ID: <2236FBA76BA1254E88B949DDB74E612B6FF20D45@IRSMSX102.ger.corp.intel.com>
References: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
 <20170704.230040.195111189904913382.davem@davemloft.net>
In-Reply-To: <20170704.230040.195111189904913382.davem@davemloft.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> From: Elena Reshetova <elena.reshetova@intel.com>
> Date: Tue,  4 Jul 2017 15:52:55 +0300
> 
> > Changes in v2:
> >  * rebase on top of net-next
> >  * currently by default refcount_t = atomic_t (*) and uses all
> >    atomic standard operations unless CONFIG_REFCOUNT_FULL is enabled.
> >    This is a compromise for the systems that are critical on
> >    performance (such as net) and cannot accept even slight delay
> >    on the refcounter operations.
> >
> > This series, for various misc network components, replaces atomic_t reference
> > counters with the new refcount_t type and API (see include/linux/refcount.h).
> > By doing this we prevent intentional or accidental
> > underflows or overflows that can led to use-after-free vulnerabilities.
> > These are the last networking-related conversions with the exception of
> > network drivers (to be send separately).
> >
> > Please excuse the long patch set, but seems like breaking it up
> > won't save that much on CC list and most of the changes are
> > trivial.
> >
> > The patches are fully independent and can be cherry-picked separately.
> > In order to try with refcount functionality enabled in run-time,
> > CONFIG_REFCOUNT_FULL must be enabled.
> >
> > NOTE: automatic kernel builder for some reason doesn't like all my
> > network branches and regularly times out the builds on these branches.
> > Suggestion for "waiting a day for a good coverage" doesn't work, as
> > we have seen with generic network conversions. So please wait for the
> > full report from kernel test rebot before merging further up.
> > This has been compile-tested in 116 configs, but 71 timed out (including
> > all s390-related configs again). I am trying to see if they can fix
> > build coverage for me in meanwhile.
> >
> > * The respective change is currently merged into -next as
> >   "locking/refcount: Create unchecked atomic_t implementation".
> 
> Series applied, that's enough for this cycle, please.

Thank you very much David! I really appreciate you taking so many of these conversions in
one go! I will stop for now :) 

With regards to net, I only have networking drivers left (16 patches in total), but I can submit them in the
next round. Will go bug other subsystem maintainers next :) 

Best Regards,
Elena.
