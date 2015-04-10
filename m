Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:59502 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431AbbDJQQO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 12:16:14 -0400
Date: Fri, 10 Apr 2015 10:15:51 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "ira.weiny" <ira.weiny@intel.com>
Cc: Doug Ledford <dledford@redhat.com>,
        Michael Wang <yun.wang@profitbricks.com>,
        Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Tom Tucker <tom@opengridcomputing.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
        Christoph Raisch <raisch@de.ibm.com>,
        Mike Marciniszyn <infinipath@intel.com>, Eli Cohen <eli@mellanox.com>,
        Faisal Latif <faisal.latif@intel.com>,
        Upinder Malhi <umalhi@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        PJ Waskiewicz <pj.waskiewicz@solidfire.com>,
        Tatyana Nikolova <Tatyana.E.Nikolova@intel.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Haggai Eran <haggaie@mellanox.com>,
        Ilya Nelkenbaum <ilyan@mellanox.com>,
        Yann Droneaud <ydroneaud@opteya.com>,
        Bart Van Assche <bvanassche@acm.org>,
        Shachar Raindel <raindel@mellanox.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Devesh Sharma <devesh.sharma@emulex.com>,
        Matan Barak <matanb@mellanox.com>, Moni Shoua <monis@mellanox.com>,
        Jiri Kosina <jkosina@suse.cz>,
        Selvin Xavier <selvin.xavier@emulex.com>,
        Mitesh Ahuja <mitesh.ahuja@emulex.com>,
        Li RongQing <roy.qing.li@gmail.com>,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Alex Estrin <alex.estrin@intel.com>,
        Eric Dumazet <edumazet@google.com>, Erez Shitrit <erezsh@mellanox.com>,
        Tom Gundersen <teg@jklm.no>, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback
 query_transport() for each HW
Message-ID: <20150410161551.GA26419@obsidianresearch.com>
References: <5523CCD5.6030401@profitbricks.com>
 <5523D098.3020007@profitbricks.com>
 <1428517786.2980.180.camel@redhat.com>
 <20150408201015.GB28666@obsidianresearch.com>
 <20150410061610.GA26288@phlsvsds.ph.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150410061610.GA26288@phlsvsds.ph.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 02:16:11AM -0400, ira.weiny wrote:

> >         IB ROCEE OPA
> > SMI     Y  N     Y    (though the OPA smi looked a bit different)
> 
> Yes OPA is different but it is based on the class version of the individual
> MADs not any particular device/port support.

> > OPA SMP N  N     Y
> 
> How is this different from the SMI?

Any code that generates SMPs and SMIs is going to need to know what
format to generate them in. It seems we have a sort of weird world
where IB SMPs are supported on OPA but not the IB SMI.

Not sure any users exist though..

> > Maybe the above set would make a lot more sense as:
> >   cap_ib_qp0
> >   cap_ib_qp1
> >   cap_opa_qp0
> 
> I disagree.
> 
> All we need right now is is cap_qp0.  All devices currently support QP1.

I didn't list iWarp in the table because everything is no, but it
doesn't support QP1.

> > ib_sa means the IBA SA protocol is supported (Y Y Y)
> 
> I think this should be (Y N Y)
> 
> IBoE has no SA.  The IBoE code "fabricates" a Path Record it does not need to
> interact with the SA.

I was wondering why there are so many checks in the SA code, I know
RoCEE doesn't use it, but why are there there?
 
> > ib_mcast true if the IBA SA protocol is used for multicast GIDs (Y N
> > Y)
> 
> Given the above why can't we just have the "ib_sa" flag?

Maybe I got it wrong, but yes, if it really means 'IBA SA protocol for
multicast then it can just be cap_sa.

But there is also the idea that some devices can't do multicast at all
(iWarp), we must care about that at some point?

> However, I think checking the link layer is more appropriate here.
> It does not make sense to do IP over IB over Eth.  Even though the
> IBoE can do the "IB" protocol.

Yes, it is ugly.

I think if we look closely we'll find that IPoIB today has a hard
requirement on cap_sa being true, so lets use that?

In fact any ULP that unconditionally uses the SA can use that.

> > I actually really prefer cap_mandatory_grh - that is what is going on
> > here. ie based on that name (as a reviewer) I'd expect to see the mad
> > layer check that the mandatory GRH is always present, or blow up.
> 
> While GRH mandatory (for the GMP) is what this is.  The function
> ib_init_ah_from_path generically is really handling an "IBoE address" to send
> to and therefore we need to force the GRH in the AH.

This make sense to me.

It appears we have at least rocee, rocee v2 (udp?), tcp, ib and opa
address and AH formats? opa would support ib addresses too I guess.

A 
 bool rdma_port_addr_is_XXX()

along with a

  enum AddrType rdma_port_addr_type()

Might be the thing? The latter should only be used with switch()

Jason
