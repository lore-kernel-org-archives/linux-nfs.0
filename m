Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16743 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756005AbbDJRiy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 13:38:54 -0400
Date: Fri, 10 Apr 2015 13:38:38 -0400
From: "ira.weiny" <ira.weiny@intel.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
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
Subject: Re: [PATCH v2 01/17] IB/Verbs: Implement new callback query_transport() for each HW
Message-ID: <20150410173836.GE10675@phlsvsds.ph.intel.com>
References: <5523CCD5.6030401@profitbricks.com> <5523D098.3020007@profitbricks.com> <1428517786.2980.180.camel@redhat.com> <20150408201015.GB28666@obsidianresearch.com> <20150410061610.GA26288@phlsvsds.ph.intel.com> <20150410161551.GA26419@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150410161551.GA26419@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 10:15:51AM -0600, Jason Gunthorpe wrote:
> On Fri, Apr 10, 2015 at 02:16:11AM -0400, ira.weiny wrote:
> 
> > >         IB ROCEE OPA
> > > SMI     Y  N     Y    (though the OPA smi looked a bit different)
> > 
> > Yes OPA is different but it is based on the class version of the individual
> > MADs not any particular device/port support.
> 
> > > OPA SMP N  N     Y
> > 
> > How is this different from the SMI?
> 
> Any code that generates SMPs and SMIs is going to need to know what
> format to generate them in. It seems we have a sort of weird world
> where IB SMPs are supported on OPA but not the IB SMI.

My mistake it was late.  The MAD stack needs to know if it should implement the
IB SMI or the IB & OPA SMI.  That also implies the use of QP0 or vise versa.

In my email to Doug I suggested "OPA MAD" which covers the need to implement
the OPA SMI on that device for MADs which have that class version.

> 
> Not sure any users exist though..

I think all the "users" are either userspace or the drivers themselves.  It is
really just the common SMI processing which needs to be turned on/off.  Again I
think this can be covered with the QP0 flag.

RDMA_MGMT_QP0            = 0x00000200,

> 
> > > Maybe the above set would make a lot more sense as:
> > >   cap_ib_qp0
> > >   cap_ib_qp1
> > >   cap_opa_qp0
> > 
> > I disagree.
> > 
> > All we need right now is is cap_qp0.  All devices currently support QP1.
> 
> I didn't list iWarp in the table because everything is no, but it
> doesn't support QP1.

Isn't ocrdma an iWarp device?

int ocrdma_process_mad(struct ib_device *ibdev,
                       int process_mad_flags,
                       u8 port_num,
                       struct ib_wc *in_wc,
                       struct ib_grh *in_grh,
                       struct ib_mad *in_mad, struct ib_mad *out_mad)
{
        int status;
        struct ocrdma_dev *dev;

        switch (in_mad->mad_hdr.mgmt_class) {
        case IB_MGMT_CLASS_PERF_MGMT:
                dev = get_ocrdma_dev(ibdev);
                if (!ocrdma_pma_counters(dev, out_mad))
                        status = IB_MAD_RESULT_SUCCESS | IB_MAD_RESULT_REPLY;
                else
                        status = IB_MAD_RESULT_SUCCESS;
                break;
        default:
                status = IB_MAD_RESULT_SUCCESS;
                break;
        }
        return status;
}


Regardless I was wrong.  USNIC devices don't support MADs at all.  So we do
need the "supports MADs at all flag".

RDMA_MGMT_IB_MAD         = 0x00000100,

> 
> > > ib_sa means the IBA SA protocol is supported (Y Y Y)
> > 
> > I think this should be (Y N Y)
> > 
> > IBoE has no SA.  The IBoE code "fabricates" a Path Record it does not need to
> > interact with the SA.
> 
> I was wondering why there are so many checks in the SA code, I know
> RoCEE doesn't use it, but why are there there?

Which checks are you referring to?  I think there are separate calls to query
the SA when running on IB for both the Route resolution and the Multicast join
operations.  The choice of those calls could be made by a "cap_sa()" helper.

>  
> > > ib_mcast true if the IBA SA protocol is used for multicast GIDs (Y N
> > > Y)
> > 
> > Given the above why can't we just have the "ib_sa" flag?
> 
> Maybe I got it wrong, but yes, if it really means 'IBA SA protocol for
> multicast then it can just be cap_sa.
> 
> But there is also the idea that some devices can't do multicast at all
> (iWarp), we must care about that at some point?

I was not sure how to handle this either...  I guess you need a
cap_multicast()???

> 
> > However, I think checking the link layer is more appropriate here.
> > It does not make sense to do IP over IB over Eth.  Even though the
> > IBoE can do the "IB" protocol.
> 
> Yes, it is ugly.
> 
> I think if we look closely we'll find that IPoIB today has a hard
> requirement on cap_sa being true, so lets use that?

I don't think that is appropriate.  You have been advocating that the checks
be clear as to what support we need.  While currently the IPoIB layer does (for
IB and OPA) require an SA I think those checks are only appropriate when it is
attempting an SA query.

The choice to run IPoIB at all is a different matter.

> 
> In fact any ULP that unconditionally uses the SA can use that.

They _can_ use that but the point of this exercise (and additional checks going
forward) is that we don't "hide" meaning like this.

IPoIB should restrict itself to running on IB link layers.  Should additional
link layers be added which IPoIB works on then we add that check.

> 
> > > I actually really prefer cap_mandatory_grh - that is what is going on
> > > here. ie based on that name (as a reviewer) I'd expect to see the mad
> > > layer check that the mandatory GRH is always present, or blow up.
> > 
> > While GRH mandatory (for the GMP) is what this is.  The function
> > ib_init_ah_from_path generically is really handling an "IBoE address" to send
> > to and therefore we need to force the GRH in the AH.
> 
> This make sense to me.
> 
> It appears we have at least rocee, rocee v2 (udp?), tcp, ib and opa
> address and AH formats?

Seems that way.  But has the rocee v2 been accepted?

> opa would support ib addresses too I guess.

Yes opa address == ib addresses.  So there is no need to distinguish them.

> 
> A 
>  bool rdma_port_addr_is_XXX()
> 
> along with a
> 
>   enum AddrType rdma_port_addr_type()
> 
> Might be the thing? The latter should only be used with switch()

Sounds good to me.  But Doug has a point that the address type and the "port"
type go together.  So this could probably be the same call for both of those.

Ira

