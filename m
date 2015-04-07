Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:42242 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753203AbbDGS4p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2015 14:56:45 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Hefty, Sean'" <sean.hefty@intel.com>,
        "'Michael Wang'" <yun.wang@profitbricks.com>,
        "'Roland Dreier'" <roland@kernel.org>, <linux-rdma@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>
Cc: "'Hal Rosenstock'" <hal.rosenstock@gmail.com>,
        "'Tom Tucker'" <tom@opengridcomputing.com>,
        "'Hoang-Nam Nguyen'" <hnguyen@de.ibm.com>,
        "'Christoph Raisch'" <raisch@de.ibm.com>,
        "'infinipath'" <infinipath@intel.com>,
        "'Eli Cohen'" <eli@mellanox.com>,
        "'Latif, Faisal'" <faisal.latif@intel.com>,
        "'Upinder Malhi'" <umalhi@cisco.com>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'David S. Miller'" <davem@davemloft.net>,
        "'Weiny, Ira'" <ira.weiny@intel.com>,
        "'PJ Waskiewicz'" <pj.waskiewicz@solidfire.com>,
        "'Nikolova, Tatyana E'" <tatyana.e.nikolova@intel.com>,
        "'Or Gerlitz'" <ogerlitz@mellanox.com>,
        "'Jack Morgenstein'" <jackm@dev.mellanox.co.il>,
        "'Haggai Eran'" <haggaie@mellanox.com>,
        "'Ilya Nelkenbaum'" <ilyan@mellanox.com>,
        "'Yann Droneaud'" <ydroneaud@opteya.com>,
        "'Bart Van Assche'" <bvanassche@acm.org>,
        "'Shachar Raindel'" <raindel@mellanox.com>,
        "'Sagi Grimberg'" <sagig@mellanox.com>,
        "'Devesh Sharma'" <devesh.sharma@emulex.com>,
        "'Matan Barak'" <matanb@mellanox.com>,
        "'Moni Shoua'" <monis@mellanox.com>, "'Jiri Kosina'" <jkosina@suse.cz>,
        "'Selvin Xavier'" <selvin.xavier@emulex.com>,
        "'Mitesh Ahuja'" <mitesh.ahuja@emulex.com>,
        "'Li RongQing'" <roy.qing.li@gmail.com>,
        "'Rasmus Villemoes'" <linux@rasmusvillemoes.dk>,
        "'Estrin, Alex'" <alex.estrin@intel.com>,
        "'Doug Ledford'" <dledford@redhat.com>,
        "'Eric Dumazet'" <edumazet@google.com>,
        "'Erez Shitrit'" <erezsh@mellanox.com>,
        "'Tom Gundersen'" <teg@jklm.no>,
        "'Chuck Lever'" <chuck.lever@oracle.com>
References: <5523CCD5.6030401@profitbricks.com> <5523CF30.7000608@profitbricks.com> <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA@ORSMSX109.amr.corp.intel.com>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373A8FBE2FA@ORSMSX109.amr.corp.intel.com>
Subject: RE: [PATCH v2 11/17] IB/Verbs: Reform link_layer_show() and ib_uverbs_query_port()
Date: Tue, 7 Apr 2015 13:56:47 -0500
Message-ID: <005e01d07164$9954e390$cbfeaab0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> > diff --git a/drivers/infiniband/core/sysfs.c
> > b/drivers/infiniband/core/sysfs.c
> > index cbd0383..aa53e40 100644
> > --- a/drivers/infiniband/core/sysfs.c
> > +++ b/drivers/infiniband/core/sysfs.c
> > @@ -248,14 +248,10 @@ static ssize_t phys_state_show(struct ib_port *p,
> > struct port_attribute *unused,
> >  static ssize_t link_layer_show(struct ib_port *p, struct port_attribute
> > *unused,
> >  			       char *buf)
> >  {
> > -	switch (rdma_port_get_link_layer(p->ibdev, p->port_num)) {
> > -	case IB_LINK_LAYER_INFINIBAND:
> > +	if (rdma_transport_ib(p->ibdev, p->port_num))
> >  		return sprintf(buf, "%s\n", "InfiniBand");
> > -	case IB_LINK_LAYER_ETHERNET:
> > +	else
> >  		return sprintf(buf, "%s\n", "Ethernet");
> > -	default:
> > -		return sprintf(buf, "%s\n", "Unknown");
> > -	}
> >  }
> >
> >  static PORT_ATTR_RO(state);
> > diff --git a/drivers/infiniband/core/uverbs_cmd.c
> > b/drivers/infiniband/core/uverbs_cmd.c
> > index a9f0489..3eb6eb5 100644
> > --- a/drivers/infiniband/core/uverbs_cmd.c
> > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > @@ -515,8 +515,10 @@ ssize_t ib_uverbs_query_port(struct ib_uverbs_file
> > *file,
> >  	resp.active_width    = attr.active_width;
> >  	resp.active_speed    = attr.active_speed;
> >  	resp.phys_state      = attr.phys_state;
> > -	resp.link_layer      = rdma_port_get_link_layer(file->device-
> > >ib_dev,
> > -							cmd.port_num);
> > +	resp.link_layer      = rdma_transport_ib(file->device->ib_dev,
> > +							cmd.port_num) ?
> > +			       IB_LINK_LAYER_INFINIBAND :
> > +			       IB_LINK_LAYER_ETHERNET;
> >
> >  	if (copy_to_user((void __user *) (unsigned long) cmd.response,
> >  			 &resp, sizeof resp))
> 
> Both of the above check the transport in order to determine the link layer.
> 
> These values are exposed to user space.  Does anyone know what link layer iWarp returns to user space?

Ethernet:

t4:~ # ibv_devinfo -d cxgb4_0|grep link_layer
                        link_layer:             Ethernet
                        link_layer:             Ethernet

Steve.

